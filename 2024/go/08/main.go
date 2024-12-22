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

func (a Arena) DistanceToMatching(from Coordinate, to Coordinate) Vector {
	return Vector{X: to.X - from.X, Y: to.Y - from.Y}
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

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

func Part1(input string) int {
	arena := makeArena(input)
	antennas := arena.AllAntennas()
	locations := make(map[Coordinate]bool)
	for _, scanner := range antennas {
		for _, target := range antennas {
			if scanner == target {
				continue
			}
			if scanner.Antenna != target.Antenna {
				continue
			}
			vector := arena.DistanceToMatching(scanner.Coord, target.Coord)
			first := target.Coord.Add(vector)
			second := scanner.Coord.Sub(vector)
			if arena.IsInBounds(first) {
				locations[first] = true
			}
			if arena.IsInBounds(second) {
				locations[second] = true
			}
		}
	}
	return len(locations)
}

func Part2(input string) int {
	return 0
}
