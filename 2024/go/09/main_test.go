package main

import (
	"testing"
)

var example = `2333133121414131402`

func TestPart1(t *testing.T) {
	ans := Part1(example)
	if ans != 1928 {
		t.Errorf("Expected 1928, but got %d", ans)
	}
}

func TestPart2(t *testing.T) {
	ans := Part2(example)
	if ans != 2858 {
		t.Errorf("Expected 2858, but got %d", ans)
	}
}
