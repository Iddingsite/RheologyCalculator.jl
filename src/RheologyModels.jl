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
# category (and, where the literature draws a clear line, by sub-family).
# Advanced / application-specific models (built from these blocks) sit alongside
# their category and are intentionally NOT exported.

# viscous: Newtonian (linear stress-strain-rate) vs non-Newtonian (rate-dependent).
# Rate-and-state friction lives here too: despite the filename, it has no yield
# surface or plastic multiplier -- compute_strain_rate is a smooth, invertible
# function of stress at every stress level, exactly like the other non-Newtonian
# (sinh-type) laws, so per its own AbstractViscosity supertype it belongs here.
include("rheology/viscous/Newtonian/LinearViscosity.jl")
include("rheology/viscous/Newtonian/BulkViscosity.jl")
include("rheology/viscous/Newtonian/DiffusionCreep.jl")
include("rheology/viscous/nonNewtonian/PowerLawViscosity.jl")
include("rheology/viscous/nonNewtonian/LTPViscosity.jl")
include("rheology/viscous/nonNewtonian/DislocationCreep.jl")
include("rheology/viscous/nonNewtonian/RateState_HypoPlastic.jl")

include("rheology/elastic/Elasticity.jl")
include("rheology/elastic/BulkElasticity.jl")
include("rheology/elastic/IncompressibleElasticity.jl")

# plastic: frictional/Coulomb-type family (cohesion + friction + dilation angle;
# open cone yield surface, with cap/smoothed-corner variants) vs critical-state
# family (M/N + tensile/compaction pressure parametrization; closed elliptical
# yield surface, e.g. Cam-Clay and its extensions).
include("rheology/plastic/frictional/DruckerPrager.jl")
include("rheology/plastic/frictional/DruckerPragerCap.jl")
include("rheology/plastic/frictional/Hyperbolic.jl")
include("rheology/plastic/criticalstate/ModCamClay.jl")
include("rheology/plastic/criticalstate/Golchin.jl")

include("utils/tensor_helpers.jl")

export LinearViscosity, PowerLawViscosity
export Elasticity, BulkElasticity, IncompressibleElasticity, BulkViscosity
export LTPViscosity, DruckerPrager, DiffusionCreep, DislocationCreep

end
