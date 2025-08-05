# Small Laplacian Integral Graphs

![License: MIT](https://img.shields.io/badge/License-MIT-pink.svg)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/JuliaDiff/BlueStyle)

## Overview

Recall that "[a] graph is called *Laplacian integral* if the eigenvalues of its Laplacian matrix are all integers."[^JP25] This spectral property is of some interest in quantum information theory; as such, I present a computational survey of some Laplacian integral graphs with low vertex counts. More precisely, I identify all Laplacian integral graphs in the following categories:

- simple connected graphs on up to 11 vertices;
- simple connected regular graphs on up to 14 vertices; and
- simple connected bipartite graphs on up to 15 vertices.

`.txt` files containing the graph6 strings of each element in the foregoing categories (disaggregated by vertex count) are available in the `data/` directory. To generate this data, I ran the scripts in `jobs/` on the [Cedar supercomputer](https://www.sfu.ca/research/institutes-centres-facilities/other-facilities/supercomputer-cedar.html) located at Simon Fraser University. Finally&mdash;summaries of the running time, maximum resident set size, etc. for each job are available in `benchmark/`.

## Dependencies

The scripts in `jobs/` (each corresponding to one of the three aforementioned categories) are computationally intensive, designed specifically for multithreaded execution on a high-performance computing cluster. Moreover, the file paths listed therein are specific to my personal account on Cedar, so even if one did have access to a similar HPC system, the scripts would still need to be modified.

However, the programs *could*, theoretically, be adapted to run on a single machine with fewer threads should one aim to confirm reproducibility&mdash;just be mindful of RAM, and note that the runtime will be significantly longer. The only requirements are working installations of Julia (v1.10 or later) and the C library [nauty](https://pallini.di.uniroma1.it/).[^MP14]

## Citing

I encourage you to cite this work if you find this data useful in your research. The citation information may be found in the [CITATION.bib](https://raw.githubusercontent.com/Luis-Varona/small-laplacian-integral-graphs/main/CITATION.bib) file within the repository.

## Project status

I may consider extending this survey to one order higher for each of the three graph categories (i.e., 11 &rarr; 12, 14 &rarr; 15, and 15 &rarr; 16) at some point in the future. However, given the long running times involved (even using 48 cores on Cedar), I make no guarantees. (If this is ever to be done, it must utilize Slurm's job array capabilities.)

## References

[^JP25]: N. Johnston and S. Plosker. Laplacian {−1,0,1}- and {−1,1}-diagonalizable graphs. *Linear Algebra and its Applications*, 704:309&ndash;339, 2025. [10.1016/j.laa.2024.10.016](https://doi.org/10.1016/j.laa.2024.10.016).
[^MP14]: B. D. McKay and A. Piperno. Practical graph isomorphism, II. *Journal of Symbolic Computation*, 60:94&ndash;112, 2014. [10.1016/j.jsc.2013.09.003](https://doi.org/10.1016/j.jsc.2013.09.003).
