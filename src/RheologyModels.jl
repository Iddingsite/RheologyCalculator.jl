"""
    RheologyModels

Build and solve local rheological models assembled from viscous, elastic, and
plastic elements.
"""
module RheologyModels

# Brings the parent's exported names (SeriesModel, solve, AbstractViscosity, …)
# into scope for the element/model definitions below. Not re-exported: callers
# outside this module get the engine via a separate `using RheologyCalculator`.
using ..RheologyCalculator
using StaticArrays, LinearAlgebra
import ForwardDiff: ForwardDiff

# postprocessing helpers used by the tensor helpers below and by downstream code
import ..RheologyCalculator: compute_stress_elastic, compute_pressure_elastic
export compute_stress_elastic, compute_pressure_elastic

include("rheology/rheology_definitions.jl")

# Advanced / application-specific material models built from the basic elements.
# These are intentionally NOT exported
include("rheology/models/Hyperbolic.jl")
include("rheology/models/ModCamClay.jl")
include("rheology/models/DruckerPragerCap.jl")
include("rheology/models/Golchin.jl")
include("rheology/models/RateState_HypoPlastic.jl")

include("utils/tensor_helpers.jl")

export LinearViscosity, LinearViscosityStress, PowerLawViscosity
export Elasticity, BulkElasticity, IncompressibleElasticity, BulkViscosity
export LTPViscosity, DruckerPrager, DiffusionCreep, DislocationCreep

end
