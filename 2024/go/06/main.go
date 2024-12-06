package main

import (
	_ "embed"
	"fmt"
	"maps"
	"slices"
	"strings"
)

//go:embed input.txt
var input string

func init() {
	// preprocessing before solving
	input = strings.TrimRight(input, "\n")
	if len(input) == 0 {
		panic("empty input.txt file")
	}
}

func main() {
	ans1 := Part1(input)
	fmt.Println("Part 1:", ans1)
	ans2 := Part2(input)
	fmt.Println("Part 2:", ans2)
}

type Coordinate struct {
	X int
	Y int
}

func (c Coordinate) String() string {
	return fmt.Sprintf("(%d, %d)", c.X, c.Y)
}

func (c Coordinate) translate(x, y int) Coordinate {
	return Coordinate{c.X + x, c.Y + y}
}

type Guard struct {
	c   Coordinate
	dir Direction
}

func (g *Guard) turnRight() {
	g.dir = g.dir.turnRight()
}

type Direction int

const (
	Up Direction = iota
	Right
	Down
	Left
)

func (d Direction) turnRight() Direction {
	return (d + 1) % 4
}

type Action int

const (
	Moved Action = iota
	Rotated
	OutOfBounds
)

func (a Action) canProceed() bool {
	return a != OutOfBounds
}

type Arena struct {
	width     int
	height    int
	obstacles map[Coordinate]bool
	guard     *Guard
}

func (arena *Arena) nextGuardPosition() Coordinate {
	c := arena.guard.c
	switch arena.guard.dir {
	case Up:
		return c.translate(0, -1)
	case Left:
		return c.translate(-1, 0)
	case Down:
		return c.translate(0, 1)
	case Right:
		return c.translate(1, 0)
	default:
		panic("Invalid Direction")
	}
}

// Returns whether the guard was able to move.
func (arena *Arena) moveGuard() Action {
	nextPos := arena.nextGuardPosition()
	if arena.obstacles[nextPos] {
		arena.guard.turnRight()
		return Rotated
	} else if nextPos.X < 0 || nextPos.X >= arena.width || nextPos.Y < 0 || nextPos.Y >= arena.height {
		return OutOfBounds
	} else {
		arena.guard.c = nextPos
		return Moved
	}
}

func (arena *Arena) visitedLocations() []Coordinate {
	visited := make(map[Coordinate]bool)
	for {
		visited[arena.guard.c] = true
		action := arena.moveGuard()
		if !action.canProceed() {
			return slices.Collect(maps.Keys(visited))
		}
	}
}

func (arena *Arena) doesLoop() bool {
	visited := make(map[Guard]bool)
	for {
		visited[*arena.guard] = true
		action := arena.moveGuard()
		if !action.canProceed() {
			return false
		}
		if visited[*arena.guard] {
			return true
		}
	}
}

func makeArena(input string) *Arena {
	lines := strings.Split(input, "\n")
	arena := &Arena{
		width:     len(lines[0]),
		height:    len(lines),
		obstacles: make(map[Coordinate]bool),
	}
	for y, line := range lines {
		for x, c := range line {
			switch c {
			case '#':
				arena.obstacles[Coordinate{x, y}] = true
			case '^':
				arena.guard = &Guard{Coordinate{x, y}, Up}
			}
		}
	}

	return arena
}

func Part1(input string) int {
	arena := makeArena(input)
	return len(arena.visitedLocations())
}

func Part2(input string) int {
	result := 0
	arena := makeArena(input)
	visted := arena.visitedLocations()

	for _, pos := range visted {
		testArena := makeArena(input)
		if testArena.guard.c == pos {
			continue
		}
		testArena.obstacles[pos] = true
		if testArena.doesLoop() {
			result += 1
		}
	}

	return result
}
