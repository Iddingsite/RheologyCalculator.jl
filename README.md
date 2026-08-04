# RheologyCalculator.jl

[![CI](https://github.com/albert-de-montserrat/RheologyCalculator.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/albert-de-montserrat/RheologyCalculator.jl/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://albert-de-montserrat.github.io/RheologyCalculator.jl/dev/)
[![codecov](https://codecov.io/gh/albert-de-montserrat/RheologyCalculator.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/albert-de-montserrat/RheologyCalculator.jl)
[![version](https://juliahub.com/docs/General/RheologyCalculator/stable/version.svg)](https://juliahub.com/ui/Packages/General/RheologyCalculator)

`RheologyCalculator.jl` builds and solves local rheological models from small
viscous, elastic, and plastic building blocks. Elements can be composed in
series, in parallel, or in nested hybrid networks, then converted into a
nonlinear residual system solved with Newton iterations.

## Repository layout

This repository ships **two packages**:

| Package | Location | What it is |
| --- | --- | --- |
| **`RheologyCalculator`** | repository root | The **core engine**: composition containers (`SeriesModel`, `ParallelModel`), equation generation, the Newton solver, and the state-function interface. Independent of any material catalogue. |
| **`RheologyCalculatorModels`** | [`lib/RheologyCalculatorModels`](./lib/RheologyCalculatorModels) | Concrete constitutive elements (`LinearViscosity`, `Elasticity`, `DruckerPrager`, creep laws, …) plus advanced material models. **Start here if you just want to build and solve models.** |

`RheologyCalculatorModels` depends on and **re-exports** `RheologyCalculator`, so
a single `using RheologyCalculatorModels` gives you the full API — solver
machinery *and* the material catalogue. Reach for `RheologyCalculator` on its own
only when you want the solver engine without the bundled elements (for example,
to supply your own material laws).

## Installation

The core engine is registered in the Julia General registry:

```julia
using Pkg
Pkg.add("RheologyCalculator")
```

The models package lives in this repository under
[`lib/RheologyCalculatorModels`](./lib/RheologyCalculatorModels) — see its
[README](./lib/RheologyCalculatorModels/README.md) for how to use it.

## Quick Start

To quickly build and solve models, use `RheologyCalculatorModels` (it re-exports the
core, so this one import is all you need):

```julia
using RheologyCalculatorModels

viscous = LinearViscosity(1e22)
elastic = IncompressibleElasticity(1e10)
c = SeriesModel(viscous, elastic)

vars   = (; ε = 1.0e-14, θ = 0.0)
args   = (; τ = 1.0e3, P = 0.0)
others = (; dt = 1.0e10, τ0 = (0.0,), P0 = (0.0,))

x = initial_guess_x(c, vars, args, others)
x = solve(c, x, vars, others)
```

> **Note:** `using RheologyCalculator` alone exports the composition and solver
> machinery (`SeriesModel`, `ParallelModel`, `solve`, `initial_guess_x`, …) but
> **not** the concrete elements (`LinearViscosity`, `Elasticity`, …). Those live
> in `RheologyCalculatorModels`.

## Composite Models

Models are assembled with `SeriesModel` and `ParallelModel`:

```julia
maxwell = SeriesModel(LinearViscosity(1e22), IncompressibleElasticity(1e10))
kv      = ParallelModel(LinearViscosity(1e21), IncompressibleElasticity(1e10))
burgers = SeriesModel(LinearViscosity(1e22), kv)
```

Nested generalized Maxwell / Kelvin-Voigt branches are supported, including
elastic elements inside parallel branches:

```julia
c = SeriesModel(
    LinearViscosity(1e22),
    ParallelModel(
        LinearViscosity(1e21),
        SeriesModel(LinearViscosity(1e21), IncompressibleElasticity(1e10)),
    ),
)
```

![Mixed Kelvin-Voigt and Maxwell model](./docs/assets/Maxwell_KV_Maxwell.png)

See [`examples/Maxwell_KV_Maxwell.jl`](./examples/Maxwell_KV_Maxwell.jl) for a
comparison against the analytical solution, and
[`docs/src/strain_rate_correction.md`](./docs/src/strain_rate_correction.md) for
the elastic correction derivation.

## Material models

`RheologyCalculatorModels` bundles a catalogue of advanced material models. To
keep the namespace small they are **not exported** — access them via the package
prefix or an explicit import:

```julia
using RheologyCalculatorModels
import RheologyCalculatorModels: DruckerPragerCap, Hyperbolic, ModCamClay, Golchin, RateStateFriction
```

### VEP + Cap (Popov et al., 2025)

![](./docs/assets/VEPCap.png)

### Hyperbolic (Abbo & Sloan, 1995)

![](./docs/assets/Hyperbolic.png)

### Modified Cam-Clay - classical (e.g., de Souza Neto book)

![](./docs/assets/ModCamClay.png)

### Modified Cam-Clay - Golchin (Golchin et al., 2021)

![](./docs/assets/Golchin.png)

### Rate and State friction (Herrendörfer et al., 2018)

![](./docs/assets/RateState.png)
