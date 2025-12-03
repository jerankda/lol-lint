#!/bin/bash

echo "========================================"
echo "lol-lint Test Suite"
echo "========================================"
echo ""

LINTER="./target/release/lol-lint"

# build release if not exists
if [ ! -f "$LINTER" ]; then
    echo "Building release binary..."
    cargo build --release
    echo ""
fi

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # no color

test_count=0
pass_count=0
fail_count=0

run_test() {
    local file=$1
    local expect_pass=$2
    local description=$3
    
    test_count=$((test_count + 1))
    
    echo -e "${CYAN}Test $test_count:${NC} $description"
    echo "File: $file"
    
    # run linter
    output=$($LINTER "$file" 2>&1)
    exit_code=$?
    
    # check result
    if [ "$expect_pass" = "pass" ]; then
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} - No errors as expected"
            pass_count=$((pass_count + 1))
        else
            echo -e "${RED}✗ FAIL${NC} - Expected pass but got errors:"
            echo "$output"
            fail_count=$((fail_count + 1))
        fi
    else
        if [ $exit_code -ne 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} - Errors caught as expected:"
            echo "$output" | head -5
            pass_count=$((pass_count + 1))
        else
            echo -e "${RED}✗ FAIL${NC} - Expected errors but passed"
            fail_count=$((fail_count + 1))
        fi
    fi
    
    echo ""
}

echo "========================================="
echo "VALID FILES (should pass)"
echo "========================================="
echo ""

run_test "examples/valid_complete.lol" "pass" "Complete valid program with all features"
run_test "examples/valid_minimal.lol" "pass" "Minimal valid program"
run_test "examples/valid_nested_expressions.lol" "pass" "Nested expressions"
run_test "examples/valid_comments.lol" "pass" "Comments support"
run_test "examples/valid_multiple_expressions.lol" "pass" "Multiple expressions in VISIBLE"

echo "========================================="
echo "ERROR FILES (should fail)"
echo "========================================="
echo ""

run_test "examples/error_use_before_declaration.lol" "fail" "Use before declaration"
run_test "examples/error_double_declaration.lol" "fail" "Double declaration"
run_test "examples/error_undeclared_assignment.lol" "fail" "Undeclared assignment"
run_test "examples/error_multiple.lol" "fail" "Multiple errors"

echo "========================================="
echo "WARNING FILES (should pass with warnings)"
echo "========================================="
echo ""

run_test "examples/warning_unused_variable.lol" "pass" "Unused variable"
run_test "examples/warning_constant_true.lol" "pass" "Constant expression (true)"
run_test "examples/warning_constant_false.lol" "pass" "Constant expression (false)"
run_test "examples/warning_empty_loop.lol" "pass" "Empty loop body"
run_test "examples/warning_missing_no_wai.lol" "pass" "Missing NO WAI"
run_test "examples/warning_empty_ya_rly.lol" "pass" "Empty YA RLY block"

echo "========================================="
echo "MIXED FILES"
echo "========================================="
echo ""

run_test "examples/mixed_issues.lol" "fail" "Mixed errors and warnings"

echo "========================================="
echo "SUMMARY"
echo "========================================="
echo "Total tests: $test_count"
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
