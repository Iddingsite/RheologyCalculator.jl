if VERSION ≤ v"1.12.3"
    using Aqua
    @testset "Project extras" begin
        @test Aqua.test_project_extras(RheologyCalculatorModels).value
    end

    @testset "Undefined exports" begin
        @test Aqua.test_undefined_exports(RheologyCalculatorModels).value
    end

    @testset "Compats" begin
        @test !Aqua.test_deps_compat(
            RheologyCalculatorModels;
            check_julia = true,
            check_extras = false,
        ).anynonpass
        # @test Aqua.test_stale_deps(RheologyCalculatorModels).value
    end

    @testset "Persistent tasks" begin
        Aqua.test_persistent_tasks(RheologyCalculatorModels)
    end

    @testset "Ambiguities" begin
        @test Aqua.test_ambiguities(RheologyCalculatorModels).value
    end

    @testset "Piracy" begin
        @test Aqua.test_piracies(RheologyCalculatorModels).value
    end
end
