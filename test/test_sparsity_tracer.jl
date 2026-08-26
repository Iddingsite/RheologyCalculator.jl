using Test
using RheologyCalculator
using RheologyCalculator.RheologyModels
using StaticArrays
using ForwardDiff
using SparseConnectivityTracer

import RheologyCalculator: initial_guess_x, normalisation_x, solve, SeriesModel,
    safe_inv, safe_inv_one, norm_weight
import RheologyCalculator.RheologyModels: DruckerPragerCap

# The tracer guards replaced three inline value-dependent expressions. Pin the
# Float64 semantics of each against the expression it replaced, including the
# zero cases that motivated the guards in the first place.
@testset "tracer guards preserve Float64 semantics" begin
    for v in (4.0, -2.5, 1.0e-30)
        @test safe_inv(v)     === (iszero(v) ? zero(v) : inv(v))
        @test safe_inv_one(v) === (iszero(v) ? one(v)  : inv(v))
    end
    @test safe_inv(0.0)     === 0.0    # guard: no Inf
    @test safe_inv_one(0.0) === 1.0    # guard: neutral element, no Inf
    @test safe_inv(4.0)     === 0.25
    @test safe_inv_one(4.0) === 0.25

    for (xi, yi) in ((3.0, 2.0), (-3.0, 2.0), (3.0, -2.0))
        @test norm_weight(xi, yi) === !iszero(yi) * abs(xi / yi)
    end
    @test norm_weight(3.0, 0.0) === 0.0    # guard: zero normalisation contributes nothing
    @test norm_weight(3.0, 2.0) === 1.5
end

@testset "SparseConnectivityTracer extension" begin
    @test Base.get_extension(
        RheologyCalculator, :RheologyCalculatorSparseConnectivityTracerExt,
    ) !== nothing

    viscous = LinearViscosity(1.0e23)
    elastic = Elasticity(1.0e10, 2.0e11)
    plastic = DruckerPragerCap(; C = 1.0e6, ϕ = 30.0, ψ = 10.0, η_vp = 1.0e18, Pt = -5.0e5)
    c = SeriesModel(viscous, elastic, plastic)

    others = (; dt = 1.0e5, τ0 = (zero_stress_tensor_2D(),), P0 = (0.3e6,))
    args = (; τ = 0.0e3, P = 0.3e6, λ = 0)
    v0 = [7.0e-14, 7.0e-15]

    function solve_outputs(input)
        strain_rate, volumetric_strain_rate = input
        vars = vars_2D(strain_rate, volumetric_strain_rate)
        x = initial_guess_x(c, vars, args, others)
        return solve(c, x, vars, others;
            xnorm0 = normalisation_x(c, plastic.C, 7.0e-14),
        )
    end

    @testset "global sparsity detection succeeds" begin
        # Without the extension this throws
        # "Function iszero requires primal value(s)".
        S = SparseConnectivityTracer.jacobian_sparsity(
            solve_outputs, v0, TracerSparsityDetector(),
        )
        @test size(S) == (length(normalisation_x(c, plastic.C, 7.0e-14)), length(v0))

        # The solve short-circuits under a tracer
        # each output must depend on every traced input.
        @test all(S)

        # The essential correctness property of any sparsity pattern: it must
        # be a superset of the true nonzeros, never miss one.
        J = ForwardDiff.jacobian(solve_outputs, v0)
        @test all(S[J .!= 0])
    end

    @testset "short-circuit returns one entry per unknown" begin
        n = length(normalisation_x(c, plastic.C, 7.0e-14))
        S = SparseConnectivityTracer.jacobian_sparsity(
            solve_outputs, v0, TracerSparsityDetector(),
        )
        @test size(S) == (n, length(v0))
        @test all(S)
    end
end
