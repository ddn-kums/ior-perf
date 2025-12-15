#!/bin/bash

# Script usage: ./parse_results.sh -h
# Script sample  command line #1: ./parse_results.sh -f <results_file_to_parse> -s <yes|no> -n <NUM_CORES>
# Example: ./parse_results.sh -f /work/kums/red/redfs/results/final/parallel_redfs-bench_perf_result_write_1M_8_NO_2_1_2025-12-11-19\:27\:56.txt -s no -n 8

parse_result () {

	FNAME=$1
	NUM_CORES=$2
	CORE_SCALING=$3

	CORE_SCALING="${CORE_SCALING,,}"

	echo "Results File Name is: $FNAME, Number of Cores: $NUM_CORES, Scaling Core: $CORE_SCALING"
	
	if [[ "$CORE_SCALING" == "no" ]]; then
		#grep csv $FNAME | awk -v C="$NUM_CORES" -F ',' '{ if ($4 == C) { print $4; print $10; sum += $10; count++} } END { if (count > 0) printf "Core Count: %d TotalMBS: %.2f \n",  C, sum }'
		grep csv $FNAME | awk -v C="$NUM_CORES" -F ',' '{ if ($4 == C) { sum += $10; count++} } END { if (count > 0) printf "Core Count:%d:TotalMBS:%.2f \n",  C, sum }'
	elif [[ "$CORE_SCALING" == "yes" ]]; then
		for ((core_count=1; core_count <= NUM_CORES; core_count *=2));
		do
			#grep csv $FNAME | awk -v C="$core_count" -F ',' '{ if ($4 == C) { print $4; print $10; sum += $10; count++} } END { if (count > 0) printf "Core Count: %d TotalMBS: %.2f \n",  C, sum }'
			grep csv $FNAME | awk -v C="$core_count" -F ',' '{ if ($4 == C) { sum += $10; count++} } END { if (count > 0) printf "Core Count:%d:TotalMBS:%.2f \n",  C, sum }'
		done
	else
		echo "Invalid CORE_SCALING: $CORE_SCALING value"
		exit 1
	fi



}

while getopts f:n:s:h flag
do

        #echo "Flag: -$flag, Argument $OPTARG";

        case "${flag}" in
                f) RESULTS_FNAME=${OPTARG};;
		n) CORES=${OPTARG};;
		s) SCALING=${OPTARG};;
                h) echo "Usage:"
                        echo "-f: Results File Name"
			echo "-n: Number of Cores"
			echo "-s: Scaling Test"
                        echo "-h: help"
			exit 
                        ;;
                *) echo "Unrecognized Option"
			exit
			;;
        esac
done


parse_result $RESULTS_FNAME $CORES $SCALING
