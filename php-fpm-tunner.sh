#!/bin/bash

# Variables
memory_limit=512  # Set memory limit in MB, aligning with php.ini's `memory_limit`
cpu_cores=$(nproc)

# Function to get free system memory in MB
get_free_memory() {
    free_memory=$(grep MemFree /proc/meminfo | awk '{print $2}')
    echo $((free_memory / 1024))  # Convert to MB
}

# Calculate maximum children and other PHP-FPM tuning values
free_memory=$(get_free_memory)
memory_reserve=$((free_memory / 10))
max_children=$(( (free_memory - memory_reserve) / memory_limit ))

# Output recommended settings
echo "pm.max_children = $max_children"
echo "pm.start_servers = $(awk "BEGIN {print int(($max_children * 0.25) < ($cpu_cores * 4) ? ($max_children * 0.25) : ($cpu_cores * 4))}")"
echo "pm.min_spare_servers = $(awk "BEGIN {print int(($max_children * 0.25) < ($cpu_cores * 2) ? ($max_children * 0.25) : ($cpu_cores * 2))}")"
echo "pm.max_spare_servers = $(awk "BEGIN {print int(($max_children * 0.75) < ($cpu_cores * 4) ? ($max_children * 0.75) : ($cpu_cores * 4))}")"

