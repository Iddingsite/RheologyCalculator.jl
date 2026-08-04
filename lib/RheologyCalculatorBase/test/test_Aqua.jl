if VERSION ≤ v"1.12.3"
    using Aqua
    @testset "Project extras" begin
        @test Aqua.test_project_extras(RheologyCalculatorBase).value
    end

    @testset "Undefined exports" begin
        @test Aqua.test_undefined_exports(RheologyCalculatorBase).value
    end

    @testset "Compats" begin
        @test !Aqua.test_deps_compat(
            RheologyCalculatorBase;
            check_julia = true,
            check_extras = false,
        ).anynonpass
        # @test Aqua.test_stale_deps(RheologyCalculatorBase).value
    end

    @testset "Persistent tasks" begin
        Aqua.test_persistent_tasks(RheologyCalculatorBase)
    end

    @testset "Ambiguities" begin
        @test Aqua.test_ambiguities(RheologyCalculatorBase).value
    end

    @testset "Piracy" begin
        @test Aqua.test_piracies(RheologyCalculatorBase).value
    end
end
