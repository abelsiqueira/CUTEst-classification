# CUTEst classification

This script updates the classification of the MASTSIF problems in [CUTEst.jl](https://github.com/JuliaSmoothOptimizers/CUTEst.jl).

## How it works

- Install the latest CUTEst.jl;
- Check whether `CLASSF.DB` has changed;
- If it has, for each changed problem, create its classification;
- In addition, test that the classification is consistent with `CLASSF.DB`.
