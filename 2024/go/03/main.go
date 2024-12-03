package main

import (
	_ "embed"
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	// preprocessing before solving
	input = strings.TrimRight(input, "\n")
	input = strings.ReplaceAll(input, "\n", "*")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1: ", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2: ", ans2)
}

func Part1(input string) int {
	pattern := `mul\((\d+),(\d+)\)`
	re := regexp.MustCompile(pattern)
	matches := re.FindAllStringSubmatch(input, -1)
	total := 0
	for _, match := range matches {
		n1, err1 := strconv.Atoi(match[1])
		n2, err2 := strconv.Atoi(match[2])
		if err1 != nil || err2 != nil {
			continue
		}
		total += n1 * n2
	}
	return total
}

func replaceRange(s string, start, end int, replacementChar rune) string {
	runes := []rune(s)
	if start < 0 || end > len(runes) || start > end {
		return s // Return the original string if indices are invalid
	}
	replacementLength := end - start
	replacement := strings.Repeat(string(replacementChar), replacementLength)
	return string(runes[:start]) + replacement + string(runes[end:])
}

func Part2(input string) int {
	cleanInput := input
	unneededRegex := regexp.MustCompile(`don't\(\).*?do\(\)`)

	unneededIndexes := unneededRegex.FindAllStringIndex(input, -1)
	for _, indexRange := range unneededIndexes {
		cleanInput = replaceRange(cleanInput, indexRange[0], indexRange[1], '*')
	}
	fmt.Println(cleanInput)

	pattern := `mul\((\d+),(\d+)\)`
	re := regexp.MustCompile(pattern)
	matches := re.FindAllStringSubmatch(cleanInput, -1)
	total := 0
	for _, match := range matches {
		n1, err1 := strconv.Atoi(match[1])
		n2, err2 := strconv.Atoi(match[2])
		if err1 != nil || err2 != nil {
			continue
		}
		total += n1 * n2
	}
	return total
}
