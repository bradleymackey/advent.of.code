package main

import (
	_ "embed"
	"fmt"
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

func Map[T, V any](ts []T, fn func(T) V) []V {
	result := make([]V, len(ts))
	for i, t := range ts {
		result[i] = fn(t)
	}
	return result
}

type Operator int

const (
	Add Operator = iota
	Multiply
)

func generatePermutations(length int, current []Operator) [][]Operator {
	if len(current) == length {
		perm := make([]Operator, len(current))
		copy(perm, current)
		return [][]Operator{perm}
	}

	var result [][]Operator
	for _, op := range []Operator{Add, Multiply} {
		newPermutations := generatePermutations(length, append(current, op))
		result = append(result, newPermutations...)
	}

	return result
}

func (op Operator) apply(a, b int) int {
	switch op {
	case Add:
		return a + b
	case Multiply:
		return a * b
	default:
		panic("invalid operator")
	}
}

type equation struct {
	result int
	parts  []int
}

func (e equation) hasAnySolutions() bool {
	operatorPerms := generatePermutations(len(e.parts)-1, []Operator{})
	for _, ops := range operatorPerms {
		intermediate := e.parts[0]
		for index, part := range e.parts[1:] {
			intermediate = ops[index].apply(intermediate, part)
		}
		if intermediate == e.result {
			return true
		}
	}
	return false
}

func parseEquation(s string) equation {
	// equation is like '100: 10 10'
	parts := strings.Split(s, ": ")
	result, err1 := strconv.Atoi(parts[0])
	if err1 != nil {
		panic(err1)
	}
	numbers := Map(strings.Split(parts[1], " "), func(item string) int { n, _ := strconv.Atoi(item); return n })
	return equation{result, numbers}
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func Part1(input string) int {
	total := 0
	for _, line := range strings.Split(input, "\n") {
		equation := parseEquation(line)
		if equation.hasAnySolutions() {
			total += equation.result
		}
	}
	return total
}

func Part2(input string) int {
	return 0
}
