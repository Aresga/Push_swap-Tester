#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Error handling
set -e

# Function to check requirements
check_requirements() {
    if ! command -v ruby >/dev/null 2>&1; then
        echo "Ruby is required but not installed."
        exit 1
    fi
}

# Function to generate random numbers
generate_numbers() {
    ruby -e "puts (1..$1).to_a.shuffle.join(' ')"
}

# Function to check leaks
check_leaks() {
    local pid=$1
    local program_name=$2
    sleep 0.1
    leaks $pid > leaks_log 2>&1
    if grep -q "leaks for" leaks_log; then
        echo -e "${RED}Memory leaks found in $program_name${NC}"
        cat leaks_log
        rm leaks_log
        return 1
    fi
    rm leaks_log
    return 0
}

# Function to test single case
test_single_case() {
    local size=$1
    local ARGS=$(generate_numbers $size)
    
    # Run push_swap with leak check
    ./push_swap $ARGS > ops.tmp &
    local push_swap_pid=$!
    check_leaks $push_swap_pid "push_swap"
    wait $push_swap_pid
    
    # Count operations
    local OP_COUNT=$(wc -l < ops.tmp | tr -d '[:space:]')
    
    # Run checker with leak check
    cat ops.tmp | ./checker_mac $ARGS > result.tmp &
    local checker_pid=$!
    check_leaks $checker_pid "checker_mac"
    wait $checker_pid
    
    local RESULT=$(cat result.tmp)
    rm ops.tmp result.tmp
    
    echo "$OP_COUNT $RESULT"
}

# Main test function
test_push_swap() {
    local size=$1
    local iterations=$2
    local total_ops=0
    local max_ops=0
    local min_ops=999999
    local failed=0
    local success=0
    
    echo -e "${BLUE}Testing $size numbers - $iterations iterations${NC}"
    echo "----------------------------------------"
    
    for ((i=1; i<=iterations; i++)); do
        local result=$(test_single_case $size)
        local ops=$(echo $result | cut -d' ' -f1)
        local status=$(echo $result | cut -d' ' -f2)
        
        # Update stats
        total_ops=$((total_ops + ops))
        [ $ops -gt $max_ops ] && max_ops=$ops
        [ $ops -lt $min_ops ] && min_ops=$ops
        
        if [ "$status" = "OK" ]; then
            success=$((success + 1))
            echo -e "Test $i: ${GREEN}OK${NC} - $ops operations"
        else
            failed=$((failed + 1))
            echo -e "Test $i: ${RED}KO${NC} - $ops operations"
        fi
    done
    
    # Print summary
    echo "----------------------------------------"
    echo -e "Successful: ${GREEN}$success${NC}"
    echo -e "Failed: ${RED}$failed${NC}"
    echo "Average ops: $((total_ops / iterations))"
    echo "Max ops: $max_ops"
    echo "Min ops: $min_ops"
    
    # Performance check
    if [ "$size" = "100" ]; then
        [ $max_ops -lt 700 ] && echo -e "${GREEN}✓ Meets requirement (<700)${NC}" || echo -e "${RED}✗ Exceeds limit (>700)${NC}"
    elif [ "$size" = "500" ]; then
        [ $max_ops -lt 5500 ] && echo -e "${GREEN}✓ Meets requirement (<5500)${NC}" || echo -e "${RED}✗ Exceeds limit (>5500)${NC}"
    fi
}

# Main execution
clear
check_requirements

echo "Push_swap Tester"
echo "================"

# Run tests
test_push_swap 100 5
echo
test_push_swap 500 5