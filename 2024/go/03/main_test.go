package main

import (
	"testing"
)

var example1 = `xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))`
var example2 = `xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)do()undo()?mul(8,5))`

func TestPart1(t *testing.T) {
	ans := Part1(example1)
	if ans != 161 {
		t.Errorf("Expected 161, got %d", ans)
	}
}

func TestPart2(t *testing.T) {
	ans := Part2(example2)
	if ans != 48 {
		t.Errorf("Expected 48, got %d", ans)
	}
}
