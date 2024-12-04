package main

import (
	_ "embed"
	"fmt"
	"strings"
)

type Coordinate struct {
	X int
	Y int
	/// The data that is expected at this coordinate.
	Expected rune
}

func (c Coordinate) translatedXY(x, y int, expected rune) Coordinate {
	return Coordinate{X: c.X + x, Y: c.Y + y, Expected: expected}
}

func (c Coordinate) translatedX(value int, expected rune) Coordinate {
	return Coordinate{X: c.X + value, Y: c.Y, Expected: expected}
}

func (c Coordinate) translatedY(value int, expected rune) Coordinate {
	return Coordinate{X: c.X, Y: c.Y + value, Expected: expected}
}

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

func makeCharMap(s string) [][]rune {
	lines := strings.Split(s, "\n")
	charMap := make([][]rune, len(lines))
	for i, line := range lines {
		charMap[i] = []rune(line)
	}
	return charMap
}

func part1Potential(start Coordinate, rows, cols int) [][]Coordinate {
	result := make([][]Coordinate, 0)
	result = append(result, []Coordinate{start, start.translatedX(1, 'M'), start.translatedX(2, 'A'), start.translatedX(3, 'S')})
	result = append(result, []Coordinate{start, start.translatedX(-1, 'M'), start.translatedX(-2, 'A'), start.translatedX(-3, 'S')})
	result = append(result, []Coordinate{start, start.translatedXY(1, 1, 'M'), start.translatedXY(2, 2, 'A'), start.translatedXY(3, 3, 'S')})
	result = append(result, []Coordinate{start, start.translatedXY(-1, -1, 'M'), start.translatedXY(-2, -2, 'A'), start.translatedXY(-3, -3, 'S')})
	result = append(result, []Coordinate{start, start.translatedXY(1, -1, 'M'), start.translatedXY(2, -2, 'A'), start.translatedXY(3, -3, 'S')})
	result = append(result, []Coordinate{start, start.translatedXY(-1, 1, 'M'), start.translatedXY(-2, 2, 'A'), start.translatedXY(-3, 3, 'S')})
	result = append(result, []Coordinate{start, start.translatedY(1, 'M'), start.translatedY(2, 'A'), start.translatedY(3, 'S')})
	result = append(result, []Coordinate{start, start.translatedY(-1, 'M'), start.translatedY(-2, 'A'), start.translatedY(-3, 'S')})
	for i, coordinates := range result {
		for _, c := range coordinates {
			if c.X < 0 || c.X >= rows || c.Y < 0 || c.Y >= cols {
				result[i] = nil
			}
		}
	}
	return result
}

func part2Potential(start Coordinate, rows, cols int) [][]Coordinate {
	first := []Coordinate{
		start,
		start.translatedXY(-1, -1, 'M'),
		start.translatedXY(1, 1, 'S'),
		start.translatedXY(-1, 1, 'M'),
		start.translatedXY(1, -1, 'S'),
	}
	second := []Coordinate{
		start,
		start.translatedXY(-1, -1, 'S'),
		start.translatedXY(1, 1, 'M'),
		start.translatedXY(-1, 1, 'M'),
		start.translatedXY(1, -1, 'S'),
	}
	third := []Coordinate{
		start,
		start.translatedXY(-1, -1, 'S'),
		start.translatedXY(1, 1, 'M'),
		start.translatedXY(-1, 1, 'S'),
		start.translatedXY(1, -1, 'M'),
	}
	fourth := []Coordinate{
		start,
		start.translatedXY(-1, -1, 'M'),
		start.translatedXY(1, 1, 'S'),
		start.translatedXY(-1, 1, 'S'),
		start.translatedXY(1, -1, 'M'),
	}
	result := [][]Coordinate{first, second, third, fourth}
	for i, coordinates := range result {
		for _, c := range coordinates {
			if c.X < 0 || c.X >= rows || c.Y < 0 || c.Y >= cols {
				result[i] = nil
			}
		}
	}
	return result
}

func matchesExpected(runeMap [][]rune, coordinates []Coordinate) bool {
	for _, c := range coordinates {
		if runeMap[c.Y][c.X] != c.Expected {
			return false
		}
	}
	return true
}

func Part1(input string) int {
	var result int
	runes := makeCharMap(input)
	for y, line := range runes {
		for x, letter := range line {
			if letter != 'X' {
				continue
			}
			start := Coordinate{X: x, Y: y, Expected: letter}
			potential := part1Potential(start, len(runes), len(line))
			for _, p := range potential {
				if p != nil && matchesExpected(runes, p) {
					result += 1
				}
			}
		}
	}
	return result
}

func Part2(input string) int {
	var result int
	runes := makeCharMap(input)
	for y, line := range runes {
		for x, letter := range line {
			if letter != 'A' {
				continue
			}
			start := Coordinate{X: x, Y: y, Expected: letter}
			potential := part2Potential(start, len(runes), len(line))
			for _, p := range potential {
				if p != nil && matchesExpected(runes, p) {
					result += 1
				}
			}
		}
	}
	return result
}
