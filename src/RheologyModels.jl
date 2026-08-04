"""
    RheologyModels

Build and solve local rheological models assembled from viscous, elastic, and
plastic elements.
"""
module RheologyModels

using ..RheologyCalculator
using StaticArrays, LinearAlgebra
import ForwardDiff: ForwardDiff

# postprocessing helpers used by the tensor helpers below and by downstream code
import ..RheologyCalculator: compute_stress_elastic, compute_pressure_elastic
export compute_stress_elastic, compute_pressure_elastic

# Basic viscous/elastic/plastic building blocks, one struct per file, grouped by
# category. Advanced / application-specific models (built from these blocks) sit
# alongside their category and are intentionally NOT exported.
include("rheology/viscous/LinearViscosity.jl")
include("rheology/viscous/PowerLawViscosity.jl")
include("rheology/viscous/BulkViscosity.jl")
include("rheology/viscous/LTPViscosity.jl")
include("rheology/viscous/DiffusionCreep.jl")
include("rheology/viscous/DislocationCreep.jl")

include("rheology/elastic/Elasticity.jl")
include("rheology/elastic/BulkElasticity.jl")
include("rheology/elastic/IncompressibleElasticity.jl")

include("rheology/plastic/DruckerPrager.jl")
include("rheology/plastic/DruckerPragerCap.jl")
include("rheology/plastic/Golchin.jl")
include("rheology/plastic/Hyperbolic.jl")
include("rheology/plastic/ModCamClay.jl")
include("rheology/plastic/RateState_HypoPlastic.jl")

include("utils/tensor_helpers.jl")

export LinearViscosity, LinearViscosityStress, PowerLawViscosity
export Elasticity, BulkElasticity, IncompressibleElasticity, BulkViscosity
export LTPViscosity, DruckerPrager, DiffusionCreep, DislocationCreep

end
