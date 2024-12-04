package main

import (
	_ "embed"
	"fmt"
	"strings"
)

type Coordinate struct {
	X int
	Y int
}

func (c Coordinate) translatedXY(x, y int) Coordinate {
	return Coordinate{X: c.X + x, Y: c.Y + y}
}

func (c Coordinate) translatedX(value int) Coordinate {
	return Coordinate{X: c.X + value, Y: c.Y}
}

func (c Coordinate) translatedY(value int) Coordinate {
	return Coordinate{X: c.X, Y: c.Y + value}
}

func (c Coordinate) expect(expected rune) ExpectedDataCoordinate {
	return ExpectedDataCoordinate{C: c, Expected: expected}
}

type ExpectedDataCoordinate struct {
	C        Coordinate
	Expected rune
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

func part1Potential(start Coordinate, rows, cols int) [][]ExpectedDataCoordinate {
	result := make([][]ExpectedDataCoordinate, 0)
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedX(1).expect('M'), start.translatedX(2).expect('A'), start.translatedX(3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedX(-1).expect('M'), start.translatedX(-2).expect('A'), start.translatedX(-3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedXY(1, 1).expect('M'), start.translatedXY(2, 2).expect('A'), start.translatedXY(3, 3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedXY(-1, -1).expect('M'), start.translatedXY(-2, -2).expect('A'), start.translatedXY(-3, -3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedXY(1, -1).expect('M'), start.translatedXY(2, -2).expect('A'), start.translatedXY(3, -3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedXY(-1, 1).expect('M'), start.translatedXY(-2, 2).expect('A'), start.translatedXY(-3, 3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedY(1).expect('M'), start.translatedY(2).expect('A'), start.translatedY(3).expect('S')})
	result = append(result, []ExpectedDataCoordinate{start.expect('X'), start.translatedY(-1).expect('M'), start.translatedY(-2).expect('A'), start.translatedY(-3).expect('S')})
	return result
}

func part2Potential(start Coordinate, rows, cols int) [][]ExpectedDataCoordinate {
	first := []ExpectedDataCoordinate{
		start.expect('A'),
		start.translatedXY(-1, -1).expect('M'),
		start.translatedXY(1, 1).expect('S'),
		start.translatedXY(-1, 1).expect('M'),
		start.translatedXY(1, -1).expect('S'),
	}
	second := []ExpectedDataCoordinate{
		start.expect('A'),
		start.translatedXY(-1, -1).expect('S'),
		start.translatedXY(1, 1).expect('M'),
		start.translatedXY(-1, 1).expect('M'),
		start.translatedXY(1, -1).expect('S'),
	}
	third := []ExpectedDataCoordinate{
		start.expect('A'),
		start.translatedXY(-1, -1).expect('S'),
		start.translatedXY(1, 1).expect('M'),
		start.translatedXY(-1, 1).expect('S'),
		start.translatedXY(1, -1).expect('M'),
	}
	fourth := []ExpectedDataCoordinate{
		start.expect('A'),
		start.translatedXY(-1, -1).expect('M'),
		start.translatedXY(1, 1).expect('S'),
		start.translatedXY(-1, 1).expect('S'),
		start.translatedXY(1, -1).expect('M'),
	}
	return [][]ExpectedDataCoordinate{first, second, third, fourth}
}

/**
 * Verifies if the runeMap matches the expected items at the given coordinates.
 */
func matchesExpected(runeMap [][]rune, coordinates []ExpectedDataCoordinate) bool {
	for _, c := range coordinates {
		if c.C.X < 0 || c.C.X >= len(runeMap[0]) || c.C.Y < 0 || c.C.Y >= len(runeMap) {
			return false
		}
		if runeMap[c.C.Y][c.C.X] != c.Expected {
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
			start := Coordinate{X: x, Y: y}
			potential := part1Potential(start, len(runes), len(line))
			for _, p := range potential {
				if matchesExpected(runes, p) {
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
			start := Coordinate{X: x, Y: y}
			potential := part2Potential(start, len(runes), len(line))
			for _, p := range potential {
				if matchesExpected(runes, p) {
					result += 1
				}
			}
		}
	}
	return result
}
