###############################################################################
# Hongkee Yoon Hongkeeyoon@kaist.ac.kr
# 2019.05
# https://kaist-elst.github.io/DFTforge.jl/
###############################################################################
# [PhysRevB.97.125132](https://doi.org/10.1103/PhysRevB.97.125132)

#using ProgressMeter
__precompile__(true)
X_VERSION = VersionNumber("0.9.5-pub+20200623");
println(" JX_VERSION: ",X_VERSION)
println(" Visit https://kaist-elst.github.io/DFTforge.jl/ for details & updates ")
println(" Tested with Julia v1.0 and v1.4 which the most recent version of Julia in 202006 https://julialang.org/")

using Distributed
import DFTforge
using DFTforge.DFTrefinery
using DFTforge.DFTcommon;
# Julia 1.0
using Statistics
#


@everywhere using Distributed
@everywhere import DFTforge
@everywhere using DFTforge.DFTrefinery
@everywhere using DFTforge.DFTcommon
##############################################################################
## 1. Read INPUT
## 1.1 Set Default values
## 1.2 Read input from argument & TOML file
## 1.3 Set values from intput (arg_input)
## 1.4 Set caluations type and ouput folder
##############################################################################

hdftmpdir = ""
## 1.1 Set Default values
#orbital_selection1 = Array{Int64,1}();
#orbital_selection2 = Array{Int64,1}();
orbital_selection1_list = Array{Array{Int}}(undef,0);
orbital_selection1_names = Array{AbstractString}(undef,0);
orbital_selection2_list = Array{Array{Int}}(undef,0);
orbital_selection2_names = Array{AbstractString}(undef,0);

orbital_selection3_list = Array{Array{Int}}(undef,0);
orbital_selection3_names = Array{AbstractString}(undef,0);
orbital_selection4_list = Array{Array{Int}}(undef,0);
orbital_selection4_names = Array{AbstractString}(undef,0);

orbital_selection_option = DFTcommon.nomask;
orbital_selection_on = false;

band_selection_on = false;
band_selection_upper = 0;
band_selection_lower = 0;

k_point_num = [3,3,3]
q_point_num = [3,3,3]
ChemP_delta_ev = 0.0
DFT_type = DFTcommon.OpenMX

## 1.2 Read input from argument & TOML file
arg_input = DFTcommon.Arg_Inputs();
arg_input = parse_input(ARGS,arg_input)
#arg_input.TOMLinput = "nio_J_wannier.toml" # Debug
#arg_input.TOMLinput = "nio_J_openmx.toml" # Debug
arg_input = parse_TOML(arg_input.TOMLinput,arg_input)
# let argument override
arg_input = parse_input(ARGS,arg_input)

## 1.3 Set values from intput (arg_input)
DFT_type = arg_input.DFT_type
Wannier90_type = arg_input.Wannier90_type
spin_type = arg_input.spin_type

result_file = arg_input.result_file
result_file_dict = arg_input.result_file_dict;

ChemP_delta_ev = arg_input.ChemP_delta_ev
 # k,q point num
k_point_num = arg_input.k_point_num
q_point_num = arg_input.q_point_num
 # atom 12
#atom1 = arg_input.atom1;
#atom2 = arg_input.atom2;
atom12_list = arg_input.atom12_list;
hdftmpdir = arg_input.hdftmpdir;

# orbital mask
orbital_selection_option = arg_input.orbital_selection_option;

orbital_selection1_list = arg_input.orbital_selection1_list;
orbital_selection1_names = arg_input.orbital_selection1_names;
orbital_selection2_list = arg_input.orbital_selection2_list;
orbital_selection2_names = arg_input.orbital_selection2_names;

orbital_selection3_list = arg_input.orbital_selection3_list;
orbital_selection3_names = arg_input.orbital_selection3_names;
orbital_selection4_list = arg_input.orbital_selection4_list;
orbital_selection4_names = arg_input.orbital_selection4_names;

println(orbital_selection1_list," ",orbital_selection1_names)
println(orbital_selection2_list," ",orbital_selection2_names)
println(orbital_selection3_list," ",orbital_selection3_names)
println(orbital_selection4_list," ",orbital_selection4_names)
@assert(length(orbital_selection1_list) == length(orbital_selection1_names));
@assert(length(orbital_selection2_list) == length(orbital_selection2_names));
@assert(length(orbital_selection3_list) == length(orbital_selection3_names));
@assert(length(orbital_selection4_list) == length(orbital_selection4_names));
# Band selection
if haskey(arg_input.Optional,"band_selection")
  band_selection_on =  arg_input.Optional["band_selection"]
  band_selection_lower =  arg_input.Optional["band_selection_boundary"][1]
  band_selection_upper =  arg_input.Optional["band_selection_boundary"][2]
