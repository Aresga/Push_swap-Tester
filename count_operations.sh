#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to generate random numbers
generate_numbers() {
    local size=$1
    ruby -e "puts (1..$size).to_a.shuffle.join(' ')"
}

# Function to count operations
count_operations() {
    local file=$1
    grep -oE 'sa|sb|ss|pa|pb|ra|rb|rr|rra|rrb|rrr' "$file" | sort | uniq -c
}

# Function to test push_swap with n numbers
test_push_swap() {
    local size=$1
    local iterations=$2
    local total_operations=0
    local max_operations=0
    local min_operations=999999
    local failed_tests=0
    local successful_tests=0
    local operation_file="operations.txt"

    echo -e "${BLUE}Testing with $size numbers - $iterations iterations${NC}"
    echo "----------------------------------------"

    for ((i=1; i<=iterations; i++)); do
        # Generate random numbers
        ARGS=$(generate_numbers $size)
        
        # Run push_swap and save output
        ./push_swap $ARGS > "$operation_file"
        
        # Count number of operations
        OP_COUNT=$(wc -l < "$operation_file" | tr -d '[:space:]')
        
        # Run checker_mac
        RESULT=$(./checker_mac $ARGS < "$operation_file")
        
        # Update statistics
        total_operations=$((total_operations + OP_COUNT))
        if [ $OP_COUNT -gt $max_operations ]; then
            max_operations=$OP_COUNT
        fi
        if [ $OP_COUNT -lt $min_operations ]; then
            min_operations=$OP_COUNT
        fi
        
        # Check result
        if [ "$RESULT" == "OK" ]; then
            echo -e "Test $i: ${GREEN}OK${NC} - Operations: $OP_COUNT"
            successful_tests=$((successful_tests + 1))
        else
            echo -e "Test $i: ${RED}KO${NC} - Operations: $OP_COUNT"
            failed_tests=$((failed_tests + 1))
        fi

        # Count and display operation frequencies
        echo -e "${YELLOW}Operation frequencies for test $i:${NC}"
        count_operations "$operation_file"
		echo -e "${YELLOW}----------------------------------------${NC}"
    done

    echo "----------------------------------------"
    echo -e "${BLUE}Total operations: ${NC}$total_operations"
    echo -e "${BLUE}Average operations: ${NC}$((total_operations / iterations))"
    echo -e "${BLUE}Max operations: ${NC}$max_operations"
    echo -e "${BLUE}Min operations: ${NC}$min_operations"
    echo -e "${GREEN}Successful tests: ${NC}$successful_tests"
    echo -e "${RED}Failed tests: ${NC}$failed_tests"
}

# Run tests
test_push_swap 100 5
test_push_swap 500 5