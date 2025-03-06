#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test error cases
test_error_cases() {
    echo -e "\n${BLUE}Testing Error Cases${NC}"
    echo "----------------------------------------"

    # Array of test cases that should show "Error"
    declare -a ERROR_CASES=(
        "2147483648"           # Greater than INT_MAX
        "-2147483649"         # Less than INT_MIN
        "1 2 3 3"            # Duplicates
        "1 2 abc"            # Non-numeric
        "1 2 2147483648"     # Mix with INT_MAX+1
        "1 2 +2147483648"    # With plus sign
        "1 2 3 2"           # Duplicate not adjacent
        "1 2 3 +"           # Invalid sign
        "1 2 3 -"           # Invalid sign
    )

    # Special test for empty input
    echo -n "Testing: ./push_swap -> "
    OUTPUT=$(./push_swap 2>&1)
    if [[ -z "$OUTPUT" ]]; then
        echo -e "${GREEN}OK${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}FAILED${NC}"
    fi
    ((total_tests++))

    echo -n "Testing: ./push_swap \"\" -> "
    OUTPUT=$(./push_swap "" 2>&1)
    if [[ -z "$OUTPUT" ]]; then
        echo -e "${GREEN}OK${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}FAILED${NC}"
    fi
    ((total_tests++))

    # Rest of error cases testing
    for test_case in "${ERROR_CASES[@]}"; do
        echo -n "Testing: ./push_swap $test_case -> "
        OUTPUT=$(./push_swap $test_case 2>&1)
        if [[ "$OUTPUT" == "Error" ]]; then
            echo -e "${GREEN}OK${NC}"
            ((passed_tests++))
        else
            echo -e "${RED}FAILED${NC}"
        fi
        ((total_tests++))
    done

    echo "----------------------------------------"
    echo -e "Error cases: ${GREEN}$passed_tests/$total_tests passed${NC}"
    echo "----------------------------------------"
    echo ""
}

# Function to generate random numbers without duplicates
generate_numbers() {
    local size=$1
    shuf -i 1-$size -n $size | tr '\n' ' '
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

    echo -e "${BLUE}Testing with $size numbers - $iterations iterations${NC}"
    echo "----------------------------------------"

    for ((i=1; i<=iterations; i++)); do
        # Generate random numbers using shuf
        ARGS=$(generate_numbers $size)

        # Run push_swap and save output
        OPERATIONS=$(./push_swap $ARGS)

        # Count number of operations
        OP_COUNT=$(echo "$OPERATIONS" | wc -l | tr -d '[:space:]')

        # Run checker_linux
        RESULT=$(echo "$OPERATIONS" | ./checker_linux $ARGS)

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
    done

    # Calculate average
    average_operations=$((total_operations / iterations))

    # Print summary
    echo -e "\n${BLUE}Summary for $size numbers:${NC}"
    echo "----------------------------------------"
    echo -e "Successful tests: ${GREEN}$successful_tests${NC}"
    echo -e "Failed tests: ${RED}$failed_tests${NC}"
    echo "Average operations: $average_operations"
    echo "Maximum operations: $max_operations"
    echo "Minimum operations: $min_operations"
    echo "----------------------------------------"
    echo "Performance Assessment:"
    echo "======================"
    if [ "$size" = "100" ]; then
        if [ -n "$max_operations" ] && [ "$max_operations" -lt 700 ]; then
            echo -e "${GREEN}✓ 100 numbers: $max_operations operations (< 700) - Meets minimum requirement${NC}"
        else
            echo -e "${RED}✗ 100 numbers: $max_operations operations (> 700) - Does not meet minimum requirement${NC}"
        fi
    elif [ "$size" = "500" ]; then
        if [ -n "$max_operations" ] && [ "$max_operations" -lt 5500 ]; then
            echo -e "${GREEN}✓ 500 numbers: $max_operations operations (< 5500) - Meets minimum requirement${NC}"
        else
            echo -e "${RED}✗ 500 numbers: $max_operations operations (> 5500) - Does not meet minimum requirement${NC}"
        fi
    fi
    echo "----------------------------------------"
    echo ""
}

# Clear screen
clear

# Check if push_swap and checker_linux exist
if [ ! -f "./push_swap" ] || [ ! -f "./checker_linux" ]; then
    echo -e "${RED}Error: push_swap or checker_linux not found in current directory${NC}"
    exit 1
fi

# Make sure executables have proper permissions
chmod +x ./push_swap ./checker_linux

# Run tests
echo "Starting Push_Swap Tests"
echo "========================"

# Test error cases first
test_error_cases

# Test with 100 numbers (20 iterations)
test_push_swap 100 1000

# Test with 500 numbers (20 iterations)
test_push_swap 500 100