end

if ((DFTcommon.unmask == orbital_selection_option) || (DFTcommon.mask == orbital_selection_option) )
 #orbital_selection_name = arg_input.orbital_selection_name
 orbital_selection_on = true
end

# Energy windows selection
energywindow_all_list = Array{Array{Float64,1},1}()
energywindow_1_list = Array{Array{Float64,1},1}()
energywindow_2_list = Array{Array{Float64,1},1}()
energywindow_3_list = Array{Array{Float64,1},1}()
energywindow_4_list = Array{Array{Float64,1},1}()
println(DFTcommon.bar_string) # print ====...====
println("energy windows")

if haskey(arg_input.Optional,"energywindow")
  energywindow_all_list = arg_input.Optional["energywindow"]["energywindow_all_list"]
  energywindow_1_list  = arg_input.Optional["energywindow"]["energywindow_1_list"]
  energywindow_2_list  = arg_input.Optional["energywindow"]["energywindow_2_list"]
  energywindow_3_list  = arg_input.Optional["energywindow"]["energywindow_3_list"]
  energywindow_4_list  = arg_input.Optional["energywindow"]["energywindow_4_list"]
  energywindow_name = arg_input.Optional["energywindow"]["energywindow_name"]
  println("energywindow_name: ",energywindow_name)
end
println("energywindow_all_list: ", energywindow_all_list)
println("energywindow_1_list: ", energywindow_1_list)
println("energywindow_2_list: ", energywindow_2_list)
println("energywindow_3_list: ", energywindow_3_list)
println("energywindow_4_list: ", energywindow_4_list)

# orbital orbital_reassign
basisTransform_rule = basisTransform_rule_type()
if haskey(arg_input.Optional,"basisTransform")
  basisTransform_rule = arg_input.Optional["basisTransform"]
end

println(DFTcommon.bar_string) # print ====...====
println("atom12_list: ",atom12_list)
println("q_point_num ",q_point_num, "\tk_point_num ",k_point_num)
println(string("DFT_type ",DFT_type))
println(string("orbital_selection_option ",orbital_selection_option))
println("mask1list ",orbital_selection1_list,"\tmask2list ",orbital_selection2_list)
println("basisTransform", basisTransform_rule)


cal_type = "jx.col.spin" # xq, ...
## 1.4 Set caluations type and ouput folder
if haskey(arg_input.Optional,"energywindow")
    energywindow_name = arg_input.Optional["energywindow"]["energywindow_name"]
    cal_type = string(cal_type,".Erange_",energywindow_name);
end

if (DFTcommon.Wannier90 == DFT_type)
  cal_type = string(cal_type,".wannier")
end
root_dir = dirname(result_file)
result_file_only = splitext(basename(result_file))
cal_name = result_file_only[1];
jq_output_dir =  joinpath(root_dir,string(cal_type,"_" ,ChemP_delta_ev))
if (!isdir(jq_output_dir))
  mkdir(jq_output_dir)
end
if ("" == hdftmpdir || !isdir(hdftmpdir) )
  hdftmpdir = jq_output_dir
end
hdf_cache_name = joinpath(hdftmpdir,string(cal_name,".hdf5"))
println(hdf_cache_name)
println(DFTcommon.bar_string) # print ====...====
##############################################################################
## 2. Calculate & Store k,q points information
## 2.1 Set Input info
## 2.2 Generate k,q points
## 2.3 Calculate Eigenstate & Store Eigenstate into file in HDF5 format
## 2.4 Send Eigenstate info to child processes
##############################################################################

## 2.1 Set Input info
hamiltonian_info = [];
if (DFTcommon.OpenMX == DFT_type || DFTcommon.EcalJ == DFT_type)
  hamiltonian_info = set_current_dftdataset(result_file,result_file_dict, DFT_type, spin_type,basisTransform_rule)
