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
	// preprocessing before solving
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func Map[T, V any](ts []T, fn func(T) V) []V {
	result := make([]V, len(ts))
	for i, t := range ts {
		result[i] = fn(t)
	}
	return result
}

type OrderingRules struct {
	// After 'key', the pages that should come after it.
	After map[int][]int
	// Before 'key', the pages that should come before it.
	Before map[int][]int
}

// The comparison function that enforces the ordering rules.
func (rules OrderingRules) comparator() func(a, b int) int {
	return func(a, b int) int {
		if slices.Contains(rules.After[a], b) {
			// a < b
			return -1
		} else if slices.Contains(rules.Before[a], b) {
			// a > b
			return 1
		} else {
			// a == b or does not matter
			return 0
		}
	}
}

// Sorts the given list according to the rules.
func (rules OrderingRules) sorted(pageList []int) []int {
	slices.SortFunc(pageList, rules.comparator())
	return pageList
}

func makeOrderingRules(rules []string) OrderingRules {
	before := make(map[int][]int)
	after := make(map[int][]int)
	for _, rule := range rules {
		// parse '12|45' into [12, 45]
		rulesStrs := strings.Split(rule, "|")
		first, err1 := strconv.Atoi(rulesStrs[0])
		if err1 != nil {
			panic(err1)
		}
		second, err2 := strconv.Atoi(rulesStrs[1])
		if err2 != nil {
			panic(err2)
		}
		after[first] = append(after[first], second)
		before[second] = append(before[second], first)
	}
	return OrderingRules{After: after, Before: before}
}

func Part1(input string) int {
	sections := strings.Split(input, "\n\n")
	orderingRules := makeOrderingRules(strings.Split(sections[0], "\n"))
	result := 0

	for _, list := range strings.Split(sections[1], "\n") {
		page := Map(strings.Split(list, ","), func(item string) int { n, _ := strconv.Atoi(item); return n })
		if slices.IsSortedFunc(page, orderingRules.comparator()) {
			result += page[len(page)/2]
		}
	}

	return result
}

func Part2(input string) int {
	sections := strings.Split(input, "\n\n")
	orderingRules := makeOrderingRules(strings.Split(sections[0], "\n"))
	result := 0

	for _, list := range strings.Split(sections[1], "\n") {
		page := Map(strings.Split(list, ","), func(item string) int { n, _ := strconv.Atoi(item); return n })
		if !slices.IsSortedFunc(page, orderingRules.comparator()) {
			fixed := orderingRules.sorted(page)
			result += fixed[len(fixed)/2]
		}
	}

	return result
}
