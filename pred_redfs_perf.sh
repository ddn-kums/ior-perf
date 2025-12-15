#!/bin/bash

#Benchmark
BENCHMARK="/opt/ddn/red/bin/redfs_bench_tool"
#Run Type
MODE="final"
#MODE="quick"
#Result Dir
RESULT_DIR="/work/kums/red/redfs/results/$MODE"
#Result File
BASE_RESULT_FILE="$RESULT_DIR/parallel_redfs-bench_perf_result"
#BASE_RESULT_FILE="$RESULT_DIR/skipio_parallel_redfs-bench_perf_result"
#SLEEPT in seconds
SLEEPT=1
#LONG_SLEEPT=10
LONG_SLEEPT=1
# NUMBER OF ITERATIONS
NUM_ITER=3
#NUM_ITER=1
#FS IO SIZES
FS_IOSIZE_LIST="1M"
# FS Operations
#FS_OPS="write read"
FS_OPS="write"
# IO Counts
IO_COUNT=100
# Client Nodes
FS_CLIENTS_FILE="/work/kums/red/redfs/scripts/all_client_nodes.txt"
FS_CLIENTS_FILE_TMP="/work/kums/red/redfs/scripts/all_client_nodes.tmp"
NODE_COUNT=6
# COREMASK
COREMASK="[1-8]"
NUM_CORES=8
SCALING_CORES="NO"
#SCALING_CORES="YES"
# redfs_bench tool Output Directory
BASE_OUTPUT_DIR="/mnt/redfs/testdir18"
#BASE_OUTPUT_DIR="/mnt/scratchfs_dataloss/dl_testdir2"
# redfs_bench tool output file
BASE_FNAME="lf1"

# redfs_bench Benchmark with static core count
run_redfs_bench_tool_static_cores_parallel_perf () {

	TESTNAME=$1
	ITER=$2
	IO_SIZE=$3
	NC=$4
	CLIENT_NL=$5


	RESULT_FILE=$BASE_RESULT_FILE"_"$TESTNAME"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$NC"_"$ITER"_`date +%F-%T`.txt"
	OUTPUT_DIR=$BASE_OUTPUT_DIR"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$ITER


	if [ -d "$OUTPUT_DIR" ] && [[ "$TESTNAME" == "read" ]]; 
	then
		echo "Directory $OUTPUT_DIR exists and performing $TESTNAME operation" 2>&1 | tee -a $RESULT_FILE
	elif [ ! -d "$OUTPUT_DIR" ] && [[ "$TESTNAME" == "write" ]];
	then
		echo "Creating Directory $OUTPUT_DIR" 2>&1 | tee -a $RESULT_FILE
		
		mkdir -p $OUTPUT_DIR
		if [ $? -eq 0 ]; then
			echo "mkdir -p $OUTPUT_DIR succeeded"
		else
			echo "mkdir -p $OUTPUT_DIR failed" 
			exit 1
		fi
		sleep $SLEEPT
	else 
		echo "Error with $TESTNAME for $OUTPUT_DIR"
		exit 1
	fi
	
	OUTPUT_FNAME=$OUTPUT_DIR"/"$BASE_FNAME"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$NC"_"$ITER

	TESTNAME="${TESTNAME,,}"

	echo "Start of redfs_bench_tool Test: $TESTNAME, Node Count: $NC, IO Size: $IO_SIZE, Num Cores: $NUM_CORES, Scaling Cores: $SCALING_CORES, Iteration: $ITER,  time: `date`" 2>&1 | tee -a $RESULT_FILE
	echo "Client Node List: $CLIENT_NL" 2>&1 | tee -a $RESULT_FILE

	if [[ "$TESTNAME" == "write" ]]; then
		echo "pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -w -c $IO_COUNT -m $COREMASK $OUTPUT_FNAME" 2>&1 | tee -a $RESULT_FILE
		pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -w -c $IO_COUNT -m $COREMASK $OUTPUT_FNAME 2>&1 | tee -a $RESULT_FILE
	elif [[ "$TESTNAME" == "read" ]]; then
		echo "pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -c $IO_COUNT -m $COREMASK $OUTPUT_FNAME" 2>&1 | tee -a $RESULT_FILE
		pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -c $IO_COUNT -m $COREMASK $OUTPUT_FNAME 2>&1 | tee -a $RESULT_FILE
	else
		echo "Unsupported Test Operation: $TESTNAME"
		exit 1
	fi


	echo "End of redfs_bench_tool Test: $TESTNAME, Node Count: $NC, IO Size: $IO_SIZE, Num Cores: $NUM_CORES, Scaling Cores: $SCALING_CORES, Iteration: $ITER,  time: `date`" 2>&1 | tee -a $RESULT_FILE
	sleep $LONG_SLEEPT
	
}