elseif (DFTcommon.Wannier90 == DFT_type)
  atomnum = arg_input.Wannier_Optional_Info.atomnum
  atompos = arg_input.Wannier_Optional_Info.atompos
  atoms_orbitals_list = arg_input.Wannier_Optional_Info.atoms_orbitals_list

  #hamiltonian_info = DFTforge.read_dftresult(result_file,DFT_type,Wannier90_type,atoms_orbitals_list,atomnum,atompos,basisTransform_rule)
  hamiltonian_info = set_current_dftdataset(result_file,result_file_dict,
  DFT_type,Wannier90_type,spin_type,atoms_orbitals_list,atomnum,atompos,basisTransform_rule)
  #hamiltonian_info = set_current_dftdataset(scf_r, DFT_type, spin_type,basisTransform_rule)
elseif (DFTcommon.PlainwaveLobster == DFT_type)
  print("PlainwaveLobster")
  atomnum = arg_input.Wannier_Optional_Info.atomnum
  atompos = arg_input.Wannier_Optional_Info.atompos
  tv  = arg_input.Optional["tv"]
  optionalInfo = Dict{AbstractString,Any}()
  optionalInfo["tv"] = tv
  optionalInfo["atomnum"] = atomnum
  optionalInfo["atompos"] = atompos
  optionalInfo["ChemP"] = arg_input.Optional["ChemP"]
  println(tv)
  hamiltonian_info = set_current_dftdataset(result_file, result_file_dict, DFT_type, spin_type,basisTransform_rule,optionalInfo)
end

DFTforge.pwork(set_current_dftdataset,(hamiltonian_info, 1));

## 2.2 Generate k,q points
k_point_list = kPoint_gen_GammaCenter(k_point_num);
q_point_list = kPoint_gen_GammaCenter(q_point_num);

#k_point_list = kPoint_gen_EquallySpaced(k_point_num);
#q_point_list = kPoint_gen_EquallySpaced(q_point_num);

(kq_point_list,kq_point_int_list) = q_k_unique_points(q_point_list,k_point_list)
println(string(" kq_point_list ",length(kq_point_list)))
println(string(" q point ",length(q_point_list) ," k point ",length(k_point_list)))

## 2.3 Calculate Eigenstate & Store Eigenstate into file in HDF5 format
eigenstate_cache = cachecal_all_Qpoint_eigenstats(kq_point_list,hdf_cache_name);
GC.gc();

## 2.4 Send Eigenstate info to child processes
DFTforge.pwork(cacheset,eigenstate_cache)
#tic();
@time DFTforge.pwork(cacheread_lampup,kq_point_list)
#toc();
################################################################################

##############################################################################
## 3. Setup extra infos (orbital, chemp shift)
##############################################################################
@everywhere function init_orbital_selection(orbital_selection_input::orbital_selection_input_Type)
    global orbital_selection1,orbital_selection2,orbital_selection_on
    global orbital_selection3,orbital_selection4
    global orbital_selection1 = Array{Int64,1}();
    global orbital_selection2 = Array{Int64,1}();

    global orbital_selection3 = Array{Int64,1}();
    global orbital_selection4 = Array{Int64,1}();
    if (orbital_selection_input.orbital_selection_on)
        global orbital_selection1 = orbital_selection_input.orbital_selection1;
        global orbital_selection2 = orbital_selection_input.orbital_selection2;

        global orbital_selection3 = orbital_selection_input.orbital_selection3;
        global orbital_selection4 = orbital_selection_input.orbital_selection4;
        global orbital_selection_on = true;
    else
        global orbital_selection_on = false;
    end
    #println(orbital_selection1)
end
@everywhere function init_variables(Input_ChemP_delta_ev ,Input_band_selection_on, Input_band_selection_lower, Input_band_selection_upper,
    energywindow_all1234_list)
  global ChemP_delta_ev, band_selection_on, band_selection_lower, band_selection_upper;
  global energywindow_all_list, energywindow_1_list, energywindow_2_list, energywindow_3_list, energywindow_4_list
  ChemP_delta_ev = Input_ChemP_delta_ev;
  band_selection_on = Input_band_selection_on;
  band_selection_lower = Input_band_selection_lower;
  band_selection_upper = Input_band_selection_upper;

  energywindow_all_list = energywindow_all1234_list[1]
  energywindow_1_list = energywindow_all1234_list[2]
  energywindow_2_list = energywindow_all1234_list[3]
  energywindow_3_list = energywindow_all1234_list[4]
  energywindow_4_list = energywindow_all1234_list[5]
end


##############################################################################
## Physical properties calculation define section
## 4. Magnetic exchange function define
## 4.1 Do K,Q sum
## 4.2 reduce K,Q to Q space
##############################################################################
## %%
## 4. Magnetic exchange function define
num_return = 8; #local scope

