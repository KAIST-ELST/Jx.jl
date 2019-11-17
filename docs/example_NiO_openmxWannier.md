---
layout: single #splash #single
author_profile: false
title: "NiO example"
classes: wide


toc: true
toc_label: "NiO (OpenMX Wannier) example"
toc_icon: "cog"

---

<style>
.color-box-green{
    background-color: green;
    height: 5px
}
</style>

<html>
<div class="color-box-green"></div>
</html>


This is the example of NiO with a G-type order from OpenMX Wannier Hamiltonaion.
In the primitive cell, two spins have different up, down order.
After the electronic structure is given,
the MFT calculation procedures consist of two processes process of [calculating J(q)](#jq-calculation) and [converting J(q) to J(R)](#jq-jr-transformation).

## The required files for Jx MFT calculation (with OpenMX)

> - [OpenMX result Hamiltonian file `*.HWR`](#niodat)
> - [The *Jx* input file `*.toml`](#nio_j_openmxtoml)

These files are provided in the following example script.




## J(q) calculation

```bash
cd examples/NiO_G-AFM.OpenMx
```

```bash
julia -p 4 src/Jx_col_spin_exchange.jl  -T nio_J_wannier.toml
```

This is the main MFT procedure. 
This is the most time-consuming part.
For MFT with Wannier Hamiltonians, the output path is `jx.col.spin.wannier_0.0` (not `jx.col.spin_0.0`),
 and inside the output path two files `jx.col.spin.wannier_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.jld2`, `jx.col.spin.wannier_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.jld2` will be generated.


> The parallel option can be given by `-p #of cpu core` or `--machine-file #PBS_NODES`. See [Julia parallel computing](https://docs.julialang.org/en/v1/manual/parallel-computing/#Starting-and-managing-worker-processes-1) for detailed options.

## J(q)->J(R) transformation
```bash
julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom 1 --atom2 1,2 --orbital_name all_all  jx.col.spin.wannier_0.0
```


The output files are `jx.col.spin.wannier_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.csv`
`jx.col.spin.wannier_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.csv` and the ploted image `Jplot_1_1,2_all_all.pdf`.
> Note that the raw sign of the MFT results contains information about whether a system likes or dislikes the current spin order. So, at the second nearest (4.18 Å) between 1-2 spins, +6 meV means that current antiferromagnetic ordering is preferred.


The output at terminal would look like bellow:

```sh
 Checking the updated version ...
 Current version 1.0.1 is the newest version.
 DFTforge Version 1.0.1
Jx_postprocess started (julia Jx_postprocess.jl --help for inputs)
================ User input =============
baseatom => 1
cellvectors => 2_2_2
root_dir => jx.col.spin.wannier_0.0
orbital_name => all_all
atom2 => 1,2
================ Selected result *.jld2 files =============
jx.col.spin.wannier_0.0/jx.col.spin.wannier_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.jld2
jx.col.spin.wannier_0.0/jx.col.spin.wannier_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.jld2
================ Selected result *.jld2 files =============
(1, 2)atom_(i, j):(1, 2) global_xyz:([0.0, 0.0, 0.0] [4.18000019366829, 4.18000019366829, 4.18000019366829])
(1, 1)atom_(i, j):(1, 1) global_xyz:([0.0, 0.0, 0.0] [0.0, 0.0, 0.0])
================ Writing CSV & Plotfile  =============
 Writing CSV:jx.col.spin.wannier_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.csv
12×8 DataFrames.DataFrame
│ Row │ Distance │ JmeV       │ Rx    │ Ry    │ Rz    │ Dx          │ Dy          │ Dz          │
│     │ Float64  │ Float64    │ Int64 │ Int64 │ Int64 │ Float64     │ Float64     │ Float64     │
├─────┼──────────┼────────────┼───────┼───────┼───────┼─────────────┼─────────────┼─────────────┤
│ 1   │ 2.9557   │ -0.0502568 │ -1    │ -1    │ 0     │ -2.09       │ -2.09       │ -2.64589e-6 │
│ 2   │ 2.9557   │ -0.0501972 │ -1    │ 0     │ -1    │ -2.09       │ -2.64589e-6 │ -2.09       │
│ 3   │ 2.9557   │ -0.0501972 │ 0     │ -1    │ -1    │ -2.64589e-6 │ -2.09       │ -2.09       │
│ 4   │ 2.9557   │ -0.0501653 │ -1    │ 0     │ 0     │ 2.64589e-6  │ 2.09        │ 2.09        │
│ 5   │ 2.9557   │ -0.0501653 │ 0     │ -1    │ 0     │ 2.09        │ 2.64589e-6  │ 2.09        │
│ 6   │ 2.9557   │ -0.0502249 │ 0     │ 0     │ -1    │ 2.09        │ 2.09        │ 2.64589e-6  │
│ 7   │ 4.17999  │ 6.02982    │ -2    │ 0     │ 0     │ -4.17999    │ -2.64589e-6 │ -2.64589e-6 │
│ 8   │ 4.17999  │ 6.02982    │ 0     │ -2    │ 0     │ -2.64589e-6 │ -4.17999    │ -2.64589e-6 │
│ 9   │ 4.17999  │ 6.02954    │ 0     │ 0     │ -2    │ -2.64589e-6 │ -2.64589e-6 │ -4.17999    │
│ 10  │ 4.17999  │ 6.0283     │ -1    │ -1    │ 1     │ 2.64589e-6  │ 2.64589e-6  │ 4.17999     │
│ 11  │ 4.17999  │ 6.02858    │ -1    │ 1     │ -1    │ 2.64589e-6  │ 4.17999     │ 2.64589e-6  │
│ 12  │ 4.17999  │ 6.02858    │ 1     │ -1    │ -1    │ 4.17999     │ 2.64589e-6  │ 2.64589e-6  │
 Writing CSV:jx.col.spin.wannier_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.csv
12×8 DataFrames.DataFrame
│ Row │ Distance │ JmeV        │ Rx    │ Ry    │ Rz    │ Dx       │ Dy       │ Dz       │
│     │ Float64  │ Float64     │ Int64 │ Int64 │ Int64 │ Float64  │ Float64  │ Float64  │
├─────┼──────────┼─────────────┼───────┼───────┼───────┼──────────┼──────────┼──────────┤
│ 1   │ 2.9557   │ 0.0277095   │ -1    │ 0     │ 1     │ -2.09    │ 0.0      │ 2.09     │
│ 2   │ 2.9557   │ 0.0274556   │ -1    │ 1     │ 0     │ -2.09    │ 2.09     │ 0.0      │
│ 3   │ 2.9557   │ 0.0277095   │ 0     │ -1    │ 1     │ 0.0      │ -2.09    │ 2.09     │
│ 4   │ 2.9557   │ 0.0277095   │ 0     │ 1     │ -1    │ 0.0      │ 2.09     │ -2.09    │
│ 5   │ 2.9557   │ 0.0274556   │ 1     │ -1    │ 0     │ 2.09     │ -2.09    │ 0.0      │
│ 6   │ 2.9557   │ 0.0277095   │ 1     │ 0     │ -1    │ 2.09     │ 0.0      │ -2.09    │
│ 7   │ 5.11942  │ -0.00451954 │ -2    │ 1     │ 1     │ -4.17999 │ 2.09     │ 2.09     │
│ 8   │ 5.11942  │ -0.00451977 │ -1    │ -1    │ 2     │ -2.09    │ -2.09    │ 4.17999  │
│ 9   │ 5.11942  │ -0.00451936 │ -1    │ 2     │ -1    │ -2.09    │ 4.17999  │ -2.09    │
│ 10  │ 5.11942  │ -0.00451954 │ 1     │ -2    │ 1     │ 2.09     │ -4.17999 │ 2.09     │
│ 11  │ 5.11942  │ -0.00451995 │ 1     │ 1     │ -2    │ 2.09     │ 2.09     │ -4.17999 │
│ 12  │ 5.11942  │ -0.00451936 │ 2     │ -1    │ -1    │ 4.17999  │ -2.09    │ -2.09    │
 Writing Plot:Jplot_1_1,2_all_all.pdf
================ All done =============
```




<style>
.color-box-blue{
    background-color: blue;
    height: 5px
}
</style>

<html>
<div class="color-box-blue"></div>
</html>
## The files provided in the example script

###  `NiO.dat`



```bash
#
# Wannier function
#
Wannier.Func.Num          16

Wannier.Outer.Window.Bottom  -10 #-2.58 #-2.55
Wannier.Outer.Window.Top     +4.0 #2.3
Wannier.Inner.Window.Bottom  -6.0
Wannier.Inner.Window.Top      0.0
Wannier.Initial.Guess         on
Wannier.Initial.Projectors.Unit FRAC     # AU, ANG or FRAC

<Wannier.Initial.Projectors
Nipro-dz2     0.000  0.000  0.000   0 0 1   1 0 0
Nipro-dz2     0.500  0.500  0.500   0 0 1   1 0 0
Nipro-dx2-y2  0.000  0.000  0.000   0 0 1   1 0 0
Nipro-dx2-y2  0.500  0.500  0.500   0 0 1   1 0 0
Nipro-dxy     0.000  0.000  0.000   0 0 1   1 0 0
Nipro-dxy     0.500  0.500  0.500   0 0 1   1 0 0
Nipro-dxz     0.000  0.000  0.000   0 0 1   1 0 0
Nipro-dxz     0.500  0.500  0.500   0 0 1   1 0 0
Nipro-dyz     0.000  0.000  0.000   0 0 1   1 0 0
Nipro-dyz     0.500  0.500  0.500   0 0 1   1 0 0
Opro-px   0.250     0.250     0.250  0 0 1   1 0 0
Opro-px   0.750     0.750     0.750  0 0 1   1 0 0
Opro-py   0.250     0.250     0.250  0 0 1   1 0 0
Opro-py   0.750     0.750     0.750  0 0 1   1 0 0
Opro-pz   0.250     0.250     0.250  0 0 1   1 0 0
Opro-pz   0.750     0.750     0.750  0 0 1   1 0 0
Wannier.Initial.Projectors>

Wannier.Kgrid     8 8 8 #6 6 6 # 8 8 8
Wannier.MaxShells   12

Wannier.Interpolated.Bands              on   # on|off, default=off

Wannier.Function.Plot                   on   # on|off, default=off
Wannier.Function.Plot.SuperCells    1 1 1   # default=0 0 0

Wannier.Dis.Mixing.Para      0.9 #0.5
Wannier.Dis.Conv.Criterion   1e-11
Wannier.Dis.SCF.Max.Steps    24000

Wannier.Minimizing.Max.Steps    2000
Wannier.Minimizing.Scheme       2
Wannier.Minimizing.StepLength   1.0
Wannier.Minimizing.Secant.Steps         12
Wannier.Minimizing.Secant.StepLength    1.0
Wannier.Minimizing.Conv.Criterion       1e-6


Wannier.Readin.Overlap.Matrix            off
```

###  `nio_J_wannier.toml`

```toml
# This is DFT-forge TOML file
HamiltonianType = "OpenMXWannier" # OpenMX, OpenMXWannier, Wannier90
spintype = "co_spin" #Set Spin type, para, co_spin, nc_spin
result_file = "nio.HWR"
atom12 = [[1,1],[1,2]]

# k,q for calculation. Using the same k,q points number is recomended
k_point_num = [6,6,6]
q_point_num = [6,6,6]

[orbitals]
orbitalselection = true # true , false
orbital_mask1_list = [[1],[2],[3],[4],[5]]
orbital_mask2_list = [[1],[2],[3],[4],[5]]

orbital_mask1_names = "[dz2,dx2y2,dxy,dyz,dxz]"
orbital_mask2_names = "[dz2,dx2y2,dxy,dyz,dxz]"
[wannier_optional]
# atom position info dose not exists at OpenMX wannier
atomnum = 4
atompos = [[0.0, 0.0, 0.0],
        [0.5, 0.5, 0.5],
        [0.250, 0.250, 0.250],
        [0.750, 0.750, 0.750]]
atoms_orbitals_list = [[1,3,5,7,9],[2,4,6,8,10],[11,13,15],[12,14,16]]
```