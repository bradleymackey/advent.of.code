package main

import (
	_ "embed"
	"fmt"
	"slices"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("input is empty")
	}
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func inputNumbers(input string) [][]int {
	var inputNumbers [][]int
	for _, line := range strings.Split(input, "\n") {
		values := strings.Fields(line)
		ints, err := stringsToInts(values)
		if err != nil {
			panic(fmt.Sprintf("Invalid input row: %v", values))
		}
		inputNumbers = append(inputNumbers, ints)
	}
	return inputNumbers
}

func stringsToInts(strings []string) ([]int, error) {
	ints := make([]int, len(strings))
	for i, s := range strings {
		num, err := strconv.Atoi(s)
		if err != nil {
			return nil, err
		}
		ints[i] = num
	}
	return ints, nil
}

func checkGapSize(nums []int, minSize int, maxSize int) bool {
	for i := 1; i < len(nums); i++ {
		gapSize := absInt(nums[i] - nums[i-1])
		isValid := gapSize >= minSize && gapSize <= maxSize
		if !isValid {
			return false
		}
	}
	return true
}

func absInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func checkSafe(nums []int) bool {
	asc := slices.IsSorted(nums)
	desc := slices.IsSortedFunc(nums, func(a, b int) int {
		if a < b {
			return 1
		} else if a == b {
			return 0
		} else {
			return -1
		}
	})
	isValidGapSize := checkGapSize(nums, 1, 3)
	return (asc || desc) && isValidGapSize
}

func Part1(input string) int {
	var safe int
	reports := inputNumbers(input)
	for _, row := range reports {
		if checkSafe(row) {
			safe += 1
		}
	}
	return safe
}

func checkSafeSublists(row []int) bool {
	if checkSafe(row) {
		return true
	}
	for i := 0; i < len(row); i++ {
		rowCopy := slices.Clone(row) // weird how 'delete' doesn't return a copy!
		modifiedReport := slices.Delete(rowCopy, i, i+1)
		if checkSafe(modifiedReport) {
			return true
		}
	}
	return false
}

func Part2(input string) int {
	var safe int
	reports := inputNumbers(input)
	for _, report := range reports {
		if checkSafeSublists(report) {
			safe += 1
		}
	}
	return safe
}
