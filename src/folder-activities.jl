export run_on_folders

"""
    run_on_folders(action, folders)
    run_on_folders(action, folders)

Run `action` into each folder in `folders`.
`action` must be either:
- a `Cmd` (like `ls`, or `git status`).
- a callable with no mandatory arguments with some keyword arguments, but that accepts arbitrary commands.

The following keyword arguments will be passed to `action`:

- `basename`: Folder name stripped of dirs before it.
- `dirname`: Complement of `basename`.
- `index`: Index of traversal in `folders`, obtained from `enumerate(folder_list)`.

If you think of something useful to add to this list, let me know.

## Examples

### Updating a file throught your cloned repos

You want to have the same configuration in all your repos, that are cloned into folder "cloned-repos".

```julia-repl
julia> myfile = joinpath(pwd(), ".editorconfig")
julia> folders = readdir("cloned-repos", join=true)
julia> run_on_folders(`cp \$myfile .`, folders)
julia> run_on_folders((;kws...) ->
       if git_has_to_commit() && run(`git commit -am "Add or update"`), folders)
julia> run_on_folders(`git push`, folders)
```

"""
function run_on_folders(
  action,
  folders;
  dry_run = false
)
  for (index, folder) in enumerate(folders)
    cd(folder) do
      if dry_run
        println("Would run action inside $folder")
      else
        action(
          basename = basename(folder),
          dirname = dirname(folder),
          index=index,
        )
      end
    end
  end
end

function run_on_folders(action, folder::String, args...; kwargs...)
  if !isdir(folder)
    error("$folder is not a folder nor a list of folders")
  end
  run_on_folders(action, readdir(folder, join=true))
end

function run_on_folders(action::Cmd, args...; kwargs...)
  run_on_folders((; kwargs...) -> run(action), args...; kwargs...)
end

function run_on_folders(action::Cmd, folder::String, args...; kwargs...)
  run_on_folders((; kwargs...) -> run(action), folder, args...; kwargs...)
end