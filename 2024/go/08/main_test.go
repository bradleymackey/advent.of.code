package main

import (
	"testing"
)

var example = `............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............`

func TestPart1(t *testing.T) {
	ans := Part1(example)
	if ans != 14 {
		t.Errorf("Expected 14, but got %d", ans)
	}
}

func TestPart2(t *testing.T) {
	ans := Part2(example)
	if ans != 34 {
		t.Errorf("Expected 34, but got %d", ans)
	}
}
