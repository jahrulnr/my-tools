#!/bin/bash

# Function to get CPU cores
get_cpu_cores() {
    if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
        cores=$(nproc)
    else
        cores=$(echo "$NUMBER_OF_PROCESSORS")
    fi
    echo "$cores"
}

# Function to get free memory in MB
get_free_memory() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        free_memory=$(grep MemFree /proc/meminfo | awk '{print $2}')
        free_memory=$((free_memory / 1024))
    else
        free_memory=$(wmic OS get FreePhysicalMemory | grep -Eo '[0-9]+')
        free_memory=$((free_memory / 1024))
    fi
    echo "$free_memory"
}

# Function to calculate average PHP-FPM worker memory in MB
get_worker_memory() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        process_memory=$(ps -eo size,command | grep 'php-fpm: pool' | awk '{sum+=$1; count++} END {if (count>0) print sum/count/1024; else print 128}')
    else
        process_memory=128  # Default if calculation not available
    fi
    echo "$process_memory"
}

cpu_cores=$(get_cpu_cores)
free_memory=$(get_free_memory)
worker_memory=$(get_worker_memory)

# Reserve 10% of memory for the system
memory_reserve=$(awk "BEGIN {print $free_memory * 0.1}")
max_children=$(awk "BEGIN {print ($free_memory - $memory_reserve) / $worker_memory}")

echo "pm.max_children = $max_children"
echo "pm.start_servers = $(awk "BEGIN {print int(($max_children * 0.25) < ($cpu_cores * 4) ? ($max_children * 0.25) : ($cpu_cores * 4))}")"
echo "pm.min_spare_servers = $(awk "BEGIN {print int(($max_children * 0.25) < ($cpu_cores * 2) ? ($max_children * 0.25) : ($cpu_cores * 2))}")"
echo "pm.max_spare_servers = $(awk "BEGIN {print int(($max_children * 0.75) < ($cpu_cores * 4) ? ($max_children * 0.75) : ($cpu_cores * 4))}")"
