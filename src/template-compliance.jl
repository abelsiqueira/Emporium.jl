export check_and_fix_compliance

"""
    check_and_fix_compliance(template_folder, file_list, workdir = "cloned_repos"; options...)

Compares the list of files given in `file_list` for every package in `workdir` with the same files in `template_folder`.
If some cases, the template files have a package name placeholder that needs to be replaced by the actual package name. Set this with the keyword variable `template_pkg_name`.

## Keywords arguments

- `auth`: GitHub.jl authentication token (use `GitHub.authenticate(YOUR_TOKEN)`).
- `check_only::Bool`: If true, will display only the comparison, without fixing anything (default: `false`).
- `close_older_compliance_prs::Bool`: If `create_pr` is enabled, and this is true, it will look for other PRs with the same branch name prefix and close them (default: `true`).
- `create_pr::Bool`: Whether to create a pull request, or just the commits. Requires a valid `auth` key (default: `false`).
- `filter_jl_ending::Bool`: Whether to check only folders ending in `.jl` or all folders (default: `true`).
- `info_header_frequency::Int`: How often to show the header with the file names (default: `5`).
- `owner::String`: If `create_pr` is true, then this is the owner of the repo, and can't be empty. The full url of the repo is `https://github.com/\$owner/\$pkg`, where `pkg` is the folder name (default: "").
- `rename_these_files::Vector{Pair{String, String}}`: List of files to be renamed, if they exist. This will be done before fixing the content with new files. Each pair is of the form `old => new` (default: []).
- `template_pkg_name::String`: The placeholder for the package name in the files.

# Extended help

## Examples

```julia
julia> clone_organization_repos("MyOrg", "cloned_repos", exclude=["MyTemplate.jl"]) # Clone from my org into repos
julia> run(`git clone https://github.com/MyOrg/MyTemplate.jl`)
julia> auth = GitHub.authenticate(ENV["GITHUB_TOKEN"])
julia> check_and_fix_compliance(
           "MyTemplate.jl",
           [".JuliaFormatter.jl", ".github/workflows/CI.yml"],
           "cloned_repos",
           auth = auth,
           check_only = false,
           close_older_compliance_prs = true,
           create_pr = true,
           owner = "MyOrg",
           rename_these_files = [".github/workflows/ci.yml"  => ".github/workflows/CI.yml"],
           template_pkg_name = "MyTemplate",
       )
```
"""
function check_and_fix_compliance(
  template_folder,
  file_list,
  workdir = "cloned_repos";
  auth = GitHub.AnonymousAuth(),
  check_only = false,
  close_older_compliance_prs = true,
  commit_message = ":bot: Template compliance update",
  create_pr = false,
  filter_jl_ending = true,
  info_header_frequency::Int = 5,
  owner = "",
  pr_title = "[Emporium.jl] Template compliance update",
  pr_body = "Created with Emporium.jl function `check_and_fix_compliance`",
  rename_these_files = [],
  template_pkg_name = "",
)
  if create_pr && owner == ""
    error("You must define the `owner` keyword argument to create the Pull Requests")
  end
  pkg_list = readdir(workdir)
  if filter_jl_ending
    pkg_list = filter(x -> x[(end - 2):end] == ".jl", pkg_list)
  end
  column_fmts = [
    "%-$(maximum(length.(pkg_list)))s";
    ["%$(len)s" for len in length.(basename.(file_list))]...
  ]

  table_line(V) = join(sprintf1.(column_fmts, V), "  ")
  @info "Checking simple files"
  for (ipkg, pkg) in enumerate(pkg_list)
    if ipkg % info_header_frequency == 1
      @info table_line(["Package"; basename.(file_list)])
    end
    # Renaming file
    if !check_only
      cd(joinpath(workdir, pkg)) do
        for (old_file, new_file) in rename_these_files
          if isfile(old_file)
            run(`git mv $old_file $new_file`)
          end
        end
      end
    end
    success = fill(false, length(file_list))
    for (ifile, file) in enumerate(file_list)
      # Compare content
      pkg_file_path = joinpath(workdir, pkg, file)
      old_file_str = isfile(pkg_file_path) ? read(pkg_file_path, String) : ""
      file_str = read(file, String)
      if old_file_str == file_str
        success[ifile] = true
      end
      # Fix the files by copying from template
      if !check_only
        open(pkg_file_path, "w") do out_stream
          file_str = replace(file_str, template_pkg_name => pkg[1:(end - 3)])
          print(out_stream, file_str)
        end
      end
    end
    success_str = [s ? "✓" : "⨉" for s in success]
    @info table_line([pkg; success_str])
  end

  if check_only
    return
  end
  branch_name = "emporium/compliance-" * Dates.format(now(), "yyyy-mm-dd-HH-MM-SS-sss")
  run_on_folders(
    (; basename = "", dirname = "", index = "") -> begin
      for file in file_list
        run(`git add $file`)
      end
      if git_has_to_commit()
        @info "Creating commit in $basename"
        run(`git checkout -b $branch_name`)
        run(`git commit -m "$commit_message"`)
        if create_pr
          repo = "$owner/$basename"
          @info "Creating pull request to $repo"
          run(`git remote set-url origin https://$(auth.token)@github.com/$repo`)

          @info "Checking for older compliance PRs"
          prs, _ = GitHub.pull_requests(repo, auth = auth)
          abort_pr = false
          for pr in prs
            if startswith(pr.head.ref, "emporium/compliance-") && pr.head.ref != branch_name
              remote = if pr.head.user.login != owner
                remote = pr.head.user.login
                run(`git remote set-url $remote https://github.com/$remote/$basename`)
                remore
              else
                "origin"
              end
              if length(read(`git diff $remote/$(pr.head.ref)`)) == 0
                # No difference to existing PR
                @info "PR#$(pr.number) already implements the proposed PR"
                abort_pr = true
                break
              end
            end
          end

          if !abort_pr
            run(`git push -u origin $branch_name`)
            new_pr = create_pull_request(
              repo,
              pr_title,
              pr_body,
              branch_name,
              auth = auth,
            )
            if close_older_compliance_prs
              for pr in prs
                if startswith(pr.head.ref, "emporium/compliance-") && pr.head.ref != branch_name

                  @info "Closing PR $(pr.number)"
                  GitHub.create_comment(
                    repo,
                    pr,
                    "Closing in favor of #$(new_pr.number)",
                    auth = auth,
                  )
                  GitHub.close_pull_request(repo, pr, auth = auth)
                end
              end
            end
          end
        end
      end
    end,
    [joinpath(workdir, x) for x in pkg_list],
  )
end