@everywhere function Magnetic_Exchange_J_colinear(input::Job_input_kq_atom_list_Type)
  global orbital_selection1,orbital_selection2,orbital_selection_on
  global orbital_selection3,orbital_selection4
  global ChemP_delta_ev, band_selection_on, band_selection_lower, band_selection_upper;
  global energywindow_all_list, energywindow_1_list, energywindow_2_list, energywindow_3_list, energywindow_4_list;
  #global SmallHks;
  ############################################################################
  ## Accessing Data Start
  ############################################################################
  # Common input info
  num_return = 8;
  k_point::DFTforge.k_point_Tuple =  input.k_point
  kq_point::DFTforge.k_point_Tuple =  input.kq_point
  spin_type::DFTforge.SPINtype = input.spin_type;

  atom12_list::Vector{Tuple{Int64,Int64}} = input.atom12_list;
  result_mat = zeros(Complex_my,num_return,length(atom12_list))
  #atom1::Int = input.atom1;
  #atom2::Int = input.atom2;

  result_index::Int = input.result_index;
  cache_index::Int = input.cache_index;

  # Get Chemp, E_temp
  TotalOrbitalNum = cacheread(cache_index).TotalOrbitalNum;
  TotalOrbitalNum2 = TotalOrbitalNum;
  if (DFTcommon.non_colinear_type == spin_type)
    TotalOrbitalNum2 = 2*TotalOrbitalNum;
  end

  ChemP = get_dftdataset(result_index).scf_r.ChemP + ChemP_delta_ev;
  E_temp = get_dftdataset(result_index).scf_r.E_Temp;

  # Get EigenState
  eigenstate_k_up::Kpoint_eigenstate_only  = cacheread_eigenstate(k_point,1,cache_index)
  eigenstate_kq_up::Kpoint_eigenstate_only = cacheread_eigenstate(kq_point,1,cache_index)
  eigenstate_k_down::Kpoint_eigenstate_only  = cacheread_eigenstate(k_point,2,cache_index)
  eigenstate_kq_down::Kpoint_eigenstate_only = cacheread_eigenstate(kq_point,2,cache_index)

  # Get Hamiltonian
# #=
  Hks_k_up::Hamiltonian_type  = cacheread_Hamiltonian(k_point,1,cache_index)
  Hks_kq_up::Hamiltonian_type  = cacheread_Hamiltonian(kq_point,1,cache_index)
  Hks_k_down::Hamiltonian_type = cacheread_Hamiltonian(k_point,2,cache_index)
  Hks_kq_down::Hamiltonian_type = cacheread_Hamiltonian(kq_point,2,cache_index)
