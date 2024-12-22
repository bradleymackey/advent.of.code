package main

import (
	_ "embed"
	"fmt"
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

type Item rune

type Antenna struct {
	Antenna Item
	Coord   Coordinate
}

type AntennaPair struct {
	First  Antenna
	Second Antenna
}

type Coordinate struct {
	X int
	Y int
}

func (c Coordinate) Add(v Vector) Coordinate {
	return Coordinate{X: c.X + v.X, Y: c.Y + v.Y}
}

func (c Coordinate) Sub(v Vector) Coordinate {
	return Coordinate{X: c.X - v.X, Y: c.Y - v.Y}
}

func (c Coordinate) DistanceTo(other Coordinate) Vector {
	return Vector{X: other.X - c.X, Y: other.Y - c.Y}
}

type Vector struct {
	X int
	Y int
}

type Arena struct {
	Grid [][]Item
}

func (a Arena) Width() int {
	return len(a.Grid[0])
}

func (a Arena) Height() int {
	return len(a.Grid)
}

func (a Arena) Get(coord Coordinate) Item {
	return a.Grid[coord.Y][coord.X]
}

func makeArena(input string) Arena {
	lines := strings.Split(input, "\n")
	grid := make([][]Item, len(lines))
	for i, line := range lines {
		grid[i] = make([]Item, len(line))
		for j, c := range line {
			grid[i][j] = Item(c)
		}
	}
	return Arena{Grid: grid}
}

func (a Arena) AllAntennas() []Antenna {
	all := make([]Antenna, 0)
	for y, row := range a.Grid {
		for x, item := range row {
			if item != '.' {
				all = append(all, Antenna{Antenna: item, Coord: Coordinate{X: x, Y: y}})
			}
		}
	}
	return all
}

func (a Arena) IsInBounds(coord Coordinate) bool {
	return coord.X >= 0 && coord.Y >= 0 && coord.X < a.Width() && coord.Y < a.Height()
}

func (a Arena) AllAntennaPairs() []AntennaPair {
	pairs := make([]AntennaPair, 0)
	antennas := a.AllAntennas()
	for _, scanner := range antennas {
		for _, target := range antennas {
			if scanner == target {
				continue
			}
			if scanner.Antenna != target.Antenna {
				continue
			}
			pairs = append(pairs, AntennaPair{First: scanner, Second: target})
		}
	}
	return pairs
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func Part1(input string) int {
	arena := makeArena(input)
	locations := make(map[Coordinate]bool)
	for _, pair := range arena.AllAntennaPairs() {
		vector := pair.First.Coord.DistanceTo(pair.Second.Coord)
		if first := pair.First.Coord.Sub(vector); arena.IsInBounds(first) {
			locations[first] = true
		}
		if second := pair.Second.Coord.Add(vector); arena.IsInBounds(second) {
			locations[second] = true
		}
	}
	return len(locations)
}

func Part2(input string) int {
	arena := makeArena(input)
	locations := make(map[Coordinate]bool)
	for _, pair := range arena.AllAntennaPairs() {
		vector := pair.First.Coord.DistanceTo(pair.Second.Coord)
		for added := pair.First.Coord.Add(vector); arena.IsInBounds(added); added = added.Add(vector) {
			locations[added] = true
		}
		for subbed := pair.Second.Coord.Sub(vector); arena.IsInBounds(subbed); subbed = subbed.Sub(vector) {
			locations[subbed] = true
		}
	}
	return len(locations)
}
