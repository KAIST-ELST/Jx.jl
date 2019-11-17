---
layout: single
author_profile: false
title: "Acknowledegment"
---

## The *Jx* history
The newly released version of *Jx* is the successor of [*Jx*](http://www.openmx-square.org/openmx_man3.8/node111.html) a subroutine that has been released as a part of [‘OpenMX’ DFT software package](http://www.openmx-square.org/), that can be regarded as the molecule version of *Jx*. In other words, the original corresponds to the Gamma-point-only calculation.
The implementation details and results can be found in the following links.
> [M. J. Han, T. Ozaki, and J. Yu, Phys. Rev. B 70, 184421 (2004).](http://dx.org/10.1103/PhysRevB.70.184421)

> [The original *Jx* in OpenMX](http://www.openmx-square.org/openmx_man3.8/node111.html)

The newly implemented *Jx* is extended to a [solid version](/docs/feature/#j-in-momentum-space) and added features such as [orbital resolution](/docs/feature/#j-coupling-matrix-orbital-resolved-interactions) and [axis redefinition](/docs/feature/#local-axis-redefinition-for-orbital-resolved-j). The parallelism related to the expansion into the K and Q spaces is carefully designed.

The [OpenMX](http://www.openmx-square.org/) is the first-class citizen in *Jx*. Also, the [extended compatibility is provided](/docs/feature/#support-mulitple-tight-binding-hamiltonian) through [DFTforge](https://kaist-elst.github.io/DFTforge.jl/) which serves as the generalized Hamiltonian interface.


## The study was supported by the following projects

> Will be updated.