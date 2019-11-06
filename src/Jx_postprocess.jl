__precompile__(true)
###
#using ProgressMeter
import DFTforge
#using DFTforge.DFTrefinery
#using DFTcommon
#using DFTforge.Plugins
println("Jx_postprocess started (julia Jx_postprocess.jl --help for inputs)")
#using ArgParse
using DFTforge.ArgParse
#using DataStructures
s = ArgParseSettings("Jx_postprocess.jl for J(q)->J(r):")
@add_arg_table s begin
    "--cellvectors"
    #action = :store_true   # this makes it a flag
        help = "cellvectors ex:) 5_5_5 default 2_2_2"
        required = true
    "--atom2"
        help = "second atom index ex1:) 1,2 or by using wild card *"     # used by the help screen
    "--orbital_name"
        help = "used for selecting orbital ex:) [all_all] or [dz_dxy]"
    "--baseatom"
        arg_type = Int
        default = 0
        help = ""
    "root_dir"
        help = "root directory of *.jld2 files "
        arg_type = String
        required = true

end

#Pkg.add("Plots")
#Pkg.add("Glob")

#parsed_args = parse_args(ARGS, s)
#=
ARGS = "-q 3_3_3 ../examples/CrO2.U0.0/jq.spin.test.wannier_0.0/"
ARGS = Array{String}(undef,0);
push!(ARGS,"--cellvectors")
push!(ARGS,"3_3_3")
push!(ARGS,"--baseatom")
push!(ARGS,"1")
push!(ARGS,"--atom12")
push!(ARGS,"1_1,1_2")
push!(ARGS,"--orbital_name")
push!(ARGS,"all_all")
push!(ARGS,"../examples/CrO2.U0.0/jq.spin.test.wannier_0.0/")
=#
parsed_args = parse_args(ARGS, s)
import DFTforge.DataFrames
import DFTforge.FileIO
import DFTforge.CSV
import Plots
import DFTforge.Glob

using Statistics

###
println("================ User input =============")
for (k,v) in parsed_args
   println(k," => ",v)
end
# read inputs
root_dir = parsed_args["root_dir"]
base_atom = parsed_args["baseatom"]
atom2_name_list = [""]
if !(Nothing == typeof(parsed_args["atom2"]))
    atom2_name_list = split(parsed_args["atom2"],",")
end
orbital_name = ""
if !(Nothing == typeof(parsed_args["orbital_name"]))
    orbital_name = parsed_args["orbital_name"]
end
# get file list
file_list = Array{String}(undef,0);
for atom2_name in atom2_name_list
   atom_12name = string(base_atom) * "_" * string(atom2_name)
   file_list_tmp = Glob.glob("*" * atom_12name * "*" * orbital_name * "*.jld2",root_dir)
   append!(file_list,file_list_tmp)
end
#get q points
cellvect_num = [2,2,2];
if !(Nothing == typeof(parsed_args["cellvectors"]))
    val = parsed_args["cellvectors"];
    cellvect_num_tmp =   map(x->parse(Int64,x),split(val,"_"))
    if (3 == length(cellvect_num_tmp))
        cellvect_num = cellvect_num_tmp;
    else
        println("q point should be like 10_10_10")
    end
end


println("================ Selected result *.jld2 files =============")
cached_mat_dict = Dict{Tuple{Int64,Int64},Any}();
#s = [];
global rv = zeros(Float64, 3,3)
global tv = zeros(Float64, 3,3)
global global_xyz = [];
global atom1 = 0
global atom2 = 0
for (k,v_filename) in enumerate(file_list)
  #s = MAT.matread(v_filename);
  println(v_filename)
  s = FileIO.load(v_filename);
  global atom1 = s["atom1"];
  global atom2 = s["atom2"];

  if (base_atom == atom1)
    s["filename"] = v_filename
    cached_mat_dict[(atom1,atom2)] = s;
  end
  global rv = s["rv"];
  global tv = s["tv"];
  global global_xyz = s["Gxyz"];
end

#cached_mat_dict = SortedDict(cached_mat_dict)
println("================ Selected result *.jld2 files =============")
#global_xyz

# Check properties

