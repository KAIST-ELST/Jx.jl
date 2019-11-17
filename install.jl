import Pkg
julia_installed_pkg = Pkg.installed()

if !haskey(julia_installed_pkg, "DFTforge" )
  Pkg.add("DFTforge")
else
  Pkg.update("DFTforge")
end

Pkg.add("Plots")
Pkg.add("JLD2")
Pkg.add("Glob")
Pkg.add("HDF5")
Pkg.add("ColorTypes")
Pkg.add("ProgressMeter")

Pkg.build("HDF5")
import DFTforge
