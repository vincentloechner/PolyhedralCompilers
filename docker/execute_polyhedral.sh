#!/bin/bash

#export C_INCLUDE_PATH=/usr/local/lib/polyhedral/clang-llvm/projects/openmp/runtime/src/
export LD_LIBRARY_PATH=/usr/local/lib/:/usr/local/lib/polyhedral/boost/boost-install/lib/:/usr/local/lib/polyhedral/gcc/gcc-install/lib:/usr/local/lib/polyhedral/gcc/gcc-install/lib64/:/usr/local/lib/polyhedral/isl/isl-install/lib/:/usr/local/lib/polyhedral/clang-llvm/lib/:/usr/local/lib/polyhedral/rose/rose-install/lib/:/usr/local/lib/polyhedral/gcc/gcc-install/lib/::/usr/local/lib/polyhedral/boost/boost-install/lib/:/usr/local/lib/polyhedral/rose/rose-install/lib/:$LD_LIBRARY_PATH

gcc="true"
clang="true"
icc="true"
polly="true"
graph="true"
rose="true"
polyopt="true"
pluto1="true"
pluto2="true"
pluto3="true"
pocc="true"
ppcg="true"
bench="all"
flag="-1"
polygeist="true"
debug="false"

gcc_bin="/usr/local/lib/polyhedral/gcc/gcc-install/bin/gcc"
clang_bin="/usr/local/lib/polyhedral/clang-llvm/bin/clang"
icc_bin="/opt/intel/oneapi/compiler/2021.4.0/linux/bin/intel64/icc"

#reading the command line arguments
while echo $1 | grep -q ^-; do
    # Evaluating a user entered string!
    # Red flags!!!  Don't do this
    eval $( echo $1 | sed 's/^-//' )=$2
	echo "$( echo $1 | sed 's/^-//' )=$2"
    shift
    shift
done

if [ "$bench" = "2mm" ] || [ "$bench" = "3mm" ] || [ "$bench" = "atax" ] || [ "$bench" = "bicg" ] || [ "$bench" = "doitgen" ] || [ "$bench" = "mvt" ]; then
	BENCH_PATH="linear-algebra/kernels"
	flag="0"
elif [ "$bench" = "gemm" ] || [ "$bench" = "gemver" ] || [ "$bench" = "gesummv" ] || [ "$bench" = "symm" ] || [ "$bench" = "syr2k" ] || [ "$bench" = "syrk" ] || [ "$bench" = "trmm" ]; then
	BENCH_PATH="linear-algebra/blas"
	flag="0"
elif [ "$bench" = "cholesky" ] || [ "$bench" = "durbin" ] || [ "$bench" = "gramschmidt" ] || [ "$bench" = "lu" ] || [ "$bench" = "ludcmp" ] || [ "$bench" = "trisolv" ]; then
	BENCH_PATH="linear-algebra/solvers"
	flag="0"
elif [ "$bench" = "correlation" ] || [ "$bench" = "covariance" ]; then
	BENCH_PATH="dataminings"
	flag="0"
elif [ "$bench" = "deriche" ] || [ "$bench" = "nussinov" ] || [ "$bench" = "floyd-warshall" ]; then
	BENCH_PATH="medley"
	flag="0"
elif [ "$bench" = "adi" ] || [ "$bench" = "jacobi-1d" ] || [ "$bench" = "fdtd-2d" ] || [ "$bench" = "jacobi-2d" ] || [ "$bench" = "heat-3d" ] || [ "$bench" = "seidel-2d" ]; then
	BENCH_PATH="stencils"
	flag="0"
elif [ "$bench" = "linear-algebra/kernels" ] || [ "$bench" = "linear-algebra/blas" ] || [ "$bench" = "linear-algebra/solvers" ] || [ "$bench" = "datamining" ] || [ "$bench" = "medley" ] || [ "$bench" = "stencils" ]; then
	flag="1"
elif [ "$bench" = "all" ]; then
	flag="2"
else
	echo 'please input correct benchmark'
fi

