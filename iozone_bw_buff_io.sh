#!/bin/bash

#VERSION=$1
#VERSION="quick"
VERSION="final"

# iozone location
BENCHMARK="/work/kums/benchmarks/iozone/iozone"
#Machine File
MACH_FILE="/work/kums/benchmarks/iozone/scripts/mf.client"

#iozone Sequential File Per Process

# Output File Prefix
#File Size
#FSIZE="128g"
FSIZE="64g"
#Maximum IO Size in KiB
MAX_IO_SIZE=2048
MIN_IO_SIZE=2048
#Number of Iterations
#MAX_ITER=3
MAX_ITER=2
#SLEEP time in seconds
SLEEPT=1

run_iozone_seq () {

	#Output of each Run saved to Result File
	local RESULT_FILE_WR="/work/kums/benchmarks/iozone/results/$VERSION/iozone_bw_bufferedIO_WR_`date +%F-%T`.txt"
	
	sleep $SLEEPT

	touch $RESULT_FILE_WR

	export RSH=/usr/bin/ssh

	# Perform write and read 
	#for np in 1 2
	for np in 2
  	do
  		for ((io_sz=$MIN_IO_SIZE; io_sz <= $MAX_IO_SIZE; io_sz *= 4))
		do
			for ((iter=1; iter <= $MAX_ITER; iter++))
			do 
				echo "******* Parallel Iozone Scaling Test: Sequential  " >> $RESULT_FILE_WR
				echo "Benchmark started at: `date`" >> $RESULT_FILE_WR
				echo "# Iteration: $MAX_ITER Process_Count: $np, I/O Request Size: '$io_sz'k" >> $RESULT_FILE_WR 
				echo "$BENCHMARK -r '$io_sz'k -s $FSIZE -i 0 -i 1 -e -c -C -+u -+m $MACH_FILE -+n -t $np" >> $RESULT_FILE_WR
				$BENCHMARK -r "$io_sz"k -s $FSIZE -i 0 -i 1 -e -c -C -+u -+m $MACH_FILE -+n -t $np 2>&1 | tee -a $RESULT_FILE_WR

				echo "Benchmark completed at: `date`" >> $RESULT_FILE_WR
				sleep $SLEEPT
			done
		done
	done

}

echo "Launching iozone Seq"
run_iozone_seq
sleep $SLEEPT
