---
layout: single
author_profile: false
title: "Getting started"

toc: true
toc_label: "Features"
toc_icon: "cog"

---
# Quick start (Install & run example)

The single script will install [Julia](#install-julia-httpsjulialangorg) & [DFTforge](#install-dftforge) & Jx

``` bash
git clone https://github.com/KAIST-ELST/Jx.jl
cd Jx.jl
./install.sh
```
[Run example](#run-example)

```
./example_NiO_OpenMX.sh
```

The `./example_NiO_OpenMX.sh` script will perform the MFT calculation for G-type antiferromagnetic NiO.
Details are as follows:
1. Extract the NiO Hamiltonian result file precomputed with [OpenMX](www.openmx-square.org/), and
2. Perform the MFT calculation.
3. Save  *J*<sub>ij</sub> to CSV files and plot *J*<sub>ij</sub> to PDF file.

# Install

## Install Julia


Currently we support latest Julia 1.0-1.2.* ([https://julialang.org/](https://julialang.org/))

 * For Linux system:

[Using Julia auto-installer for Linux](https://github.com/abelsiqueira/jill)

 ```bash
echo 'export PATH=~/opt/bin:$PATH' >>~/.profile
echo 'export PATH=~/opt/bin:$PATH' >>~/.bashrc
JULIA_INSTALL=~/opt/bin bash -ci "$(curl –fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"
 ```
 * For OSX

Install [Homebrew](https://brew.sh/)

```bash
brew cask install julia
brew cask upgrade julia
```

 * For Windows see: [Julia Download](https://julialang.org/downloads/)


## Install [DFTforge](https://kaist-elst.github.io/DFTforge.jl/)
```julia
import Pkg
Pkg.add("DFTforge")
```
<!---
<figure>
   <a href="">
   <img src="/assets/images/install2.gif"  
      alt="Install example" />
   </a>
     <!- style="max-height: 200px;" ->
   <figcaption> Easy install</figcaption>
</figure>
--->


# Run example

## G-type AFM (anti ferromagnetic) NiO example
```bash
./example_NiO_OpenMX.sh
```
