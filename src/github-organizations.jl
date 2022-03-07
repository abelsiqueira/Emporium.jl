export clone_organization_repos

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
  cd(dest) do
    repos = GitHub.repos(org, true, auth = auth)[1]
    for repo in repos
      repo.name in exclude && continue
      if dry_run
        println("Would clone $(repo.html_url) but dry_run is true")
      else
        run(`git clone $(repo.html_url)`)
      end
    end
  end
end
