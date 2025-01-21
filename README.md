# General-purpose Polyhedral Compilers

This github repository contains the docker script to set the environment for seven general-purpose polyhedral compilers and build those
compilers in a Linux environment. Those seven polyhedral compilers are: Pluto, PoCC, Polly, Graphite, PolyOpt, PPCG, and Polygeist.

It also contains the PolyBench/C benchmarks to test them and measure the execution time of the resulting codes.
Currently, we only support the execution on CPU architectures.

### Steps to Build Docker Environment
This docker installation will occupy more than `50GB` of disk space, and take *some* time to build
(depending on the performance of your computer).
The complete sequential benchmarks will run in less than a day, the parallel ones are obviously faster.

The `docker` folder contains the Dockerfile and all the scripts to build the docker environment.
The complete list of commands to install it and run it are as follows:
```
git clone https://github.com/vincentloechner/PolyhedralCompilers.git
cd PolyhedralCompilers/docker
docker build -f Docker-polyhedral-src . -t polyhedral
docker run --volume $(pwd):/results -it --privileged polyhedral bash
```
Once the docker environment is set the docker machine with built polyhedral compilers can be invoked
ith the `docker run` command, you can adapt its invocation to your needs.
The polyhedral compiler's source files and their respective build `binaries` are found inside the docker.

### How to test Polyhedral Compilers
We included PolyBench/C - a set of 30 numerical benchmarks that has polyhedral nested loops (SCoPs). We have
two scripts `execute_polyhedral.sh` and `execute_polyhedral_syn.sh` to test the parallel and non-parallel execution
of polyhedral compilers. For example:

To execute all 30 benchmarks against `gcc`, `clang`, `icc`, `rose`, and seven polyhedral compilers in parallel, enter the docker and run:
```
cd polybench
./execute_polyhedral.sh
```


To execute the 2mm benchmark against `gcc`, `clang`, `icc`, `rose`, and seven polyhedral compilers in sequential, run:
```
cd polybench
./execute_polyhedral_syn.sh -bench 2mm
```

More options are available, check the first lines of the scripts for more information.

The results can be found in the `/results/output_data`  repository in the docker machine, or in the `docker/output_data` repository of the host.
