# Candock benchmarking scripts

This project contains all the benchmarking scripts required to reproduce the results presented in our [docking paper](https://pubs.acs.org/doi/10.1021/acs.jcim.9b00686). Each benchmarking set is given its own project directory along with the protein and ligand structures used in the benchmark. The scripts used to run CANDOCK on these benchmarking sets are also provided in their corresponding directories.

If you use this repository, please be sure to not only cite the CANDOCK paper, but the benchmark sets themselves. The links to these papers are as follows:

[Astex](https://pubs.acs.org/doi/abs/10.1021/jm061277y)

[PDBBind](https://pubs.acs.org/doi/10.1021/acs.jcim.8b00545)

[PINC](https://link.springer.com/article/10.1007%2Fs10822-015-9846-3)

## CASF results

The **CASF** directory contains the benchmarking results for the CASF benchmark. Please see [the CASF-2016 paper](https://pubs.acs.org/doi/10.1021/acs.jcim.8b00545) for details. 

## Obtaining CANDOCK

CANDOCK (v0.4.3) can be obtained along with this repository by using the following commands:

```bash
git clone https://github.com/chopralab/candock_benchmark.git
git submodule init
git submodule update
```

Please see the CANDOCK readme (now in the *candock* directory) for instructions on how to build and install the project. After this this is complete, you can run the benchmarking scripts in the benchmark directories.
