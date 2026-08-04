using RheologyCalculatorBase, Test
import RheologyCalculatorBase: compute_stress_elastic, compute_pressure_elastic
import RheologyCalculatorBase: compute_residual

function runtests()
    # Concrete rheological elements used across the Base test suite. We include the
    # single source of truth from the parent RheologyCalculator package rather than
    # a duplicate: the file only extends RheologyCalculatorBase's interface functions
    # (no RheologyCalculator dependency), so Base still tests cycle-free.
    include(joinpath(@__DIR__, "..", "..", "..", "src", "rheology", "rheology_definitions.jl"))

    files = readdir(@__DIR__)
    test_files = filter(startswith("test_"), files)

    allocations_only = "--allocations-only" in ARGS
    if allocations_only
        test_files = filter(==("test_allocations.jl"), test_files)
    elseif Base.JLOptions().code_coverage != 0
        filter!(!=("test_allocations.jl"), test_files)
    end

    for f in test_files
        !isdir(f) && include(f)
    end
    return
end

runtests()
