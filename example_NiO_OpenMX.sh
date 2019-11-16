#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'


source ~/.profile # to add Julia to path
printf "${BLUE} 0. Unzip the example ${NC} \n"
printf "${BLUE} examples/NiO_G-AFM_U0.OpenMx ${NC} \n"

cd "examples/NiO_G-AFM.OpenMx"

# Unzip dft result
# nio.scf : OpenMX full Hamiltonian info
# nio.HWR : Wannier Hamiltonian from OpenMX
tar xvf nio_dft_result.tar.xz

cd "../../"
# obtain J(q)
printf "${BLUE} 1. Calculate J(q) ${NC} \n"
printf "${GREEN}   julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml ${NC} \n"
printf "${GREEN}   'julia --machine-file <file>' instead of 'julia -p 4' is also possible ${NC} \n"
sleep 2
#julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml
julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml
# J(q) -> J(R)
printf "${BLUE} 2. Transform J(q) -> J(Rij) ${NC} \n"
printf "${GREEN}   julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all  examples/NiO_G-AFM.OpenMx/jx.col.spin_0.0 ${NC} \n"
sleep 2
julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all examples/NiO_G-AFM.OpenMx/jx.col.spin_0.0