function run()
{ 
	echo "Running benchmark $bench:"
	echo " "

	if [ "$gcc" = "true" ]; then
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "gcc -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_gcc.out
		done 
		rm ./"$bench"_time
	fi

	if [ "$clang" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "clang -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
	
		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_clang.out
		done
		rm ./"$bench"_time
	fi

	if [ "$icc" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "icc -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
	
		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_icc.out
		done
		rm ./"$bench"_time
	fi
	
	if [ "$rose" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "rose-compiler -ffast-math -march=native -fopenmp -O3 -I /usr/local/lib/polyhedral/rose/rose-install/include/rose/ -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
		
		/usr/local/lib/polyhedral/rose/rose-install/bin/rose-compiler -ffast-math -march=native -fopenmp -O3 -I /usr/local/lib/polyhedral/rose/rose-install/include/rose/ -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm > garbage.txt
		echo "Rose:"
		for exe in 1
	do
		 ./"$bench"_time 2> ./output_data/"$bench"_rose.out
		done
		rm ./"$bench"_time
	fi

	if [ "$polly" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "clang -O3 -fopenmp -ffast-math -march=native -mprefer-vector-width=256 -mllvm -polly -mllvm -polly-parallel -lgomp -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
	
		${clang_bin} -O3 -fopenmp -ffast-math -march=native -mprefer-vector-width=256 -mllvm -polly -mllvm -polly-parallel -lgomp -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "polly:"
		for exe in 1
		do
		 ./"$bench"_time 2> ./output_data/"$bench"_polly.out
		done
		rm ./"$bench"_time
	fi

	if [ "$graph" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "gcc -fgraphite -O3 -floop-parallelize-all -ffast-math -march=native -fopenmp -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
	
		${gcc_bin} -fgraphite -O3 -floop-parallelize-all -ffast-math -march=native -fopenmp -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "graphite:"
		for exe in 1
		do
		 ./"$bench"_time 2> ./output_data/"$bench"_graphite.out
		done
		rm ./"$bench"_time
	fi

	if [ "$polyopt" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "PolyRose -ffast-math -march=native --polyopt-fixed-tiling --polyopt-scalar-privatization --polyopt-safe-math-func -fopenmp -O3 -I /usr/local/lib/polyhedral/rose/rose-install/include/rose/ -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm"
		fi
	
		/usr/local/lib/polyhedral/rose/rose/projects/PolyOpt2/src/PolyRose -ffast-math -march=native --polyopt-fixed-tiling --polyopt-scalar-privatization --polyopt-safe-math-func -fopenmp -O3 -I /usr/local/lib/polyhedral/rose/rose-install/include/rose/ -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm > garbage.txt
		echo "PolyOpt:"
		for exe in 1
		do
		 ./"$bench"_time 2> ./output_data/"$bench"_poly_opt.out
		done
		rm ./"$bench"_time
	fi

	if [ "$pluto1" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "polycc --tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c"
		fi
	
		timeout 30m /usr/local/lib/polyhedral/pluto/polycc --tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c > garbage.txt
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(--tile) gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_tile_gcc.out
		done
		rm ./"$bench"_time

		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(--tile) clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_tile_clang.out
		done
		rm ./"$bench"_time

		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(--tile) icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_tile_icc.out
		done
		rm ./"$bench"_time

		mv ./"$bench".pluto.c ./output_data/
		mv ./"$bench".pluto.cloog ./output_data/
	fi

	if [ "$pluto2" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "polycc --l2tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c"
		fi
	
		timeout 30m  /usr/local/lib/polyhedral/pluto/polycc --l2tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c > garbage.txt
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(2l-tile) gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_2l-tile_gcc.out
		done
		rm ./"$bench"_time

		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(2l-tile) clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_2l-tile_clang.out
		done
		rm ./"$bench"_time

		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(2l-tile) icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_2l-tile_icc.out
		done
		rm ./"$bench"_time

		mv ./"$bench".pluto.c ./output_data/
		mv ./"$bench".pluto.cloog ./output_data/
	fi

	if [ "$pluto3" = "true" ]; then	
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "polycc --diamond-tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c"
		fi
	
		timeout 30m /usr/local/lib/polyhedral/pluto/polycc --diamond-tile  --parallel --smartfuse --prevector "$BENCH_PATH"/"$bench"/"$bench".c > garbage.txt
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(diamond-tile) gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_diamond-tile_gcc.out
		done
		rm ./"$bench"_time

		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(diamond-tile) clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_diamond-tile_clang.out
		done
		rm ./"$bench"_time

		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c ./"$bench".pluto.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "Pluto(diamond-tile) icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pluto_diamond-tile_icc.out
		done
		rm ./"$bench"_time

		mv ./"$bench".pluto.c ./output_data
		mv ./"$bench".pluto.cloog ./output_data
	fi

	if [ "$pocc" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "pocc --pluto-tile --pluto-parallel --pragmatizer --vectorizer --pluto-scalpriv --pluto-fuse smartfuse "$BENCH_PATH"/"$bench"/"$bench".c"
		fi
	
		/usr/local/lib/polyhedral/pocc/bin/pocc --pluto-tile --pluto-parallel --pragmatizer --vectorizer --pluto-scalpriv --pluto-fuse smartfuse "$BENCH_PATH"/"$bench"/"$bench".c > garbage.txt
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".pocc.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "PoCC gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pocc_gcc.out
		done
		rm ./"$bench"_time

		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".pocc.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "PoCC clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pocc_clang.out
		done
		rm ./"$bench"_time

		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$BENCH_PATH"/"$bench"/"$bench".pocc.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "PoCC icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_pocc_icc.out
		done
		rm ./"$bench"_time
	fi

	if [ "$ppcg" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "ppcg --tile --target=c --openmp "$BENCH_PATH"/"$bench"/"$bench".c"
		fi
	
		/usr/local/lib/polyhedral/ppcg/ppcg --tile --target=c --openmp "$BENCH_PATH"/"$bench"/"$bench".c -I ./utilities/
		
		${gcc_bin} -O3 -fopenmp -ffast-math -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$bench".ppcg.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "ppcg gcc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_ppcg_gcc.out
		done
		rm ./"$bench"_time

		${clang_bin} -O3 -fopenmp -march=native -ffast-math -mprefer-vector-width=256 -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$bench".ppcg.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "ppcg clang:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_ppcg_clang.out
		done
		rm ./"$bench"_time

		${icc_bin} -fopenmp -O3 -fp-model=fast -march=native -I utilities -I "$BENCH_PATH"/"$bench" utilities/polybench.c "$bench".ppcg.c -DPOLYBENCH_TIME -DEXTRALARGE_DATASET -DPOLYBENCH_DUMP_ARRAYS  -DPOLYBENCH_USE_RESTRICT -DPOLYBENCH_USE_SCALAR_LB -DPOLYBENCH_USE_C99_PROTO -o "$bench"_time -lm
		echo "ppcg icc:"
		for exe in 1
		do
			./"$bench"_time 2> ./output_data/"$bench"_ppcg_icc.out
		done
		rm ./"$bench"_time
	fi
	
	if [ "$polygeist" = "true" ]; then
	
		if [ "$debug" = "true" ]; then
			echo ' '
			echo "mlir-clang -march=native -I utilities -D POLYBENCH_TIME -D EXTRALARGE_DATASET -D POLYBENCH_NO_FLUSH_CACHE -D POLYBENCH_DUMP_ARRAYS"$BENCH_PATH"/"$bench"/"$bench".c  -o "$bench"_time_in.mlir"
			echo "polymer-opt --demote-loop-reduction --extract-scop-stmt --pluto-opt='parallelize=1' --inline --canonicalize "$bench"_time_in.mlir 2>/dev/null > "$bench"_time.out.mlir"
			echo "mlir-opt -mem2reg -detect-reduction -mem2reg -canonicalize -affine-parallelize -lower-affine -convert-scf-to-openmp -convert-scf-to-std -convert-openmp-to-llvm "$bench"_time.out.mlir | /usr/local/lib/polyhedral/mlir-clang/build/bin/mlir-translate -mlir-to-llvmir > "$bench"_mlir.ll"
			echo "clang utilities/polybench.c -O3 -march=native ./"$bench"_mlir.ll -o "$bench".out -lm -fopenmp -D POLYBENCH_TIME -D POLYBENCH_NO_FLUSH_CACHE -D EXTRALARGE_DATASET -D POLYBENCH_DUMP_ARRAYS"
		fi
	
		export C_INCLUDE_PATH_BK=$C_INCLUDE_PATH
		export LD_LIBRARY_PATH_BK=$LD_LIBRARY_PATH
		
		export C_INCLUDE_PATH=/usr/local/lib/polyhedral/mlir-clang/build/projects/openmp/runtime/src/
		export LD_LIBRARY_PATH=/usr/local/lib/polyhedral/mlir-clang/build/lib/:/usr/local/lib/polyhedral/polymer/build/pluto/lib/:/usr/local/lib/polyhedral/polymer/build/lib:/usr/local/lib/polyhedral/polymer/llvm/build/lib/:$LD_LIBRARY_PATH
	
	
		/usr/local/lib/polyhedral/mlir-clang/build/bin/mlir-clang -march=native -I utilities -D POLYBENCH_TIME -D EXTRALARGE_DATASET -D POLYBENCH_NO_FLUSH_CACHE -D POLYBENCH_DUMP_ARRAYS "$BENCH_PATH"/"$bench"/"$bench".c  -o "$bench"_time_in.mlir
		/usr/local/lib/polyhedral/polymer/build/bin/polymer-opt --demote-loop-reduction --extract-scop-stmt --pluto-opt='parallelize=1' --inline --canonicalize "$bench"_time_in.mlir 2>/dev/null > "$bench"_time.out.mlir
		/usr/local/lib/polyhedral/mlir-clang/build/bin/mlir-opt -mem2reg -detect-reduction -mem2reg -canonicalize -affine-parallelize -lower-affine -convert-scf-to-openmp -convert-scf-to-std -convert-openmp-to-llvm "$bench"_time.out.mlir | /usr/local/lib/polyhedral/mlir-clang/build/bin/mlir-translate -mlir-to-llvmir > "$bench"_mlir.ll
		/usr/local/lib/polyhedral/mlir-clang/build/bin/clang utilities/polybench.c -O3 -mprefer-vector-width=256 -march=native ./"$bench"_mlir.ll -o "$bench".out -lm -fopenmp -D POLYBENCH_TIME -D POLYBENCH_NO_FLUSH_CACHE -D EXTRALARGE_DATASET -D POLYBENCH_DUMP_ARRAYS
		
		echo "polygeist:"
		for exe in 1
		do
			./"$bench".out 2> ./output_data/"$bench"_polygeist.out
		done
		rm ./"$bench".out
		
		export C_INCLUDE_PATH=$C_INCLUDE_PATH_BK
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BK
	fi
}

if [ "$flag" = "0" ]; then
	run
fi

if [ "$flag" = "1" ] || [ "$flag" = "2" ]; then
	if [ "$bench" = "linear-algebra/kernels" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("atax" "2mm" "3mm" "bicg" "doitgen" "mvt")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="linear-algebra/kernels"
			bench="$i"
			run
			echo ' '
		done
	fi
	if [ "$bench" = "linear-algebra/blas" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("gemm" "gemver" "gesummv" "symm" "syr2k" "syrk" "trmm")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="linear-algebra/blas"
			bench="$i"
			run
			echo ' '
		done	
	fi
	if [ "$bench" = "linear-algebra/solvers" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("cholesky" "durbin" "gramschmidt" "lu" "ludcmp" "trisolv")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="linear-algebra/solvers"
			bench="$i"
			run
			echo ' '
		done
	fi	
	if [ "$bench" = "datamining" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("correlation" "covariance")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="datamining"
			bench="$i"
			run
			echo ' '
		done	
	fi
	if [ "$bench" = "medley" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("deriche" "nussinov" "floyd-warshall")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="medley"
			bench="$i"
			run
			echo ' '
		done	
	fi	
	if [ "$bench" = "stencils" ] || [ "$flag" = "2" ]; then
		declare -a arrayben=("adi" "jacobi-1d" "seidel-2d" "fdtd-2d" "jacobi-2d" "heat-3d")
		for i in "${arrayben[@]}"
		do
			BENCH_PATH="stencils"
			bench="$i"
			run
			echo ' '
		done	
	fi
fi
