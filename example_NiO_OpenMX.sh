#!/usr/bin/env bash
cd "examples/NiO_G-AFM.OpenMx"

# Unzip dft result 
# nio.scf : OpenMX full Hamiltonian info
# nio.HWR : Wannier Hamiltonian from OpenMX
tar xvf nio_dft_result.tar.xz
# obtain J(q)
julia -p 4 ~/.julia/v0.6/DFTforge/src/Jx_col_spin_exchange.jl  -T nio_J_openmx.toml
# J(q) -> J(R)
julia ~/.julia/v0.6/DFTforge/src/Jx_postprocess.jl --cellvectors  3_3_3 --atom12 1_1,1_2  --orbital_name all_all --baseatom 1 jq.col.spin_0.0

