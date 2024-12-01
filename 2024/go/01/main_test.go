package main

import (
	"testing"
)

var example1 = `3   4
4   3
2   5
1   3
3   9
3   3`

func TestPart1(t *testing.T) {
	answer := Part1(example1)
	if answer != 11 {
		t.Errorf("Expected 11, got %d", answer)
	}
}