#atom1_frac_xyz = global_xyz[atom1,:];
for (k,v) in cached_mat_dict
  s = v;

  atom1_tmp = s["atom1"]
  atom2_tmp = s["atom2"]

  #println([atom1_tmp, atom2_tmp])
  rv_tmp = s["rv"]
  tv_tmp = s["tv"]
  global_xyz_tmp = s["Gxyz"];
  #atom1_frac_xyz_tmp = global_xyz[atom1,:];

  @assert(rv == rv_tmp);
  @assert(tv == tv_tmp);
  @assert(atom1 == atom1_tmp);
  @assert(global_xyz == global_xyz_tmp);
  #@assert(atom1_frac_xyz == atom1_frac_xyz_tmp);
end







function get_J(cell_vect_list, J_ij_Q_data, q_point_cart, atom1_global_xyz, atom2_global_xyz)
  J_ij_cell_vect = zeros(ComplexF64,length(cell_vect_list));
  J_ij_pos_vects = zeros(length(cell_vect_list),3);

  atom2_global_xyz_0 = atom2_global_xyz;

  for (k,v) in enumerate(cell_vect_list)
  #k = 1
  #cell_vect_list[1]
    v = cell_vect_list[k][:]

    cell_global_xyz = v[1]*tv[1,:] + v[2]*tv[2,:] + v[3]*tv[3,:]
    atom2_global_xyz_rel = cell_global_xyz[:] + atom2_global_xyz[:];
    Rq = q_point_cart[:,1] * cell_global_xyz[1] +
    q_point_cart[:,2] * cell_global_xyz[2] + q_point_cart[:,3] * cell_global_xyz[3]

    size(exp.(-1*im*Rq))

    J_12_R = mean(J_ij_Q_data.*exp.(-1*im*Rq));
    J_ij_cell_vect[k] = J_12_R
    J_ij_pos_vects[k,:] = atom2_global_xyz_rel - atom1_global_xyz;
  end
  #println("atom2_global_xyz_rel ",J_ij_pos_vects)
  return (J_ij_cell_vect,J_ij_pos_vects)
end


function get_J_idx_1(cell_vect_list, item_idx)
  J_ij_R = [];
  for (k,s) in cached_mat_dict
    #k = 1
    #s = MAT.matread(joinpath(root_dir,file_list_same_baseatom[k]));
    q_point_fact_list = s["q_point_list"]/s["k_point_precision"];

    q_point_cart =   q_point_fact_list[:,1] * transpose(rv[1,:]) + q_point_fact_list[:,2] * transpose(rv[2,:]) + q_point_fact_list[:,3] * transpose(rv[3,:]);


    atom1 = s["atom1"];
    atom2 = s["atom2"];
    atom1_global_xyz = s["Gxyz"][atom1,:];
    atom2_global_xyz = s["Gxyz"][atom2,:]
    println(k, "atom_(i, j):(",atom1,", ",atom2,") global_xyz:(",
      atom1_global_xyz," ",atom2_global_xyz,")")
    #atom1_frac_xyz[:]

    (J,dist_vect) = get_J(cell_vect_list, s["Jij_Q_matlab"][item_idx, 1], q_point_cart, atom1_global_xyz[:], atom2_global_xyz[:] );
    distance_scalar = sqrt.(real( sum(dist_vect.^2,dims=2)[:] ));
    v = sortperm(distance_scalar);
    distance_scalar = distance_scalar[v];
    J = J[v];
    J_r = real(J);
    dist_vect = dist_vect[v,:];
    cell_vect_list2 = cell_vect_list[v];
    #########################
    # Remove 0,0,0 position
    #########################
    nonzero_distance_idx = abs.(distance_scalar) .> 0.000001
    distance_scalar     = distance_scalar[nonzero_distance_idx]
    dist_vect           = dist_vect[nonzero_distance_idx,:]
    cell_vect_list2     = cell_vect_list2[nonzero_distance_idx]
    J_r                 = J_r[nonzero_distance_idx]

    push!(J_ij_R,deepcopy(
    (atom1, atom2, dist_vect, cell_vect_list2, J_r, s)) )
    #Plots.scatter!(distance_scalar, J_r*1000.0)
  end
  return J_ij_R;
end

