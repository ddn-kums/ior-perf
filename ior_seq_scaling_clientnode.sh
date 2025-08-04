#!/bin/bash

#VERSION=$1
#VERSION="final"
#VERSION="quick"
VERSION="test"

# IOR location
BENCHMARK="/work/kums/benchmarks/ior/ior-4.0.0/src/ior"
#Machine File
#MACH_FILE="/work/kums/benchmarks/mpi/mf_mn.txt"
MACH_FILE="/work/kums/benchmarks/mpi/mf_sn.txt"

#IOR Sequential File Per Process - Create and Read 

# Output File Prefix
OUTPUT_FILE="iorfppseq1"
#File Size in GiB
#AGG_FSIZE="768"
#AGG_FSIZE="128"
AGG_FSIZE="1"
#Minimum IO Size in KiB
MIN_IO_SIZE=1024
#MIN_IO_SIZE=8192
#Maximum IO Size in KiB
MAX_IO_SIZE=1024
#MAX_IO_SIZE=8192
#Number of Iterations
MAX_ITER=3
MAX_ITER=2
#Maximum Number of MPI proceses
MAX_NP=1
#SLEEP time in seconds
SLEEPT=5

run_IOR_seq () {

	#Output of each Run saved to Result File
	local RESULT_FILE_WR="/work/kums/benchmarks/ior/results/$VERSION/IOR_Seq_Scaling_Clients_with_SingleProcPerNode_`date +%F-%T`.txt"
	#local RESULT_FILE_WR="/work/kums/benchmarks/ior/results/$VERSION/IOR_Seq_ALL_Clients_with_ScalingProcPerNode_`date +%F-%T`.txt"
	#local RESULT_FILE_WR="/work/kums/benchmarks/ior/results/$VERSION/IOR_Seq_Single_Client_with_ScalingProcPerNode_`date +%F-%T`.txt"
	# Output Directory
	#local OUTPUT_DIR="/redfs/ior_out"
	local OUTPUT_DIR="/tmp/ior_out"
	
	#MPI machine file directory
	#local MPI_DIR=`dirname $MACH_FILE`
	#pushd $MPI_DIR

	touch $RESULT_FILE_WR

	# Perform write and read on new file
	#for np in 1 2 3 4 5 6
	#for np in 6 12 24 48
	#for np in 1 2 4 8
	for np in 1
  	do
  		for ((io_sz=$MIN_IO_SIZE; io_sz <= $MAX_IO_SIZE; io_sz *= 8))
		do

			#fsize=$((AGG_FSIZE/np))
			fsize=$AGG_FSIZE	
			
			echo "***IOR Scaling Test: Sequential  " >> $RESULT_FILE_WR
			echo "------------------------------------" >> $RESULT_FILE_WR
date >> $RESULT_FILE_WR
			echo "# Iteration: $MAX_ITER Process_Count: $np, I/O Request Size: '$io_sz'k" >> $RESULT_FILE_WR 
			# Keep File
			echo "mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -d 5 -C -k -g -w -r -e -F -t '$io_sz'k -b '$fsize'g -o $OUTPUT_DIR/$OUTPUT_FILE" >> $RESULT_FILE_WR
			mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -d 5 -C -k -g -w -r -e -F -t "$io_sz"k -b "$fsize"g -o $OUTPUT_DIR/$OUTPUT_FILE 2>&1 | tee -a $RESULT_FILE_WR
			
			# Delete file at the end of the run
			#echo "mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -d 5 -C -g -w -r -e -F -t '$io_sz'k -b '$fsize'g -o $OUTPUT_DIR/$OUTPUT_FILE" >> $RESULT_FILE_WR
			#mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -d 5 -C -g -w -r -e -F -t "$io_sz"k -b "$fsize"g -o $OUTPUT_DIR/$OUTPUT_FILE 2>&1 | tee -a $RESULT_FILE_WR
			echo "------------------------------------" >> $RESULT_FILE_WR

			sleep $SLEEPT
		done
	done
	#popd

}

echo "Launching IOR Seq"
run_IOR_seq
sleep $SLEEPT
