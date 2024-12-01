package main

import (
	"testing"
)

var example = `3   4
4   3
2   5
1   3
3   9
3   3`

func TestPart1(t *testing.T) {
	answer := Part1(example)
	if answer != 11 {
		t.Errorf("Expected 11, got %d", answer)
	}
}

func TestPart2(t *testing.T) {
	answer := Part2(example)
	if answer != 31 {
		t.Errorf("Expected 31, got %d", answer)
	}
}
