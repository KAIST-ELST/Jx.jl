echo " 0. Unzip the example \n"
echo " examples/NiO_G-AFM_U0.OpenMx  \n"

cd "examples/NiO_G-AFM.OpenMx"
tar xvf nio_dft_result.tar.gz
timeout 2

cd "../../"
echo "1. Calculate J(q) ${NC} \n"
echo "  julia.exe -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM_U0.OpenMx/nio_J_openmx.toml"
echo "  julia.exe --machine-file <file>' instead of 'julia -p 4' is also possible"
timeout 2
C:/Users/bluehope/AppData/Local/Julia-1.2.0/bin/julia.exe -p 4 src/Jx_col_spin_exchange.jl  -T examples/NiO_G-AFM.OpenMx/nio_J_openmx.toml


echo "2. Transform J(q) -> J(Rij)"
echo "  julia.exe  src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all  examples/NiO_G-AFM_U0.OpenMx/jx.col.spin_0.0"
timeout 2
C:/Users/bluehope/AppData/Local/Julia-1.2.0/bin/julia.exe src/Jx_postprocess.jl --cellvectors  2_2_2 --baseatom1 1 --atom2 1,2 --orbital_name all_all  examples/NiO_G-AFM.OpenMx/jx.col.spin_0.0