function get_J_idx_2(cell_vect_list, atom1, atom2, item_idx, angle_idx)
  J_ij_R = [];
  #k = 1
  s = cached_mat_dict[atom1,atom2]
  q_point_fact_list = s["q_point_list"]/s["k_point_precision"];

  q_point_cart =   q_point_fact_list[:,1] * transpose(rv[1,:]) +
   q_point_fact_list[:,2] * transpose(rv[2,:])+
   q_point_fact_list[:,3] * tranpose(rv[3,:])

  atom1_global_xyz = s["Gxyz"][atom1,:];
  atom2_global_xyz = s["Gxyz"][atom2,:]
  #println(atom1_global_xyz," ",atom2_global_xyz)
  #atom1_frac_xyz[:]

  (J,dist_vect) = get_J(cell_vect_list, s["Jij_Q_matlab"][item_idx,angle_idx], q_point_cart, atom1_global_xyz[:], atom2_global_xyz[:] );
  distance_scalar = sqrt(real( sum(dist_vect.^2,2)[:] ));
  v = sortperm(distance_scalar);
  distance_scalar = distance_scalar[v];
  J = J[v];
  J_r = real(J);
  nonzero_distance_idx = abs.(distance_scalar) .> 0.000001
  distance_scalar = distance_scalar[nonzero_distance_idx]
  J_r = J_r[nonzero_distance_idx]
  push!(J_ij_R,deepcopy((atom1,atom2,distance_scalar,J_r,s)) )

  #Plots.scatter!(distance_scalar, J_r*1000.0)

  return J_ij_R;
end

cell_vect_list = [];
cell_vect_x_list = -cellvect_num[1]:1:cellvect_num[1]
cell_vect_y_list = -cellvect_num[2]:1:cellvect_num[2]
cell_vect_z_list = -cellvect_num[3]:1:cellvect_num[3]
for cell_vect_x in cell_vect_x_list
  for cell_vect_y in cell_vect_y_list
    for cell_vect_z in cell_vect_z_list
      push!(cell_vect_list,[cell_vect_x,cell_vect_y,cell_vect_z])
    end
  end
end

J_ij_R = get_J_idx_1(cell_vect_list, 1)
size(J_ij_R)[1]
atom12_num = size(J_ij_R)[1];
atom12_num = size(J_ij_R)[1];
##=
println("================ Writing CSV & Plotfile  =============")
num_results = size(J_ij_R)[1]
@assert(num_results == length(file_list))
for result_i in 1:num_results
    s_tmp = J_ij_R[result_i][6]
    file_name = s_tmp["filename"]

    basefile =  splitext(file_name)[1]
    #basefile =  splitext(file_list[result_i])[1]
    csv_filename = basefile*".csv"
    println(" Writing CSV:", basename(csv_filename))

    dist_vect = J_ij_R[result_i][3]
    distance_scalar = sqrt.(real( sum(dist_vect.^2,dims=2) ))[:]
    #println(size(distance_scalar),size(J_ij_R[result_i][4]),size(cell_vect_list),size(dist_vect))
    Rxyz = collect(transpose(hcat(J_ij_R[result_i][4]...)))

    CSV.write(csv_filename,
    DataFrames.DataFrame(Distance = distance_scalar,
                         JmeV = J_ij_R[result_i][5] * 1000.0, # eV -> meV
                         #Dxyz = dist_vect[:,1],
                         Rx = Rxyz[:,1],
                         Ry = Rxyz[:,2],
                         Rz = Rxyz[:,3],
                         Dx = dist_vect[:,1],
                         Dy = dist_vect[:,2],
                         Dz = dist_vect[:,3]
                        ); delim=',' )
end

################################################################################
# Plot first item
################################################################################
Plots.plotly()
dist_vect = J_ij_R[1][3]
distance_scalar = sqrt.(real( sum(dist_vect.^2,dims=2) ))[:]
label= string(J_ij_R[1][1])*"_"*string(J_ij_R[1][2])

Plots.plot(distance_scalar,J_ij_R[1][5] *1000.0, label = label)
################################################################################
# Plot second to end of itmes
################################################################################
for result_i in 2:size(J_ij_R)[1]
    #println(result_i)
    dist_vect = J_ij_R[result_i][3]
    distance_scalar = sqrt.(real( sum(dist_vect.^2,dims=2) ))[:]
    label= string(J_ij_R[result_i][1])*"_"*string(J_ij_R[result_i][2])

    Plots.plot!(distance_scalar,J_ij_R[result_i][5] *1000.0, label = label)  # eV -> meV
end

plot_filename = "Jplot_" * string(base_atom) * "_" *
   join(atom2_name_list,",") * "_" * orbital_name * ".pdf"

println(" Writing Plot:",plot_filename)
Plots.savefig(joinpath(root_dir,plot_filename))
#Plots.plot!(J_ij_R[2][3],J_ij_R[2][4] *1000.0)
println("================ All done =============")
