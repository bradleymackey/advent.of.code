// --- Day 5: Binary Boarding ---

use std::collections::HashSet;

fn seat_id(boarding_pass: &str) -> u32 {
    boarding_pass
        .chars()
        // convert char to a bit
        .filter_map::<u8, _>(|c| match c {
            'F' | 'L' => Some(0),
            'B' | 'R' => Some(1),
            _ => None,
        })
        // convert bit list to a number, the seat id pops out!
        .fold(0, |acc, b| acc * 2 + b as u32)
}

#[aoc_generator(day5)]
fn parse_input(input: &str) -> Vec<u32> {
    input.lines().map(|line| seat_id(line)).collect()
}

#[aoc(day5, part1)]
fn part1(input: &Vec<u32>) -> u32 {
    input.into_iter().max().unwrap_or(&0).clone()
}

#[aoc(day5, part2)]
fn part2(input: &Vec<u32>) -> Option<u32> {
    let seen = input.into_iter().collect::<HashSet<_>>();
    // rust iter note ->
    // .iter() ALWAYS returns a reference (&T)
    // eliding .iter() calls .into_iter() (see docs for more info)
    for &id in seen.iter() {
        // we are looking for a gap in the consecutive ids -> not at the very start or end, just
        // somewhere in the middle
        let (poss, next) = (id + 1, id + 2);
        if !seen.contains(&poss) && seen.contains(&next) {
            return Some(poss);
        }
    }
    None
}
