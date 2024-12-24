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

type DiskSpan struct {
	// -1 = free space, otherwise file ID
	ID    int
	Start int
	End   int
}

func (s DiskSpan) Length() int {
	return s.End - s.Start
}

func (s DiskSpan) isFreeSpace() bool {
	return s.ID == -1
}

func (s DiskSpan) Atoms() []Atom {
	atoms := make([]Atom, 0)
	for i := s.Start; i < s.End; i++ {
		id := s.ID
		atoms = append(atoms, Atom{ID: id})
	}
	return atoms
}

func makeAtoms(spans []DiskSpan) []Atom {
	atoms := make([]Atom, 0)
	for _, span := range spans {
		atoms = append(atoms, span.Atoms()...)
	}
	return atoms
}

func defragment1(spans []DiskSpan) []Atom {
	tmp := makeAtoms(spans)
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

func makeSpans(input string) []DiskSpan {
	spans := make([]DiskSpan, 0)
	// Alternates, block/free/block/free etc.
	isFreeSpace := false
	currentID := 0
	currentIndex := 0
	for _, num := range input {
		length, err := strconv.Atoi(string(num))
		if err != nil {
			panic("Invalid input")
		}
		id := currentID
		if isFreeSpace {
			id = -1
		}
		spans = append(spans, DiskSpan{ID: id, Start: currentIndex, End: currentIndex + length})
		if !isFreeSpace {
			currentID += 1
		}
		currentIndex += length
		isFreeSpace = !isFreeSpace
	}
	return spans
}

func defragment2(spans []DiskSpan) []Atom {
	tmp := makeAtoms(spans)
	lower, upper := 0, len(tmp)-1
	endPointer := upper
	for endPointer > lower {
		// Move to the next item
		for endPointer > lower && tmp[endPointer].ID == -1 {
			endPointer -= 1
		}

		// How big is this item?
		itemLength := 0
		for i := endPointer; i > lower && tmp[i].ID == tmp[endPointer].ID; i-- {
			itemLength += 1
		}

		// Iterate over the current array to find the best slot
		for freePointer := 0; freePointer < upper; freePointer++ {
			// Find the first free spot
			for freePointer < upper && tmp[freePointer].ID != -1 {
				freePointer += 1
			}

			// Don't move items further to the end
			if freePointer > endPointer {
				break
			}

			// How big is it?
			freeSize := 0
			for freePointer+freeSize < upper && tmp[freePointer+freeSize].ID == -1 {
				freeSize += 1
			}

			if freeSize >= itemLength {
				// Swap the whole item with the free space
				for j := 0; j < itemLength; j++ {
					tmp[endPointer-j], tmp[freePointer+j] = tmp[freePointer+j], tmp[endPointer-j]
				}
				break
			}
		}

		endPointer -= itemLength
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
	spans := makeSpans(input)
	defragmented := defragment1(spans)
	return checksum(defragmented)
}

func Part2(input string) int {
	spans := makeSpans(input)
	defragmented := defragment2(spans)
	return checksum(defragmented)
}
