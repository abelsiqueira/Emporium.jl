@testset "Git auxiliary tests" begin
  cd(mktempdir()) do
    run(`git init`)
    run(`git config --local user.name "Emporium"`)
    run(`git config --local user.email "shop@emporium.com"`)
    open("a.file", "w") do io
      println(io, "TMP")
    end
    open("b.file", "w") do io
      println(io, "TMP")
    end
    run(`git add a.file b.file`)
    run(`git commit -m "First commit"`)

    @testset "Clean work dir" begin
      @test !git_has_to_commit()
    end

    open("a.file", "w") do io
      println(io, "TMP2")
    end
    @testset "Modification on the work dir" begin
      @test git_has_modifications_to_stage()
      @test !git_has_staged_to_commit()
    end

    run(`git add a.file`)
    @testset "Staged on the work dir" begin
      @test !git_has_modifications_to_stage()
      @test git_has_staged_to_commit()
    end

    open("b.file", "w") do io
      println(io, "TMP2")
    end
    @testset "Staged on the work dir" begin
      @test git_has_modifications_to_stage()
      @test git_has_staged_to_commit()
    end
  end
end
