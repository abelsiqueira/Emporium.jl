export create_test_project_from_main_project

using TOML

"""
    create_test_project_from_main_project()

Create `test/Project.toml` from the sections [extras] and [targets] in `Project.toml`.
"""
function create_test_project_from_main_project()
  # Initial checks
  if !isfile("Project.toml")
    error("File Project.toml doesn't exist")
  end
  if isfile("test/Project.toml")
    error("File test/Project.toml already exists")
  end

  # Early return if there's nothing we can do. No error!
  project = TOML.parsefile("Project.toml")
  if ["targets", "extras"] ∩ keys(project) == [] || !("test" in keys(project["targets"]))
    @info ["targets", "extras"] ∩ keys(project)
    @info "test" in keys(project["targets"])
    @info(
      "Nothing to do, create test/Project.toml manually: just `pkg> activate test` and `add` things."
    )
    return
  end

  # Actual code
  compat, deps, extras, targets = getindex.(Ref(project), ["compat", "deps", "extras", "targets"])
  test_deps = Dict()
  test_compat = Dict()

  # We only unpack the "test" target
  for pkg in targets["test"]
    # Project.toml could be ill-written, so some checks are made
    if pkg in keys(extras) # extras can be moved
      test_deps[pkg] = extras[pkg]
      delete!(extras, pkg)
    elseif pkg in keys(deps) # deps are copied
      test_deps[pkg] = deps[pkg]
    else # shouldn't happen
      error("Unknown package $pkg in target list")
    end
    if pkg in keys(compat) # copy compats too!
      test_compat[pkg] = compat[pkg]
      if !(pkg in keys(deps))
        delete!(compat, pkg)
      end
    end
  end
  delete!(targets, "test")
  for k in ["compat", "deps", "extras", "targets"]
    if length(project[k]) == 0
      delete!(project, k)
    end
  end
  test_project = Dict("deps" => test_deps)
  if length(test_compat) > 0
    test_project["compat"] = test_compat
  end

  # Copied from Pkg.jl
  _project_key_order = ["name", "uuid", "keywords", "license", "desc", "deps", "compat"]
  project_key_order(key::String) =
    something(findfirst(x -> x == key, _project_key_order), length(_project_key_order) + 1)
  by = key -> (project_key_order(key), key)

  mkpath("test")
  open("test/Project.toml", "w") do io
    TOML.print(io, test_project, sorted = true, by = by)
  end
  open("Project.toml", "w") do io
    TOML.print(io, project, sorted = true, by = by)
  end
end
