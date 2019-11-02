---
layout: single
author_profile: false
title: "Feature"

toc: true
toc_label: "Features"
toc_icon: "cog"



---


Jx support the following features:

## *J* in momentum space.

MFT is a linear response calculation and can be performed in momentum space.
Therefore, MFT can compute short and long-term interactions in moment space, without multiple real space supercells calculations.


{% include figure image_path="assets/images/Fig_Metal_basis_vs_J_Fe.svg" alt="Fe metal Jij profile" caption="The calculated **J**<sub>ij</sub> for bcc Fe as a function of interatomic distance." %}


## *J* coupling matrix (Orbital resolved interactions)


A useful feature of MFT is to calculate the orbitally decomposed magnetic response function. <!---\cite{kvashnin_exchange_2015,yoon_reliability_2018}. --->
It means that a magnetic coupling constant is extended to a matrix. If we consider **d** orbital system, for example, each magnetic atom has five magnetic orbitals and the magnetic coupling J<sub>12</sub> (in between atom 1 and atom 2) is expressed by a 5X5 matrix J<sub>12</sub>.

## Local axis redefinition for orbital resolved *J*

In practice, a difficulty in analyzing magnetic materials arises from the absence of well-defined global coordinate axis. 
A typical example is the distorted oxides in which the local $x,y,z$ coordinate at one site is not the same at another. When one tries to calculate the orbital-dependent magnetic coupling, this ambiguity can cause annoying problems. With this motivation, $\mathsf{J_x}$ provides functionality for the user to re-define the local coordinates.


## Support mulitple Tight-binding Hamiltonian

We support following Hamiltonian interfaces:
* Full DFT Hamiltonian from [OpenMX](http://www.openmx-square.org/) ![OpenMx](http://www.openmx-square.org/OpenMX_LOGO_S.PNG){:height="50px" width="50px"}
* Wannier
    * [Openmx Wannier](http://www.openmx-square.org/openmx_man3.7/node109.html).
    * [Wannier90](http://www.wannier.org/).
    * Adding custom Hamilton format interfaces are also possible.
* Full DFT/QSGW Hamiltonian from [EcalJ](https://github.com/tkotani/ecalj)

---
<!--- 
feature_row:
  - image_path: assets/images/Fig_Metal_basis_vs_J_Fe.svg
    alt: "placeholder image 1"
    title: "Placeholder 1"
    excerpt: "This is some sample content that goes here with **Markdown** formatting."
  - image_path: /assets/images/unsplash-gallery-image-2-th.jpg
    alt: "placeholder image 2"
    title: "Placeholder 2"
    excerpt: "This is some sample content that goes here with **Markdown** formatting."
    url: "#test-link"
    btn_label: "Read More"
    btn_class: "btn--inverse"
  - image_path: /assets/images/unsplash-gallery-image-3-th.jpg
    title: "Placeholder 3"
    excerpt: "This is some sample content that goes here with **Markdown** formatting."

{% include feature_row %} 
--->
---
