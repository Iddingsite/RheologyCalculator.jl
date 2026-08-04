# RheologyCalculatorModels.jl

`RheologyCalculatorModels` provides the concrete material building blocks and a
catalogue of advanced constitutive models, and **re-exports
`RheologyCalculator`** so a single `using RheologyCalculatorModels` gives you
both the solver machinery (`SeriesModel`, `ParallelModel`, `solve`, …) and a
ready set of material laws.

## What it provides

- **Viscous:** `LinearViscosity`, `LinearViscosityStress`, `PowerLawViscosity`,
  `BulkViscosity`, `LTPViscosity`, `DiffusionCreep`, `DislocationCreep`
- **Elastic:** `Elasticity`, `IncompressibleElasticity`, `BulkElasticity`
- **Plastic:** `DruckerPrager`

together with the post-processing helpers `compute_stress_elastic` and
`compute_pressure_elastic`.

**Advanced material models** — defined but **not exported** (access via
`RheologyCalculatorModels.<Model>` or an explicit `import`):

| Model | Reference |
| --- | --- |
| `DruckerPragerCap` | VEP with tensile cap (Popov et al., 2025) |
| `Hyperbolic` | Hyperbolic yield (Abbo & Sloan, 1995) |
| `ModCamClay` | Modified Cam-Clay |
| `Golchin` | Modified Cam-Clay variant (Golchin et al., 2021) |
| `RateStateFriction` | Rate-and-state friction (Herrendörfer et al., 2018) |

The lower-level tensor helpers (`vars_2D`, `second_invariant_2D`,
`elastic_stress_history_2D`, `zero_stress_tensor_2D`, …) are likewise defined but
not exported; import them explicitly when a script needs them.

## Usage

From a checkout of the repository, activate the package environment:

```julia
using Pkg
Pkg.activate("lib/RheologyCalculatorModels")
Pkg.instantiate()
```

Then build and solve a model:

```julia
using RheologyCalculatorModels

c = SeriesModel(LinearViscosity(1e22), IncompressibleElasticity(1e10))

vars   = (; ε = 1.0e-14, θ = 0.0)
args   = (; τ = 1.0e3, P = 0.0)
others = (; dt = 1.0e10, τ0 = (0.0,), P0 = (0.0,))

x = initial_guess_x(c, vars, args, others)
x = solve(c, x, vars, others)
```

Using one of the advanced models (imported explicitly, since they are not
exported):

```julia
import RheologyCalculatorModels: DruckerPragerCap

plastic = DruckerPragerCap(; C = 1e6, ϕ = 30.0, ψ = 10.0, η_vp = 0.0, Pt = -5e5)
c = SeriesModel(LinearViscosity(1e23), Elasticity(1e10, 2e11), plastic)
```

The runnable scripts in [`../../examples`](../../examples) all build on this
package.

## Relationship to `RheologyCalculator`

`RheologyCalculatorModels` depends on `RheologyCalculator` (a path dependency
within this monorepo) and re-exports it. The core owns the composition
containers, equation generation, and the Newton solver; this package adds the
concrete material laws that extend the core's state-function interface. See the
[top-level README](../../README.md) for the overall project overview.
