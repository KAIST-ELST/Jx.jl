---
layout: single #splash #single
author_profile: false
title: "NiO Wannier90 example"
classes: wide


toc: true
toc_label: "NiO (Wannier90) example"
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

This is the example of a G-type ordered NiO with Wannier90.
In the primitive cell, two spins have different up, down the order.
After Wannier Hamiltonian is constructed, the MFT calculation procedures consist of two-step processes of [calculating J(q)](#jq-calculation) and [converting J(q) to J(R)](#jq-jr-transformation).

> Before MFT calculation, it is STRONGLY recommended to compare the Wannier band with the original DFT band structure. Especially for the metallic systems, a small difference near the Fermi level could significantly impact linear response calculations.

## The required files for Jx MFT calculation (with Wannier90)

The required files for MFT calculation: Wannier90 Hamiltonian files and toml input files.
> - Wannier90 Hamiltonian files  (`wannier90.up_hr.dat`, `wannier90.dn_hr.dat`) 
> - [Wannier90 info files (`wannier90.up.win`, `wannier90.dn.win`)](#wannier90-infofile)
> - [The *Jx* input file `*.toml`](#nio_J_wannier90.toml)

The important tasks are to write `feremi_energy` in `Wannier90 info` and num of atoms, atom position, orbital info in the `input toml` file.


## J(q) calculation

```bash
cd examples/NiO_G_AFM.Wannier90.example
```

```bash
julia -p 4 src/Jx_col_spin_exchange.jl  -T nio_J_wannier90.toml
```

This is the main MFT procedure. 
This is the most time-consuming part.
For MFT with Wannier Hamiltonians, the output path is `jx2.col.spin.wannier_0.0` (not `jx2.col.spin_0.0`),
 and inside the output path following files 
 `jx2.col.spin.wannier_wannier90_atomij_1_1_atom1m_[,]_atom2m_[,]_[eg_eg__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_1_atom1m_[,]_atom2m_[,]_[eg_t2g__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_1_atom1m_[,]_atom2m_[,]_[t2g_eg__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_1_atom1m_[,]_atom2m_[,]_[t2g_t2g__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_2_atom1m_[,]_atom2m_[,]_[eg_eg__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_2_atom1m_[,]_atom2m_[,]_[eg_t2g__all__all]_ChemPdelta_0.0.jld2`,
`jx2.col.spin.wannier_wannier90_atomij_1_2_atom1m_[,]_atom2m_[,]_[t2g_eg__all__all]_ChemPdelta_0.0.jld2`, `jx2.col.spin.wannier_wannier90_atomij_1_2_atom1m_[,]_atom2m_[,]_[t2g_t2g__all__all]_ChemPdelta_0.0.jld2`
  will be generated.


> The parallel option can be given by `-p #of cpu core` or `--machine-file #PBS_NODES`. See [Julia parallel computing](https://docs.julialang.org/en/v1/manual/parallel-computing/#Starting-and-managing-worker-processes-1) for detailed options.

## J(q)->J(R) transformation
```bash
julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom 1 --atom2 1,2 --orbital_name eg_eg  jx2.col.spin.wannier_0.0
```

The output files are `jx.col.spin.wannier_nio_atomij_1_1_[eg_eg]_ChemPdelta_0.0.csv`
`jx.col.spin.wannier_nio_atomij_1_2_[eg_eg]_ChemPdelta_0.0.csv` and the ploted image `Jplot_1_1,2_eg_eg.pdf`.
> Note that the raw sign of the MFT results contains information about whether a system likes or dislikes the current spin order. So, at the second nearest (4.18 Å) between 1-2 spins, +6 meV means that current antiferromagnetic ordering is preferred.


The other orbitals interaction can be plotted by changing `orbital_name` options as follows `--orbital_name eg_t2g`, `--orbital_name t2g_t2g`, `--orbital_name t2g_eg`.

<style>
.color-box-blue{
    background-color: blue;
    height: 5px
}
</style>

<html>
<div class="color-box-blue"></div>
</html>
## The files provided in the example


### Wannier90 infofile
 
 * The `fermi_energy` MUST be set for BOTH `wannier90.dn.win` and `wannier90.up.win` files from the DTF result.




```toml
num_bands =    32  ! set to NBANDS by VASP
num_wann =     16  ! # user setting

! use_bloch_phases = T

begin unit_cell_cart
     4.1700000     2.0850000     2.0850000
     2.0850000     4.1700000     2.0850000
     2.0850000     2.0850000     4.1700000
end unit_cell_cart

begin atoms_cart
Ni       0.0000000     0.0000000     0.0000000
Ni       4.1700000     4.1700000     4.1700000
O        2.0850000     2.0850000     2.0850000
O        6.2550000     6.2550000     6.2550000
end atoms_cart

###### writing hamiltonian ######
write_hr = .true.
###############################

###### fermi energy  ##########
fermi_energy = 6.21888783      # <- MUST BE UPDATED FOR EACH SYSTEMS
###############################



###### Energy windows #########
dis_win_min =  -4.0 !-3.0
dis_win_max =  10.0
dis_froz_min =  5.3 !8.0 !5.2
dis_froz_max =  6.3 !9.9
###############################
```

###  `nio_J_wannier90.toml`

 * The `atomnum`, `atompos`, `atoms_orbitals_list` must be updated for each different system.

```toml
HamiltonianType = "Wannier90"
spintype = "co_spin"        #Set Spin type, para, co_spin, nc_spin

# wannier90.up.win, wannier90.up_hr.dat // wannier90.dn.win, wannier90.dn_hr.dat files are required.
result_file = ["wannier90.up","wannier90.dn"]

atom12 = [[1,1],[1,2]]


k_point_num = [10,10,10]
q_point_num = [10,10,10]

[orbitals]
orbitalselection = true # true , false
orbital_mask1_list = [[1,4],[2,3,5]]
orbital_mask2_list = [[1,4],[2,3,5]]

orbital_mask1_names = "[eg,t2g]"
orbital_mask2_names = "[eg,t2g]"

# For d-orbital index see
# http://www.wannier.org/doc/user_guide.pdf
#orbital_mask1_list = [[1],[2],[3],[4],[5]]
#orbital_mask2_list = [[1],[2],[3],[4],[5]]

#orbital_mask1_names = "[dz2,dxz,dyz,dx2y2,dxy]"
#orbital_mask2_names = "[dz2,dxz,dyz,dx2y2,dxy]"
[wannier_optional]
# atom position info dose not exists at OpenMX wannier
atomnum = 4
# atompos in fractional coordinate
atompos = [[0.0, 0.0, 0.0],          # atom1 Ni1
        [0.5, 0.5, 0.5],             # atom2 Ni2
        [0.250, 0.250, 0.250],       # atom3 O1
        [0.750, 0.750, 0.750]]       # atom4 O2

# orbital indexes for each atoms
atoms_orbitals_list = [[1,2,3,4,5], # atom1 Ni1 d orbitals
        [6,7,8,9,10],               # atom2 Ni2 d orbitals
        [11,12,13],                 # atom3 O1 p orbitals
        [14,15,16]]                 # atom4 O2 p orbitals

```