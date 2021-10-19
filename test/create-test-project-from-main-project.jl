@testset "Create test/Project.toml from Project.toml" begin
  project_before = joinpath(@__DIR__, "auxiliary-files/Project-with-extras-and-target.toml")
  project_after = joinpath(@__DIR__, "auxiliary-files/Project-without-extras-and-target.toml")
  project_inside_test = joinpath(@__DIR__, "auxiliary-files/Project-inside-test.toml")
  cd(mktempdir()) do
    @testset "Test Project.toml exist" begin
      @test_throws ErrorException create_test_project_from_main_project()
    end
    cp(project_before, "Project.toml")
    create_test_project_from_main_project()
    @testset "Project.toml OK" begin
      @test readlines("Project.toml") == readlines(project_after)
    end
    @testset "test/Project.toml OK" begin
      @test isfile("test/Project.toml")
      @test readlines("test/Project.toml") == readlines(project_inside_test)
    end
    @testset "Fail if test/Project.toml exists" begin
      @test_throws ErrorException create_test_project_from_main_project()
    end
  end
end
