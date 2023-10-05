---
layout: single #splash #single
author_profile: false
title: "NiO (OpenMX full Hamiltonian) example"
classes: wide


toc: true
toc_label: "NiO example"
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

This is the NiO with OpenMX example.
After the electronic structure is given,
the MFT calculation procedures consist of two processes process of [calculating J(q)](#jq-calculation) and [converting J(q) to J(R)](#jq-jr-transformation).

## The required files for Jx MFT calculation (with OpenMX)

> - [OpenMX result Hamiltonian file `*.scfout`](#niodat)
> - [The *Jx* input file `*.toml`](#nio_j_openmxtoml)

These files are provided in the following example script.

## Automated script

Run following [script](#example_nio_openmxsh):

```
./example_NiO_OpenMX.sh
```
1. It will automatically unzip pre calculated [OpenMX](openmx-square.org) Hamilton file `NiO.scfout` and *Jx* input `nio_J_openmx.toml` at `examples/NiO_G-AFM.OpenMx/`.
2. Than, *Jx* will perform *J(q)* calculation (The most time-consuming part. Roughly 5-10 min depending on CPU).
3. After *J(q)* calculation done, the *J(q)* -> *J(R)* transformation will run.

----

## J(q) calculation

```bash
julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml
```

This is the main MFT procedure. 
This is the most time-consuming part.
The output path is  `jx2.col.spin_0.0` and inside the output path two files `jx2.col.spin_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.jld2`,`jx2.col.spin_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.jld2` will be generated.

> The parallel option can be given by `-p #of cpu core` or `--machine-file #PBS_NODES`. See [Julia parallel computing](https://docs.julialang.org/en/v1/manual/parallel-computing/#Starting-and-managing-worker-processes-1) for detailed options.

## J(q)->J(R) transformation

```bash
julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all  examples/NiO_G-AFM.OpenMx/jx2.col.spin_0.0
```

For MFT with Wannier Hamiltonians, the output path is  `jx2.col.spin_0.0`.
The output files are `jx2.col.spin.wannier_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.csv`
`jx2.col.spin.wannier_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.csv` and the ploted image `Jplot_1_1,2_all_all.pdf`.
> Note that the raw sign of the MFT results contains information about whether a system likes or dislikes the current spin order. So, at the second nearest (4.18 Å) between 1-2 spins, +8.5 meV means that current antiferromagnetic ordering is preferred.


```sh
 DFTforge Version 1.3.2
Jx_postprocess started (julia Jx_postprocess.jl --help for inputs)
================ User input =============
cellvectors => 2_2_2
baseatom1 => 1
root_dir => jx2.col.spin_0.0
orbital_name => all_all
atom2 => 1,2
================ Selected result *.jld2 files =============
jx2.col.spin_0.0/jx2.col.spin_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.jld2
jx2.col.spin_0.0/jx2.col.spin_nio_atomij_1_2_[all_all]_ChemPdelta_0.0.jld2
================ Selected result *.jld2 files =============
[0.0 0.0 0.0; 4.1799999990685945 4.1799999990685945 4.1799999990685945; 2.0899999995342973 2.0899999995342973 2.0899999995342973; 6.269999998602892 6.269999998602892 6.269999998602892]
(1, 2)atom_(i, j):(1, 2) global_xyz:([0.0, 0.0, 0.0] [4.1799999990685945, 4.1799999990685945, 4.1799999990685945])
(1, 1)atom_(i, j):(1, 1) global_xyz:([0.0, 0.0, 0.0] [0.0, 0.0, 0.0])
================ Writing CSV & Plotfile  =============
2 2
 Writing CSV:jx2.col.spin_nio_atomij_1_2_[all_all]_ChemPdelta_0.0__1.csv
12×10 DataFrame
 Row │ Distance  JmeV       Atom1  Atom2  Rx     Ry     Rz     Dx            Dy            Dz
     │ Float64   Float64    Int64  Int64  Int64  Int64  Int64  Float64       Float64       Float64
─────┼─────────────────────────────────────────────────────────────────────────────────────────────
   1 │  2.95571  -0.238341      1      2     -1     -1      0  -2.09         -2.09            0.0
   2 │  2.95571  -0.238341      1      2     -1      0     -1  -2.09          0.0            -2.09
   3 │  2.95571  -0.238341      1      2      0     -1     -1   0.0          -2.09           -2.09
   4 │  2.95571  -0.238341      1      2     -1      0      0   0.0           2.09            2.09
   5 │  2.95571  -0.238341      1      2      0     -1      0   2.09          0.0             2.09
   6 │  2.95571  -0.238341      1      2      0      0     -1   2.09          2.09            0.0
   7 │  4.18      8.54461       1      2     -2      0      0  -4.18          0.0             0.0
   8 │  4.18      8.5446        1      2     -1     -1      1   8.88178e-16   8.88178e-16     4.18
   9 │  4.18      8.54461       1      2     -1      1     -1   0.0           4.18            0.0
  10 │  4.18      8.54461       1      2      0     -2      0   0.0          -4.18            0.0
  11 │  4.18      8.5446        1      2      0      0     -2   0.0           0.0            -4.18
  12 │  4.18      8.54461       1      2      1     -1     -1   4.18          0.0             0.0
 Writing CSV:jx2.col.spin_nio_atomij_1_1_[all_all]_ChemPdelta_0.0.csv
12×10 DataFrame
 Row │ Distance  JmeV        Atom1  Atom2  Rx     Ry     Rz     Dx       Dy       Dz
     │ Float64   Float64     Int64  Int64  Int64  Int64  Int64  Float64  Float64  Float64
─────┼────────────────────────────────────────────────────────────────────────────────────
   1 │  2.95571  0.160754        1      1     -1      0      1    -2.09     0.0      2.09
   2 │  2.95571  0.160753        1      1     -1      1      0    -2.09     2.09     0.0
   3 │  2.95571  0.160754        1      1      0     -1      1     0.0     -2.09     2.09
   4 │  2.95571  0.160754        1      1      0      1     -1     0.0      2.09    -2.09
   5 │  2.95571  0.160753        1      1      1     -1      0     2.09    -2.09     0.0
   6 │  2.95571  0.160754        1      1      1      0     -1     2.09     0.0     -2.09
   7 │  5.11943  0.00673793      1      1     -2      1      1    -4.18     2.09     2.09
   8 │  5.11943  0.00673793      1      1     -1      2     -1    -2.09     4.18    -2.09
   9 │  5.11943  0.00673793      1      1      1     -2      1     2.09    -4.18     2.09
  10 │  5.11943  0.00673793      1      1      2     -1     -1     4.18    -2.09    -2.09
  11 │  5.11943  0.00673793      1      1     -1     -1      2    -2.09    -2.09     4.18
  12 │  5.11943  0.00624584      1      1     -1      0      0    -4.18    -2.09    -2.09
 Writing Plot:Jplot_1_1,2_all_all.pdf
 Writing Plot:Jplot_1_1,2_all_all.svg
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
# output Hamiltonian and overlap
#
HS.fileout                   on        # on|off, default=off
```

###  `nio_J_openmx.toml`

```toml
# This is DFT-forge TOML file
HamiltonianType = "OpenMX" # OpenMX, OpenMXWannier, Wannier90
spintype = "co_spin" #Set Spin type, para, co_spin, nc_spin
result_file = "nio.scfout"
atom12 = [[1,1],[1,2]]


# k,q for calculation. Using the same k,q points number is recomended
k_point_num = [6,6,6]
q_point_num = [6,6,6]

[orbitals]

##################################################################################################
#In OpenMX inputfile NiO.dat
#<Definition.of.Atomic.Species
#Ni     Ni6.0S-s2p2d2f1  Ni_PBE13S
##################################################################################################
# s2p2d2f1 represent 2 s orbitals, 2 p orbitals, 2 d orbitals, and 1 f orbital for the Ni.
# Therefore, orbital indexs 1,2 standsfor s1, s2
# 3,4,5: p1   5,6,7: p2
# 9,10,11,12,13: d1 14,15,16,17,18: d2
# 19,20,21,22,23,24,25: f1
#
# If we want to calculate the interaction between d orbitals of Ni,
# you can choose [9-13] orbital.
# Each orbital index names is as follows:
# 9:dz2, 10:dx2y2, 11:dxy, 12:dyz, 13:dxz
# You can check it through nio.out file.
##################################################################################################

orbitalselection = false # true,false
orbital_mask1_list = [[9],[10],[11],[12],[13]]
orbital_mask2_list = [[9],[10],[11],[12],[13]]

orbital_mask1_names = "[dz2,dx2y2,dxy,dxz,dyz]"
orbital_mask2_names = "[dz2,dx2y2,dxy,dxz,dyz]"
```

###  `./example_NiO_OpenMX.sh`:

```bash
#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'


JX_ROOT=`pwd`
source ~/.profile # to add Julia to path
printf "${BLUE} 0. Unzip the example ${NC} \n"
printf "${BLUE} examples/NiO_G-AFM.OpenMx ${NC} \n"

cd "examples/NiO_G-AFM.OpenMx"

# Unzip dft result
# nio.scf : OpenMX full Hamiltonian info
# nio.HWR : Wannier Hamiltonian from OpenMX
tar xvf nio_dft_result.tar.gz

# cd "../../"
# obtain J(q) long excution
printf "${BLUE} 1. Calculate J(q) ${NC} \n"
printf "${GREEN}   julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml ${NC} \n"
printf "${GREEN}   'julia --machine-file <file>' instead of 'julia -p 4' is also possible ${NC} \n"
sleep 2
#julia -p 4 src/Jx_col_spin_exchange.jl  -T nio_J_openmx.toml
julia -p 4 $JX_ROOT/src/Jx_col_spin_exchange.jl  -T nio_J_openmx.toml

# J(q) -> J(R) short post processing
printf "${BLUE} 2. Transform J(q) -> J(Rij) ${NC} \n"
printf "${GREEN}   julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all  examples/NiO_G-AFM.OpenMx/jx2.col.spin_0.0 ${NC} \n"
sleep 2
julia  $JX_ROOT/src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all jx2.col.spin_0.0
```
