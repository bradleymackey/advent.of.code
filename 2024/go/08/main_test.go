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
