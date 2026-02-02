#!/bin/bash

#VERSION=$1
#VERSION="final"
VERSION="quick"

# IOR location
BENCHMARK="/home/krajara/repo/ior-4.0.0/src/ior"
#Machine File
MACH_FILE="/home/krajara/mpi/mf_mn.txt"
#MACH_FILE="/home/krajara/mpi/mf.txt"
#MACH_FILE="/home/krajara/mpi/mf_sn.txt"

#IOR Sequential File Per Process - Create and Read 

# Output File Prefix
BASE_OUTPUT_FILE="iorfppdioseq7"
#File Size in GiB
#AGG_FSIZE="512"
AGG_FSIZE="128"
#File Size in MiB
#AGG_FSIZE="1024"
#Minimum IO Size in KiB
MIN_IO_SIZE=2048
#MIN_IO_SIZE=8192
#Maximum IO Size in KiB
MAX_IO_SIZE=2048
#MAX_IO_SIZE=8192
#Number of Iterations
MAX_ITER=1
#MAX_ITER=2
#SLEEP time in seconds
SLEEPT=2

run_IOR_seq () {

	#Output of each Run saved to Result File
	local RESULT_FILE_WR="/home/krajara/benchmarks/ior/results/$VERSION/IOR_Seq_Scaling_Clients_with_DIO_`date +%F-%T`.txt"
	#local RESULT_FILE_WR="/home/krajara/benchmarks/ior/results/$VERSION/IOR_Seq_Single_Client_with_DIO_`date +%F-%T`.txt"
	# Output Directory
	local OUTPUT_DIR="/redfs/ior_out"
	#local OUTPUT_DIR="/redfs/ior_scaling_out_dir1"
	
	touch $RESULT_FILE_WR

	# Perform write and read on new file
	#for np in 1 2 4 8 16 32 64
	for np in 2
	#for np in 256 384 
	#for np in 64 128 160 192 224 256 
  	do
  		for ((io_sz=$MIN_IO_SIZE; io_sz <= $MAX_IO_SIZE; io_sz *= 8))
		do

			fsize=$((AGG_FSIZE/np))
			#fsize=$AGG_FSIZE	
			OUTPUT_FILE=$BASE_OUTPUT_FILE"-"$np"-"$io_sz
			sleep $SLEEPT

			echo "***IOR Scaling Test: Sequential  " >> $RESULT_FILE_WR
			echo "------------------------------------" >> $RESULT_FILE_WR
			date >> $RESULT_FILE_WR
			echo "# Iteration: $MAX_ITER Process_Count: $np, I/O Request Size: '$io_sz'k" 2>&1 | tee -a  $RESULT_FILE_WR 
			
			# File Size in GiB - O_DIRECT
			echo "mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -a POSIX -d 5 -C -g -w -r -e -F --posix.odirect -t '$io_sz'k -b '$fsize'g -o $OUTPUT_DIR/$OUTPUT_FILE" 2>&1 | tee -a $RESULT_FILE_WR
			mpirun -f $MACH_FILE -n $np $BENCHMARK -i $MAX_ITER -a POSIX -d 5 -C -g -w -r -e -F --posix.odirect -t "$io_sz"k -b "$fsize"g -o $OUTPUT_DIR/$OUTPUT_FILE 2>&1 | tee -a $RESULT_FILE_WR
			
			echo "------------------------------------" >> $RESULT_FILE_WR
			sleep $SLEEPT
		done
	done

}

echo "Launching IOR Seq"
run_IOR_seq
sleep $SLEEPT
