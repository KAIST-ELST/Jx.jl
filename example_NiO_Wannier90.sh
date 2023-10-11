#!/bin/bash
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'


JX_ROOT=`pwd`

source ~/.profile # to add Julia to path
printf "${BLUE} 0. Unzip the example ${NC} \n"
printf "${BLUE} examples/NiO_G-AFM.OpenMx ${NC} \n"

cd "examples"

# Unzip Wannier90 result
tar -Jxvf NiO_G_AFM.vasp.Wannier90.tar.xz

cd "NiO_G_AFM.vasp.Wannier90/wannier90_Ni.d_O.p"
# obtain J(q) long excution 
printf "${BLUE} 1. Calculate J(q) ${NC} \n"
printf "${GREEN}   julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml ${NC} \n"
printf "${GREEN}   'julia --machine-file <file>' instead of 'julia -p 4' is also possible ${NC} \n"
sleep 2
#julia -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml
julia -p 4 $JX_ROOT/src/Jx_col_spin_exchange.jl  -T nio_J_wannier90.toml
                                              
# J(q) -> J(R) short post processing 
printf "${BLUE} 2. Transform J(q) -> J(Rij) ${NC} \n"

printf "${GREEN}   julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name eg_t2g  jx2.col.spin.wannier_0.0  ${NC} \n"
sleep 2
julia  $JX_ROOT/src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name eg_t2g jx2.col.spin.wannier_0.0

printf "${GREEN}   julia  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name eg_eg  jx2.col.spin.wannier_0.0  ${NC} \n"
sleep 2
julia  $JX_ROOT/src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name eg_eg jx2.col.spin.wannier_0.0
