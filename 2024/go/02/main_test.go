package main

import (
	"testing"
)

var example = `7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9`

func TestPart1(t *testing.T) {
	answer := Part1(example)
	if answer != 2 {
		t.Errorf("Expected 2, got %d", answer)
	}
}

func TestPart2(t *testing.T) {
	answer := Part2(example)
	if answer != 4 {
		t.Errorf("Expected 4, got %d", answer)
	}
}
