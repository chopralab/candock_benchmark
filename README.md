# Candock benchmarking scripts

This project contains all the benchmarking scripts required to reproduce the results presented in our [docking paper](https://www.biorxiv.org/content/10.1101/442897v2). Each benchmarking set is given its own project directory along with the protein and ligand structures used in the benchmark. The scripts used to run CANDOCK on these benchmarking sets are also provided in their corresponding directories.

# Obtaining CANDOCK

CANDOCK (v0.4.3) can be obtained along with this repository by using the following commands:

```bash
git clone https://github.com/chopralab/candock_benchmark.git
git submodule init
git submodule update
```

Please see the CANDOCK readme (now in the *candock* directory) for instructions on how to build and install the project. After this this is complete, you can run the benchmarking scripts in the benchmark directories.
