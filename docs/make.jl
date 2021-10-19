using Emporium
using Documenter

DocMeta.setdocmeta!(Emporium, :DocTestSetup, :(using Emporium); recursive = true)

makedocs(;
  modules = [Emporium],
  authors = "Abel Soares Siqueira <abel.s.siqueira@gmail.com> and contributors",
  repo = "https://github.com/abelsiqueira/Emporium.jl/blob/{commit}{path}#{line}",
  sitename = "Emporium.jl",
  format = Documenter.HTML(;
    prettyurls = get(ENV, "CI", "false") == "true",
    canonical = "https://abelsiqueira.github.io/Emporium.jl",
    assets = String[],
  ),
  pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/abelsiqueira/Emporium.jl", devbranch = "main")
