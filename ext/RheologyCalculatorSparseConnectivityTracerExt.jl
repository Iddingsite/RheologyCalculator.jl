module RheologyCalculatorSparseConnectivityTracerExt

using RheologyCalculator
using RheologyCalculator: AbstractCompositeModel
using SparseConnectivityTracer: AbstractTracer
using StaticArrays

# Global tracers carry a sparsity pattern but no primal value, so the
# value-dependent guards in the solver must fall back to their unguarded form.
# The guard only ever avoided Inf/NaN in the *value*; the dependency pattern is
# identical either way.
@inline RheologyCalculator.safe_inv(v::AbstractTracer)     = inv(v)
@inline RheologyCalculator.safe_inv_one(v::AbstractTracer) = inv(v)
@inline RheologyCalculator.norm_weight(xi, yi::AbstractTracer) = abs(xi / yi)

# Union the sparsity patterns of every numeric leaf of a nested structure.
tracer_union(acc, v::Number)                       = acc + v
tracer_union(acc, v::Union{Tuple, AbstractArray})  = foldl(tracer_union, v; init = acc)
tracer_union(acc, v::NamedTuple)                   = foldl(tracer_union, values(v); init = acc)
tracer_union(acc, ::Any)                           = acc

"""
Sparsity short-circuit for the local Newton solve.

Running the iteration under a global tracer is neither possible (the internal
`ForwardDiff.jacobian` and the pivoted `\\` need primal values) nor necessary.
By the implicit function theorem the converged solution satisfies
`∂x*/∂v = -J⁻¹ ∂r/∂v`, and `J⁻¹` couples all local unknowns, so every component
of `x*` depends on every traced input. Returning that union is the correct
conservative sparsity pattern, and it avoids executing the constitutive laws,
whose yield-function guards are themselves value-dependent, under a tracer.
"""
function RheologyCalculator.solve(c::AbstractCompositeModel, x::SVector{N, T},
                                  vars, others; kwargs...) where {N, T <: AbstractTracer}
    dep = foldl(tracer_union, x; init = zero(T))
    dep = tracer_union(dep, vars)
    return SVector{N, T}(ntuple(_ -> dep, N))
end

end