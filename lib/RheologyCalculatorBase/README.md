# RheologyCalculatorBase.jl

[![CI](https://github.com/albert-de-montserrat/RheologyCalculator.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/albert-de-montserrat/RheologyCalculator.jl/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://albert-de-montserrat.github.io/RheologyCalculator.jl/dev/)

`RheologyCalculatorBase.jl` is a component of the RheologyCalculator.jl monorepo. It holds the core machinery for building and solving local rheological models. Elements can be composed in series, in parallel, or in nested hybrid networks, then converted into a nonlinear residual system solved with Newton iterations.

## Rheological element definitions

The package exports the composition and solver machinery (`SeriesModel`,
`ParallelModel`, `solve`, `initial_guess_x`, …) but **not** the concrete
constitutive elements used throughout the examples (`LinearViscosity`,
`Elasticity`, `DruckerPrager`, and the rest). Those are defined in
RheologyCalculator.jl.
