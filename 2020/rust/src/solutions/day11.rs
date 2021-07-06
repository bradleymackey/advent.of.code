// --- Day 11: Seating System ---

use crate::common::vector2::Vector2;
use std::convert::From;

enum Part {
    One,
    Two,
}

#[derive(Clone, Debug, Copy, PartialEq, Eq)]
enum Position {
    Seat(bool),
    Floor,
}

impl Default for Position {
    fn default() -> Self {
        Position::Floor
    }
}

impl Position {
    fn is_occupied(&self) -> bool {
        match &self {
            Position::Seat(true) => true,
            _ => false,
        }
    }
    fn never_changes(&self) -> bool {
        match &self {
            Position::Floor => true,
            _ => false,
        }
    }
}

impl From<char> for Position {
    // From<T> must succeed
    // if there was a possibility of graceful failure, use TryFrom instead
    fn from(c: char) -> Self {
        use Position::*;
        match c {
            'L' => Seat(false),
            '#' => Seat(true),
            '.' => Floor,
            _ => panic!("bad input"),
        }
    }
}

// clone -> always explict, may be expensive
// copy -> implicit, should only be used for non-expensive things
#[derive(Debug, Clone, PartialEq, Eq)]
struct WaitingRoom {
    floor: Vec<Vec<Position>>,
    changed_flag: bool,
}

impl From<&str> for WaitingRoom {
    fn from(input: &str) -> Self {
        let positions = input
            .lines()
            .map(|l| l.chars().map(|c| Position::from(c)).collect())
            .collect();
        Self {
            floor: positions,
            changed_flag: false,
        }
    }
}

impl WaitingRoom {
    fn rows(&self) -> i32 {
        self.floor.len() as i32
    }
    fn cols(&self) -> i32 {
        self.floor[0].len() as i32
    }
}

impl WaitingRoom {
    fn is_valid_position(&self, v: Vector2<i32>) -> bool {
        if v.x < 0 || v.y < 0 {
            return false;
        }
        if v.x > self.rows() || v.y > self.cols() {
            return false;
        }
        return true;
    }
    /// Get the position at the given coordinates.
    fn position(&self, v: Vector2<i32>) -> Position {
        if v.x < 0 || v.y < 0 || v.x >= self.rows() || v.y >= self.cols() {
            return Position::Floor;
        }
        match &self.floor.get(v.x as usize) {
            Some(row) => {
                if let Some(pos) = row.get(v.y as usize) {
                    *pos
                } else {
                    Position::default()
                }
            }
            _ => Position::default(),
        }
    }
    /// Gets the new state for a given x,y.
    fn new_state_part_1(&self, v: Vector2<i32>) -> Position {
        let current = self.position(v);
        if current.never_changes() {
            return current;
        }
        let mut adjacent_occupied = 0;
        for i in -1..=1 as i32 {
            for j in -1..=1 as i32 {
                if i == 0 && j == 0 {
                    continue;
                }
                let vec = v + Vector2::new(i, j);
                let pos = self.position(vec);
                if pos.is_occupied() {
                    adjacent_occupied += 1;
                }
            }
        }
        match current {
            Position::Seat(false) if adjacent_occupied == 0 => Position::Seat(true),
            Position::Seat(true) if adjacent_occupied >= 4 => Position::Seat(false),
            _ => current,
        }
    }

    fn is_occupied_in_direction(&self, start: Vector2<i32>, repeat: Vector2<i32>) -> bool {
        let mut current = start;
        loop {
            current += repeat;
            if !self.is_valid_position(current) {
                // if it reached an invalid position, the line is not occupied
                return false;
            }
            let item = self.position(current);
            match item {
                Position::Floor => continue,
                Position::Seat(occ) => return occ,
            }
        }
    }

    fn new_state_part_2(&self, v: Vector2<i32>) -> Position {
        let current = self.position(v);
        if current.never_changes() {
            return current;
        }
        let directions = [
            Vector2::new(1, 0),
            Vector2::new(-1, 0),
            Vector2::new(0, 1),
            Vector2::new(0, -1),
            Vector2::new(1, 1),
            Vector2::new(1, -1),
            Vector2::new(-1, 1),
            Vector2::new(-1, -1),
        ];
        let adjacent_occupied = directions
            .iter()
            .map(|d| self.is_occupied_in_direction(v, *d))
            .filter(|o| o == &true)
            .count();
        match current {
            Position::Seat(false) if adjacent_occupied == 0 => Position::Seat(true),
            Position::Seat(true) if adjacent_occupied >= 5 => Position::Seat(false),
            _ => current,
        }
    }

    fn round(&mut self, part: Part) {
        self.changed_flag = false;
        let old = self.clone();
        for i in 0..self.rows() {
            for j in 0..self.cols() {
                let vec = Vector2::new(i, j);
                let old_state = old.position(vec);
                let new_state = match part {
                    Part::One => old.new_state_part_1(vec),
                    Part::Two => old.new_state_part_2(vec),
                };
                self.floor[i as usize][j as usize] = new_state;
                if old_state != new_state {
                    self.changed_flag = true;
                }
            }
        }
    }

    /// how many sears are occupied?
    fn occupied(&self) -> i32 {
        let mut count = 0;
        for i in 0..self.rows() {
            for j in 0..self.cols() {
                let vec = Vector2::new(i, j);
                if self.position(vec).is_occupied() {
                    count += 1;
                }
            }
        }
        count
    }
}

#[aoc_generator(day11)]
fn parse_input(input: &str) -> WaitingRoom {
    WaitingRoom::from(input)
}

#[aoc(day11, part1)]
fn part1(input: &WaitingRoom) -> i32 {
    let mut room = input.clone();
    loop {
        room.round(Part::One);
        if !room.changed_flag {
            return room.occupied();
        }
    }
}

#[aoc(day11, part2)]
fn part2(input: &WaitingRoom) -> i32 {
    let mut room = input.clone();
    loop {
        room.round(Part::Two);
        if !room.changed_flag {
            return room.occupied();
        }
    }
}
