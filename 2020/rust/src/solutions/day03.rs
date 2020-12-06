// --- Day 3: Toboggan Trajectory ---
// getting the hang of this parsing business now
// i really like how fast rust is, and how helpful these error messages are

use crate::common::parse_error::ParseError;
use crate::common::vector2::Vector2;
use std::convert::TryFrom;

type Input = Vec<Vec<Cell>>;

#[derive(Debug)]
enum Cell {
    Empty,
    Tree,
}

impl TryFrom<char> for Cell {
    type Error = ParseError;
    fn try_from(val: char) -> Result<Self, Self::Error> {
        match val {
            '.' => Ok(Cell::Empty),
            '#' => Ok(Cell::Tree),
            _ => Err(ParseError),
        }
    }
}

#[aoc_generator(day3)]
fn parse_input(input: &str) -> Input {
    input
        .lines()
        .map(|line| {
            line.chars()
                .map(|c| Cell::try_from(c).unwrap_or(Cell::Empty))
                .collect()
        })
        .collect()
}

#[inline]
fn trees_encountered(input: &Input, slope: &Vector2<usize>) -> usize {
    let x_wide = input[0].len();
    let height = input.len();
    let mut pos = Vector2::zero();
    let mut trees = 0;
    while pos.y < height - 1 {
        pos += *slope;
        pos.x %= x_wide; // repeat, so wrap
        let item = &input[pos.y][pos.x];
        match item {
            Cell::Empty => {}
            Cell::Tree => trees += 1,
        }
    }
    trees
}

#[aoc(day3, part1)]
fn part1(input: &Input) -> usize {
    let slope = Vector2::new(3, 1);
    trees_encountered(&input, &slope)
}

#[aoc(day3, part2)]
fn part2(input: &Input) -> usize {
    let slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)];
    slopes
        .iter()
        .map(|slope| trees_encountered(&input, &Vector2::from_tup(*slope)))
        .product()
}

#[cfg(test)]
mod tests {
    #[test]
    fn example_test() {
        assert!(true);
    }
}
