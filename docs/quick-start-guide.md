---
layout: single
author_profile: false
title: "Quick start"
---


### Install Julia ([https://julialang.org/](https://julialang.org/))

 * Currently we support latest Julia 1.0/1.1. *
 * For Linux system:

[Using Julia auto-installer for Linux](https://github.com/abelsiqueira/jill)

 ```bash
echo 'export PATH=~/opt/bin:$PATH' >>~/.profile
echo 'export PATH=~/opt/bin:$PATH' >>~/.bashrc
JULIA_INSTALL=~/opt/bin bash -ci "$(curl –fsSL https://raw.githubusercontent.com/abelsiqueira/jill/master/jill.sh)"
 ```

 * For OSX or Windows see: [Julia Download](https://julialang.org/downloads/)

### Install DFTforge
```bash
git clone github.com/KAIST-ELST/DFTforge.jl
julia install.jl
```

<figure>
   <a href="">
   <img src="/assets/images/install2.gif" style="max-height: 200px;"
      alt="Install example" />
   </a>

   <figcaption> Easy install</figcaption>
</figure>


### Run example

#### G-type AFM (anti ferromagnetic) NiO example
```bash
./example_NiO_OpenMX.sh
```
