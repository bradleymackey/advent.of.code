package main

import (
	_ "embed"
	"fmt"
	// "strings"
)

//go:embed input.txt
var input string

func init() {
	fmt.Println("We have got the input!")
}

func main() {
	fmt.Println("Hello, World!")
	ans := Part1(input)
	fmt.Println("Part 1: ", ans)
}

func Part1(input string) int {
	return 0
}
