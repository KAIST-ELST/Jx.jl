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

```console
git clone https://github.com/KAIST-ELST/Jx.jl
cd Jx.jl
./install_julia_linux_mac.sh
```
[Run example](#run-example)

```console
./example_NiO_OpenMX.sh
```

The `./example_NiO_OpenMX.sh` script will perform the MFT calculation for G-type antiferromagnetic NiO.
Details are as follows:
1. Extract the NiO Hamiltonian result file precomputed with [OpenMX](www.openmx-square.org/), and
2. Perform the MFT calculation.
3. Save  *J*<sub>ij</sub> to CSV files and plot *J*<sub>ij</sub> to PDF file.

# Step by step installation

## 1. Download the Jx code
```console
git clone https://github.com/KAIST-ELST/Jx.jl
```

## 2. Install Julia

![Julia1.3](https://img.shields.io/badge/Julia-1.3-blue.svg?longCache=true)
![Julia1.4](https://img.shields.io/badge/Julia-1.4-blue.svg?longCache=true)
![Julia1.5](https://img.shields.io/badge/Julia-1.5-blue.svg?longCache=true)
![Julia1.6](https://img.shields.io/badge/Julia-1.6-blue.svg?longCache=true)


Currently we support latest Julia 1.3-1.6.* ([https://julialang.org/](https://julialang.org/))


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


## 3. Install [DFTforge](https://kaist-elst.github.io/DFTforge.jl/)
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


## 4.Run example

### G-type AFM (anti ferromagnetic) NiO example
```bash
./example_NiO_OpenMX.sh
```

See the [NiO example]({{site.url}}{{ site.baseurl }}/docs/example_NiO/) page for the procedure the script does.
