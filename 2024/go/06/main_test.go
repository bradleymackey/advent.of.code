package main

import (
	"testing"
)

var example = `....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...`

func TestPart1(t *testing.T) {
	ans := Part1(example)
	if ans != 41 {
		t.Errorf("Expected 41, but got %d", ans)
	}
}

func TestPart2(t *testing.T) {
	ans := Part2(example)
	if ans != 6 {
		t.Errorf("Expected 6, but got %d", ans)
	}
}