# =#
  (orbitalStartIdx_list,orbitalNums) = cacheread_atomsOrbital_lists(cache_index)

  En_k_up::Array{Float_my,1} = eigenstate_k_up.Eigenvalues;
  Em_kq_up::Array{Float_my,1} = eigenstate_kq_up.Eigenvalues;
  En_k_down::Array{Float_my,1} = eigenstate_k_down.Eigenvalues;
  Em_kq_down::Array{Float_my,1} = eigenstate_kq_down.Eigenvalues;

  # enegy eigenvalue could be smaller than TotalOrbitalNum2 (orbital number)
  energy_idx_num_k_up = length(En_k_up);
  energy_idx_num_kq_up = length(Em_kq_up);
  energy_idx_num_k_dn = length(En_k_down);
  energy_idx_num_kq_dn = length(Em_kq_down);

  #[Orbital index, Energy index]

  Es_n_k_up::Array{Complex_my,2} = eigenstate_k_up.Eigenstate;       # [TotalOrbitalNum2, energy_idx_num_k_up]
  Es_m_kq_up::Array{Complex_my,2} = eigenstate_kq_up.Eigenstate;     # [TotalOrbitalNum2, energy_idx_num_kq_up]
  Es_n_k_down::Array{Complex_my,2} = eigenstate_k_down.Eigenstate;   # [TotalOrbitalNum2, energy_idx_num_k_dn]
  Es_m_kq_down::Array{Complex_my,2} = eigenstate_kq_down.Eigenstate; # [TotalOrbitalNum2, energy_idx_num_kq_dn]

  if (band_selection_on)
    En_k_up = eigenstate_k_up.Eigenvalues[band_selection_lower:band_selection_upper];
    Em_kq_up = eigenstate_kq_up.Eigenvalues[band_selection_lower:band_selection_upper];
    En_k_down = eigenstate_k_down.Eigenvalues[band_selection_lower:band_selection_upper];
    Em_kq_down = eigenstate_kq_down.Eigenvalues[band_selection_lower:band_selection_upper];

    Es_n_k_up = eigenstate_k_up.Eigenstate[:,band_selection_lower:band_selection_upper];
    Es_m_kq_up= eigenstate_kq_up.Eigenstate[:,band_selection_lower:band_selection_upper];
    Es_n_k_down = eigenstate_k_down.Eigenstate[:,band_selection_lower:band_selection_upper];
    Es_m_kq_down = eigenstate_kq_down.Eigenstate[:,band_selection_lower:band_selection_upper];

    TotalOrbitalNum2 = length(En_k_up);
  end

  for (atom12_i,atom12) in enumerate(atom12_list)
    atom1 = atom12[1]
    atom2 = atom12[2]

    atom1_orbitals = orbitalStartIdx_list[atom1] .+ (1:orbitalNums[atom1]);
    atom2_orbitals = orbitalStartIdx_list[atom2] .+ (1:orbitalNums[atom2]);
    ############################################################################
    ## Accessing Data End
    ############################################################################

    # mask oribtals
    Es_n_k_up_atom1 = copy(Es_n_k_up);
    Es_n_k_up_atom2 = copy(Es_n_k_up);

    Es_n_k_down_atom1 = copy(Es_n_k_down);
    Es_n_k_down_atom2 = copy(Es_n_k_down);

    Es_m_kq_up_atom1  = copy(Es_m_kq_up);
    Es_m_kq_up_atom2  = copy(Es_m_kq_up);

    Es_m_kq_down_atom1 = copy(Es_m_kq_down);
    Es_m_kq_down_atom2 = copy(Es_m_kq_down);

    @inline function energy_cut(energywindow_list, En , Es)
        En_whiteList_mask_total = zeros(Bool, length(En))
        for energywindow_item in energywindow_list
            lower_E_cut = energywindow_item[1]
            upper_E_cut = energywindow_item[2]
            En_whiteList_mask  = ( (lower_E_cut .< (En  .- ChemP)) .& (upper_E_cut .> (En  .- ChemP)) );

            En_whiteList_mask_total .|= En_whiteList_mask;
        end
        Es[:, .!En_whiteList_mask_total] .= 0.0;
    end
    # Energy mask
    if (length(energywindow_all_list)>0)
        energy_cut(energywindow_all_list, En_k_up, Es_n_k_up_atom1);
        energy_cut(energywindow_all_list, En_k_up, Es_n_k_up_atom2);

        energy_cut(energywindow_all_list, Em_kq_up, Es_m_kq_up_atom1);
        energy_cut(energywindow_all_list, Em_kq_up, Es_m_kq_up_atom2);

        energy_cut(energywindow_all_list, En_k_down, Es_n_k_down_atom1);
        energy_cut(energywindow_all_list, En_k_down, Es_n_k_down_atom2);

        energy_cut(energywindow_all_list, Em_kq_down, Es_m_kq_down_atom1);
        energy_cut(energywindow_all_list, Em_kq_down, Es_m_kq_down_atom2);

    end
    if (length(energywindow_1_list)>0)
        energy_cut(energywindow_1_list, En_k_up, Es_n_k_up_atom1);
        energy_cut(energywindow_1_list, En_k_down, Es_n_k_down_atom1);
    end
    if (length(energywindow_3_list)>0)
        energy_cut(energywindow_3_list, Em_kq_up, Es_m_kq_up_atom1);
        energy_cut(energywindow_3_list, Em_kq_down, Es_m_kq_down_atom1);
    end
    if (length(energywindow_2_list)>0)
        energy_cut(energywindow_2_list, En_k_up, Es_n_k_up_atom2);
        energy_cut(energywindow_2_list, En_k_down, Es_n_k_down_atom2);
    end
    if (length(energywindow_4_list)>0)
        energy_cut(energywindow_4_list, Em_kq_up, Es_m_kq_up_atom2);
        energy_cut(energywindow_4_list, Em_kq_down, Es_m_kq_down_atom2);
    end


    # Orbital mask

    if (length(orbital_selection1)>0)
      orbital_selection1_tmp = collect(1:orbitalNums[atom1]);
      for orbit1 in orbital_selection1
          deleteat!(orbital_selection1_tmp, findall(orbital_selection1_tmp .== orbit1))
      end
      Es_n_k_up_atom1[orbitalStartIdx_list[atom1] .+ orbital_selection1_tmp,:]   .= 0.0;
      Es_n_k_down_atom1[orbitalStartIdx_list[atom1] .+ orbital_selection1_tmp,:] .= 0.0;
    end
    if (length(orbital_selection3)>0)
      orbital_selection3_tmp = collect(1:orbitalNums[atom1]);
      for orbit3 in orbital_selection3
          deleteat!(orbital_selection3_tmp, findall(orbital_selection3_tmp .== orbit3))
      end
      Es_m_kq_up_atom1[orbitalStartIdx_list[atom1] .+ orbital_selection3_tmp,:]   .= 0.0;
      Es_m_kq_down_atom1[orbitalStartIdx_list[atom1] .+ orbital_selection3_tmp,:] .= 0.0;
    end

    if (length(orbital_selection2)>0)
      orbital_selection2_tmp = collect(1:orbitalNums[atom2]);
      for orbit2 in orbital_selection2
          deleteat!(orbital_selection2_tmp, findall(orbital_selection2_tmp .== orbit2))
      end
      Es_n_k_up_atom2[orbitalStartIdx_list[atom2]   .+ orbital_selection2_tmp,:] .= 0.0;
      Es_n_k_down_atom2[orbitalStartIdx_list[atom2] .+ orbital_selection2_tmp,:] .= 0.0;
    end
    if (length(orbital_selection4)>0)
      orbital_selection4_tmp = collect(1:orbitalNums[atom2]);
      for orbit4 in orbital_selection4
          deleteat!(orbital_selection4_tmp, findall(orbital_selection4_tmp .== orbit4))
      end
      Es_m_kq_up_atom2[orbitalStartIdx_list[atom2]   .+ orbital_selection4_tmp,:] .= 0.0;
      Es_m_kq_down_atom2[orbitalStartIdx_list[atom2] .+ orbital_selection4_tmp,:] .= 0.0;
    end

    ## Do auctual calucations
    Fftn_k_up  = 1.0./(exp.( ((En_k_up)  .- ChemP)/(kBeV*E_temp)) .+ 1.0 );
    Fftm_kq_up = 1.0./(exp.( ((Em_kq_up) .- ChemP)/(kBeV*E_temp)) .+ 1.0 );

    Fftn_k_down  = 1.0./(exp.( ((En_k_down)  .- ChemP)/(kBeV*E_temp)) .+ 1.0 );
    Fftm_kq_down = 1.0./(exp.( ((Em_kq_down) .- ChemP)/(kBeV*E_temp)) .+ 1.0 );

    # Index convention: dFnk[nk,mkq]
    # target dim [energy_idx_num_k_dn,energy_idx_num_kq_up]
    dFnk_down_Fmkq_up =
      Fftn_k_down*ones(1,energy_idx_num_kq_up)  - ones(energy_idx_num_k_dn,1)*Fftm_kq_up[:]' ;
    # target dim [energy_idx_num_k_up,energy_idx_num_kq_dn]
    dFnk_up_Fmkq_down =
      Fftn_k_up*ones(1,energy_idx_num_kq_dn)  - ones(energy_idx_num_k_up,1)*Fftm_kq_down[:]' ;

    # Index convention: Enk_Emkq[nk,mkq]
    # target dim [energy_idx_num_k_dn,energy_idx_num_kq_up]
    Enk_down_Emkq_up =
      En_k_down[:]*ones(1,energy_idx_num_kq_up) - ones(energy_idx_num_k_dn,1)*Em_kq_up[:]' ;
    #Enk_down_Emkq_up .+= im*0.0001;
    # target dim [energy_idx_num_k_up,energy_idx_num_kq_dn]
    Enk_up_Emkq_down =
      En_k_up[:]*ones(1,energy_idx_num_kq_dn) - ones(energy_idx_num_k_up,1)*Em_kq_down[:]' ;
    #Enk_up_Emkq_down .+= im*0.0001;
    #Enk_Emkq += im*0.001;


    V1_k  = 0.5*(Hks_k_up[atom1_orbitals,atom1_orbitals] - Hks_k_down[atom1_orbitals,atom1_orbitals]);
    V2_kq = 0.5*(Hks_kq_up[atom2_orbitals,atom2_orbitals] - Hks_kq_down[atom2_orbitals,atom2_orbitals]);

    V1_kq = 0.5*(Hks_kq_up[atom1_orbitals,atom1_orbitals] - Hks_kq_down[atom1_orbitals,atom1_orbitals]);
    V2_k  = 0.5*(Hks_k_up[atom2_orbitals,atom2_orbitals] - Hks_k_down[atom2_orbitals,atom2_orbitals]);

    # Cal. psi><w|V_k|w><w|psi> , psi><w|V_k+q|<w|psi>
    VV1_down_up_k = Es_n_k_down_atom1[atom1_orbitals,:]' * V1_k *
        Es_m_kq_up_atom1[atom1_orbitals,:];
    VV2_up_down_kq = Es_m_kq_up_atom2[atom2_orbitals,:]' * V2_kq *
        Es_n_k_down_atom2[atom2_orbitals,:];

    VV1_down_up_kq = Es_n_k_down_atom1[atom1_orbitals,:]' * V1_kq *
        Es_m_kq_up_atom1[atom1_orbitals,:];
    VV2_up_down_k = Es_m_kq_up_atom2[atom2_orbitals,:]' * V2_k *
        Es_n_k_down_atom2[atom2_orbitals,:];

    VV1_up_down_k = Es_n_k_up_atom1[atom1_orbitals,:]' * V1_k *
        Es_m_kq_down_atom1[atom1_orbitals,:];
    VV2_down_up_kq = Es_m_kq_down_atom2[atom2_orbitals,:]' * V2_kq *
        Es_n_k_up_atom2[atom2_orbitals,:];

    VV1_up_down_kq = Es_n_k_up_atom1[atom1_orbitals,:]' * V1_kq *
        Es_m_kq_down_atom1[atom1_orbitals,:];
    VV2_down_up_k = Es_m_kq_down_atom2[atom2_orbitals,:]' * V2_k *
        Es_n_k_up_atom2[atom2_orbitals,:];


    x1_down_up_k = Es_n_k_down_atom1[atom1_orbitals,:]'  *
        Es_m_kq_up_atom1[atom1_orbitals,:];
    x2_up_down_kq = Es_m_kq_up_atom2[atom2_orbitals,:]'  *
        Es_n_k_down_atom2[atom2_orbitals,:];

    # Index convention: Vi_Vj[nk,mkq]
    Vi_Vj_down_up_up_down_k_kq = VV1_down_up_k.*transpose(VV2_up_down_kq);
    Vi_Vj_down_up_up_down_kq_k = VV1_down_up_kq.*transpose(VV2_up_down_k);

    Vi_Vj_up_down_down_up_k_kq = VV1_up_down_k.*transpose(VV2_down_up_kq);
    Vi_Vj_up_down_down_up_kq_k = VV1_up_down_kq.*transpose(VV2_down_up_k);
    #Vi_Vj_down_up_up_down_G    = VV1_down_up_G.*transpose(VV2_up_down_G);
    #Vi_Vj_up_down_down_up_G    = VV1_up_down_G.*transpose(VV2_down_up_G);

    x_down_up_up_down_k_kq = x1_down_up_k.*transpose(x2_up_down_kq);


    # Index convetion: J_ij[nk,mkq]
    J_ij_down_up_up_down_k_kq =  0.5./(-Enk_down_Emkq_up).*dFnk_down_Fmkq_up .* Vi_Vj_down_up_up_down_k_kq ;
    J_ij_down_up_up_down_kq_k =  0.5./(-Enk_down_Emkq_up).*dFnk_down_Fmkq_up .* Vi_Vj_down_up_up_down_kq_k ;

    J_ij_up_down_down_up_k_kq =  0.5./(-Enk_up_Emkq_down).*dFnk_up_Fmkq_down .* Vi_Vj_up_down_down_up_k_kq ;
    J_ij_up_down_down_up_kq_k =  0.5./(-Enk_up_Emkq_down).*dFnk_up_Fmkq_down .* Vi_Vj_up_down_down_up_kq_k ;


    x_ij_down_up_up_down_k_kq =  0.5./(-Enk_down_Emkq_up).*dFnk_down_Fmkq_up .* x_down_up_up_down_k_kq ;

    result_mat[2,atom12_i] = sum(J_ij_down_up_up_down_k_kq[.!isnan.(J_ij_down_up_up_down_k_kq)] );
    #result_mat[3,atom12_i] = sum(J_ij_down_up_up_down_kq_k[.!isnan.(J_ij_down_up_up_down_kq_k)] );
    #result_mat[4,atom12_i] = sum(J_ij_up_down_down_up_k_kq[.!isnan.(J_ij_up_down_down_up_k_kq)] );
    result_mat[5,atom12_i] = sum(J_ij_up_down_down_up_kq_k[.!isnan.(J_ij_up_down_down_up_kq_k)] );


    result_mat[1,atom12_i] = 0.5*(result_mat[2,atom12_i] + result_mat[5,atom12_i] );
  end
  return result_mat

