export clone_organization_repos, create_pull_request

"""
    clone_organization_repos(org; options...)
    clone_organization_repos(org, dest; options...)

Clone all repos from the GitHub organization `org` into folder `dest`.
If `dest` is not specified, used `dest = org`.

Options:

- `auth = AnonymousAuth()`: Authentication token (`GitHub.authenticate(ENV["GITHUB_AUTH"])`)
- `dry_run = false`: Don't clone the repos, only list them.
- `exclude = []`: Exclude listed repos.
"""
function clone_organization_repos(
  org,
  dest = org;
  auth = GitHub.AnonymousAuth(),
  dry_run = false,
  exclude = [],
)
  isdir(dest) || mkdir(dest)
  cloned = String[]
  cd(dest) do
    repos = GitHub.repos(org, true, auth = auth)[1]
    for repo in repos
      repo.name in exclude && continue
      if dry_run
        @info "Would clone $(repo.html_url) but dry_run is true"
      else
        run(`git clone $(repo.html_url)`)
        push!(cloned, repo.name)
      end
    end
  end

  return cloned
end

"""
    pr = create_pull_request(repo, title, body, head; options...)

Very thin layer over GitHub.create_pull_request.
Creates a pull request to `repo` from branch `head` to base `base` (defaults to `main`).
The `title` and `body` must be supplied.

## Options

- `auth = GitHub.AnonymousAuth()`: GitHub authentication token
- `base = "main"`: Main branch where you want to merge the changes
- `dry_run = false`: Test instead of actually running
"""
function create_pull_request(
  repo,
  title,
  body,
  head;
  auth = GitHub.AnonymousAuth(),
  base = "main",
  dry_run = false,
)
  params = Dict(
    :title => title,
    :body => body,
    :head => head,
    :base => base,
    :maintainer_can_modify => true,
    :draft => false,
  )
  pr = if dry_run
    @info "Would create a pull request with params = $params"
    GitHub.PullRequest()
  else
    pr = GitHub.create_pull_request(GitHub.repo(repo), auth = auth, params = params)
    @info "Pull request created at $(pr.url)"
    pr
  end

  return pr
end
