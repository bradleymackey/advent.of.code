// --- Day 5: Binary Boarding ---

use crate::common::parse_error::ParseError;
use std::collections::HashSet;
use std::convert::TryFrom;

#[derive(Debug, Clone)]
enum Side {
    Lo,
    Hi,
}

impl TryFrom<char> for Side {
    type Error = ParseError;
    fn try_from(val: char) -> Result<Self, Self::Error> {
        match val {
            'F' | 'L' => Ok(Side::Lo),
            'B' | 'R' => Ok(Side::Hi),
            _ => Err(ParseError),
        }
    }
}

#[derive(Debug)]
struct BoardingPass {
    rows: Vec<Side>,
    cols: Vec<Side>,
}

impl TryFrom<&str> for BoardingPass {
    type Error = ParseError;
    fn try_from(val: &str) -> Result<Self, Self::Error> {
        let parsed: Vec<Side> = val.chars().filter_map(|c| Side::try_from(c).ok()).collect();
        let (rows, cols) = parsed.split_at(7);
        Ok(BoardingPass {
            rows: rows.to_vec(),
            cols: cols.to_vec(),
        })
    }
}

impl BoardingPass {
    fn seat_position(positions: &Vec<Side>) -> usize {
        // only need to track the 'low end' of the binary search
        // if in the 'high end' a given round, just add the round size
        let mut round_size = 2u32.pow(positions.len() as u32) as usize;
        let mut seat = 0;
        for pos in positions {
            round_size /= 2;
            if let Side::Hi = pos {
                seat += round_size;
            }
        }
        seat
    }
    fn seat_id(&self) -> usize {
        let row = BoardingPass::seat_position(&self.rows);
        let col = BoardingPass::seat_position(&self.cols);
        (row * 8) + col
    }
}

#[aoc_generator(day5)]
fn parse_input(input: &str) -> Vec<BoardingPass> {
    input
        .lines()
        .filter_map(|line| BoardingPass::try_from(line).ok())
        .collect()
}

#[aoc(day5, part1)]
fn part1(input: &Vec<BoardingPass>) -> Option<usize> {
    input.into_iter().map(|p| p.seat_id()).max()
}

#[aoc(day5, part2)]
fn part2(input: &Vec<BoardingPass>) -> Option<usize> {
    let seen = input
        .into_iter()
        .map(|p| p.seat_id())
        .collect::<HashSet<_>>();
    // rust iter note ->
    // .iter() ALWAYS returns a reference (&T)
    // eliding .iter() calls .into_iter()
    // .into_iter() returns either T, &T, &mut T depending on the context
    // we don't want to "move" `seen` here, because we access it from the loop
    // therefore, just refer to it, so we call `.iter()`
    for id in seen.iter() {
        // we are looking for a gap in the consecutive ids -> not at the very start or end, just
        // somewhere in the middle
        let (poss, next) = (id + 1, id + 2);
        if !seen.contains(&poss) && seen.contains(&next) {
            return Some(poss);
        }
    }
    None
}
