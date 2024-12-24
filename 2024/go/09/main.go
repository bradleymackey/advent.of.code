package main

import (
	_ "embed"
	"fmt"
	"strconv"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

type Atom struct {
	// -1 = free space, otherwise file ID
	ID int
}

func makeAtoms(input string) []Atom {
	atoms := make([]Atom, 0)
	isBlock := true
	id := 0
	for _, num := range input {
		length, err := strconv.Atoi(string(num))
		if err != nil {
			panic("Invalid input")
		}
		for i := 0; i < length; i++ {
			if isBlock {
				atoms = append(atoms, Atom{ID: id})
			} else {
				atoms = append(atoms, Atom{ID: -1})
			}
		}
		if isBlock {
			id += 1
		}
		isBlock = !isBlock
	}
	return atoms
}

func defragment(atoms []Atom) []Atom {
	tmp := append([]Atom(nil), atoms...)
	lower, upper := 0, len(tmp)-1
	startPointer := lower
	endPointer := upper
	for {
		// Move to next empty space
		for startPointer < upper && tmp[startPointer].ID != -1 {
			startPointer += 1
		}
		// Move to the next item
		for endPointer > lower && tmp[endPointer].ID == -1 {
			endPointer -= 1
		}
		if startPointer >= endPointer {
			break
		}
		tmp[startPointer], tmp[endPointer] = tmp[endPointer], tmp[startPointer]
	}
	return tmp
}

func checksum(atoms []Atom) int {
	total := 0
	for i, atom := range atoms {
		if atom.ID == -1 {
			continue
		}
		total += i * atom.ID
	}
	return total
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func Part1(input string) int {
	atoms := makeAtoms(input)
	defragmented := defragment(atoms)
	return checksum(defragmented)
}

func Part2(input string) int {
	return 0
}
