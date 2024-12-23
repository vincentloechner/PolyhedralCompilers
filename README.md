# General-purpose Polyhedral Compilers

This github repository contains the necessary docker script to set the environment for seven general-purpose polyhedral compilers and build those
compilers in an Unix/Linux environment. Those seven polyhedral compilers are as follows: Pluto, PoCC, Polly, Graphite, PolyOpt, PPCG, and Polygeist.

It also contains the PolyBench/C benchmarks to test them and measure the execution time of the resulting codes.
Currently, we only support the execution for CPU architectures.

### Steps to Build Docker Environment
This Docker installation will consume more than  `50GB` of disk space. Clone the above git repository. The folder `docker` contains all the necessary files to build the docker environment. 
The commands are as follows:
```
git clone https://github.com/vincentloechner/PolyhedralCompilers.git
cd PolyhedralCompilers/docker
docker build -f Docker-polyhedral-src . -t polyhedral
docker run --volume $(pwd):/results -it --privileged polyhedral bash
```
Once the docker environment is set with `docker run` the docker machine with built polyhedral compilers can be invoked. 
The polyhedral compiler's source files and their respective build `binaries` are found inside the docker.

### How to test Polyhedral Compilers
We rely on PolyBench/C - a set of 30 numerical benchmarks that has polyhedral nature of nested loops. We have
two scripts `execute_polyhedral.sh` and `execute_polyhedral_syn.sh` to test the parallel and non-parallel execution
of polyhedral compilers. Some examples:

To execute all 30 benchmarks against `gcc`, `clang`, `icc`, `rose`, and seven polyhedral compilers in parallel, run:
```
cd polybench
./execute_polyhedral.sh
```


To execute the 2mm benchmark against `gcc`, `clang`, `icc`, `rose`, and seven polyhedral compilers in sequential, run:
```
cd polybench
./execute_polyhedral_syn.sh -bench 2mm
```

More options are available, check the first lines of the script for more information.

The results can be found in the `/results/output_data`  repository in the docker machine, or in the `docker/output_data` repository of the host.
