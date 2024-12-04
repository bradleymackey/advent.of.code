package main

import (
	"testing"
)

var example = `MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX`

func TestPart1(t *testing.T) {
	ans := Part1(example)
	if ans != 18 {
		t.Errorf("Expected 18, but got %d", ans)
	}
}

func TestPart2(t *testing.T) {
	ans := Part2(example)
	if ans != 9 {
		t.Errorf("Expected 9, but got %d", ans)
	}
}