# redfs_bench Benchmark with scaling core counts
run_redfs_bench_tool_scaling_cores_parallel_perf () {

	TESTNAME=$1
	ITER=$2
	IO_SIZE=$3
	NC=$4
	CLIENT_NL=$5

	RESULT_FILE=$BASE_RESULT_FILE"_"$TESTNAME"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$NC"_"$ITER"_`date +%F-%T`.txt"

	for((cores=1; cores <= $NUM_CORES; cores*=2));
	do
		OUTPUT_DIR=$BASE_OUTPUT_DIR"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$cores"_"$ITER

		if [ -d "$OUTPUT_DIR" ] && [[ "$TESTNAME" == "read" ]]; 
		then
			echo "Directory $OUTPUT_DIR exists and performing $TESTNAME operation" 2>&1 | tee -a $RESULT_FILE
		elif [ ! -d "$OUTPUT_DIR" ] && [[ "$TESTNAME" == "write" ]];
		then
			echo "Creating Directory $OUTPUT_DIR" 2>&1 | tee -a $RESULT_FILE
		
			mkdir -p $OUTPUT_DIR
			if [ $? -eq 0 ]; then
				echo "mkdir -p $OUTPUT_DIR succeeded"
			else
				echo "mkdir -p $OUTPUT_DIR failed" 
				exit 1
			fi
			sleep $SLEEPT
		else 
			echo "Error with $TESTNAME for $OUTPUT_DIR"
			exit 1
		fi
	
		OUTPUT_FNAME=$OUTPUT_DIR"/"$BASE_FNAME"_"$IO_SIZE"_"$NUM_CORES"_"$SCALING_CORES"_"$NC"_"$ITER

		TESTNAME="${TESTNAME,,}"

		if [[ $cores -eq 1 ]]; then
			SCALING_COREMASK="[1]"
		else
			SCALING_COREMASK="[1-$cores]"
		fi

		echo "Start of redfs_bench_tool Test: $TESTNAME, Node Count: $NC, IO Size: $IO_SIZE, Num Cores: $NUM_CORES, Scaling Cores: $SCALING_CORES, Scaling Coremask: $SCALING_COREMASK, Iteration: $ITER,  time: `date`" 2>&1 | tee -a $RESULT_FILE
		echo "Client Node List: $CLIENT_NL" 2>&1 | tee -a $RESULT_FILE

		if [[ "$TESTNAME" == "write" ]]; then
			echo "pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -w -c $IO_COUNT -m $SCALING_COREMASK $OUTPUT_FNAME" 2>&1 | tee -a $RESULT_FILE
			pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -w -c $IO_COUNT -m $SCALING_COREMASK $OUTPUT_FNAME 2>&1 | tee -a $RESULT_FILE
		elif [[ "$TESTNAME" == "read" ]]; then
			echo "pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -c $IO_COUNT -m $SCALING_COREMASK $OUTPUT_FNAME" 2>&1 | tee -a $RESULT_FILE
			pdsh -w $CLIENT_NL $BENCHMARK -b $IO_SIZE --direct -c $IO_COUNT -m $SCALING_COREMASK $OUTPUT_FNAME 2>&1 | tee -a $RESULT_FILE
		else
			echo "Unsupported Test Operation: $TESTNAME"
			exit 1
		fi

		echo "End of redfs_bench_tool Test: $TESTNAME, Node Count: $NC, IO Size: $IO_SIZE, Num Cores: $NUM_CORES, Scaling Cores: $SCALING_CORES, Scaling Coremask: $SCALING_COREMASK, Iteration: $ITER,  time: `date`" 2>&1 | tee -a $RESULT_FILE

		sleep $LONG_SLEEPT
	done
	
}

# Start of redfs_bench_tool benchmarking
echo "redfs_bench_tool Benchmarking"
mkdir -p $RESULT_DIR

for ((iter=1; iter <= $NUM_ITER; iter++))
do
	for io_size in $FS_IOSIZE_LIST
	do
		for ops in $FS_OPS
		do
			#for((nc=1; nc <=$NODE_COUNT; nc++))
			#for nc in 1 6
			for nc in 2 
			do
				CLIENT_NODE_LIST=""
						
				head -$nc $FS_CLIENTS_FILE > $FS_CLIENTS_FILE_TMP
				while read -r line; do
					CLIENT_NODE_LIST+=$line
				done < "$FS_CLIENTS_FILE_TMP"

				CLIENT_NODE_LIST="${CLIENT_NODE_LIST::-1}"
				echo $CLIENT_NODE_LIST

				if [[ "$SCALING_CORES" == "NO" ]]; then
					echo "invoking Non-Scaling Cores and parallel redfs_bench_tool run for node count: $nc"
					run_redfs_bench_tool_static_cores_parallel_perf $ops $iter $io_size $nc $CLIENT_NODE_LIST
				elif [[ "$SCALING_CORES" == "YES" ]]; then
					echo "invoking Scaling Cores and parallel redfs_bench_tool run for node count: $nc"
					run_redfs_bench_tool_scaling_cores_parallel_perf $ops $iter $io_size $nc $CLIENT_NODE_LIST
				else
					echo "Unsupported Scaling Cores mode: $SCALING_CORES"
					exit 1
				fi
				sleep $LONG_SLEEPT

			done
		done
	done
done
