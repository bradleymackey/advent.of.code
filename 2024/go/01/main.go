package main

import (
	_ "embed"
	"fmt"
	"sort"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	// preprocessing before solving
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

func main() {
	fmt.Println("Hello, World!")
	ans1 := Part1(input)
	fmt.Println("Part 1: ", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2: ", ans2)
}

func absInt(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func getLists(input string) ([]int, []int) {
	var list1 []int
	var list2 []int
	for _, line := range strings.Split(input, "\n") {
		values := strings.Fields(line)
		first_value, _ := strconv.Atoi(values[0])
		second_value, _ := strconv.Atoi(values[1])
		list1 = append(list1, first_value)
		list2 = append(list2, second_value)
	}
	sort.Ints(list1)
	sort.Ints(list2)
	return list1, list2
}

func countOccurrences(slice []int) map[int]int {
	result := make(map[int]int)
	for _, v := range slice {
		result[v]++
	}
	return result
}

func Part1(input string) int {
	list1, list2 := getLists(input)

	var total int
	for i := 0; i < len(list1); i++ {
		total += absInt(list1[i] - list2[i])
	}

	return total
}

func Part2(input string) int {
	list1, list2 := getLists(input)
	list2Count := countOccurrences(list2)

	var total int
	for i := 0; i < len(list1); i++ {
		total += list1[i] * list2Count[list1[i]]
	}

	return total
}