end




## 4.1 Do K,Q sum
# for orbital_selection1_list,orbital_selection2_list combinations

for (orbital1_i,orbital_selection1_local) in enumerate(orbital_selection1_list)
  for (orbital2_i,orbital_selection2_local) in enumerate(orbital_selection2_list)

    for (orbital3_i,orbital_selection3_local) in enumerate(orbital_selection3_list)
      for (orbital4_i,orbital_selection4_local) in enumerate(orbital_selection4_list)
        orbital_selection_input = orbital_selection_input_Type(orbital_selection1_local,orbital_selection2_local,
          orbital_selection3_local,orbital_selection4_local,(-1,-1),false)
        if (orbital_selection_on)
            orbital_selection_input = orbital_selection_input_Type(orbital_selection1_local,orbital_selection2_local,
            orbital_selection3_local,orbital_selection4_local,(-1,-1),true)
        end
        orbital_selection_name = orbital_selection1_names[orbital1_i]*"_"*orbital_selection2_names[orbital2_i]*"__"*
          orbital_selection3_names[orbital3_i]*"__"*orbital_selection4_names[orbital4_i];
        println(DFTcommon.bar_string) # print ====...====
        println(orbital_selection_name," selection1 ",orbital_selection1_local,"\tselection2 ",orbital_selection2_local,
        "\tselection3 ",orbital_selection3_local,"\tselection4 ",orbital_selection4_local)

        # setup extra info
        energywindow_all1234_list = [
        energywindow_all_list,
          energywindow_1_list,energywindow_2_list,
          energywindow_3_list,energywindow_4_list
         ]
        DFTforge.pwork(init_orbital_selection,orbital_selection_input)
        DFTforge.pwork(init_variables,ChemP_delta_ev,band_selection_on, band_selection_lower, band_selection_upper, energywindow_all1234_list)

        (X_Q_nc,X_Q_mean_nc) = Qspace_Ksum_atomlist_parallel(Magnetic_Exchange_J_colinear,
        q_point_list,k_point_list,atom12_list,num_return)
        #println(typeof(X_Q_mean_nc))
        println(DFTcommon.bar_string) # print ====...====
        ## 4.2 reduce K,Q to Q space
        # Average X_Q results
        Xij_Q_mean_matlab = Array{Array{Complex_my,1}}(undef,num_return,length(atom12_list));
        for (atom12_i,atom12) in enumerate(atom12_list)
          atom1 = atom12[1];
          atom2 = atom12[2];
          for xyz_i = 1:num_return
            Xij_Q_mean_matlab[xyz_i,atom12_i] = zeros(Complex_my,length(q_point_list));
            for (q_i,q_point) in enumerate(q_point_list)
              q_point_int = k_point_float2int(q_point);
              Xij_Q_mean_matlab[xyz_i,atom12_i][q_i] =
                X_Q_mean_nc[xyz_i,atom12_i][q_point_int];
            end
            if 0 == xyz_i
                println(string(" Gamma point J [",atom1,",",atom2,"] ",xyz_i," :",
                1000.0*mean(Xij_Q_mean_matlab[xyz_i,atom12_i][:])," meV"))
            end
          end
        end
        ###############################################################################
        ## 5. Save results and clear hdf5 file
        ## 5.1 Prepaire infomations for outout
        ## 5.2 Write to MAT
        ###############################################################################
        optionalOutputDict = Dict{AbstractString,Any}()
        optionalOutputDict["num_return"] = num_return;
        optionalOutputDict["VERSION_Spin_Exchange"] = string(X_VERSION);

        export2mat_K_Q(Xij_Q_mean_matlab,hamiltonian_info,q_point_list,k_point_list,atom12_list,
        orbital_selection_on,
        orbital_selection1_local,orbital_selection2_local,orbital_selection3_local,orbital_selection4_local,
        energywindow_all1234_list,
        ChemP_delta_ev,
        optionalOutputDict,
        jq_output_dir,cal_name,
        orbital_selection_name,cal_type);
      end
    end
  end
end

## 5.3 Cleanup HDF5 cache file
println(DFTcommon.bar_string) # print ====...====
println("hdf_cache_name:",hdf_cache_name)
if (isfile(hdf_cache_name))
  rm(hdf_cache_name)
  file = open(hdf_cache_name,"w");
  close(file);
end
