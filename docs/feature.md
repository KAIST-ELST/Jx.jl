---
layout: single
author_profile: false
title: "Feature"

toc: true
toc_label: "Features"
toc_icon: "cog"


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
---


# Jx support the following features:
## *J* in momentum space.

MFT is a linear response calculation and can be performed in momentum space.
Therefore, MFT can compute short and long-term interactions in moment space, without multiple real space supercells calculations.


{% include figure image_path="assets/images/Fig_Metal_basis_vs_J_Fe.svg" alt="Fe metal Jij profile" caption="The calculated **J**<sub>ij</sub> for bcc Fe as a function of interatomic distance." %}




## *J* coupling matrix (Orbital resolved interactions)

## Local axis redefinition for orbital resolved *J*

## Support mulitple Tight-binding Hamiltonian

We support following Hamiltonian interfaces:
* Full DFT Hamiltonian from [OpenMX](http://www.openmx-square.org/) ![OpenMx](http://www.openmx-square.org/OpenMX_LOGO_S.PNG){:height="50px" width="50px"}
* Wannier
    * [Openmx Wannier](http://www.openmx-square.org/openmx_man3.7/node109.html).
    * [Wannier90](http://www.wannier.org/).
    * Adding custom Hamilton format interfaces are also possible.
* Full DFT/QSGW Hamiltonian from [EcalJ](https://github.com/tkotani/ecalj)

---
{% include feature_row %}
---