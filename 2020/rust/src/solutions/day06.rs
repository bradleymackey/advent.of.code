// --- Day 6: Custom Customs ---
// not the most elegant solution, ideally this would be more functional

use std::collections::{HashMap, HashSet};
type Input = Vec<Vec<char>>;

#[aoc_generator(day6)]
fn parse_input(input: &str) -> Input {
    let mut vec: Input = input.lines().map(|line| line.chars().collect()).collect();
    // add empty to the end for the last
    vec.push(vec![]);
    vec
}

#[aoc(day6, part1)]
fn part1(input: &Input) -> u32 {
    let mut total = 0;
    let mut seen_round = HashSet::<char>::new();
    for chrs in input.iter() {
        // empty = end of group
        if chrs.is_empty() {
            total += seen_round.len() as u32;
            seen_round.clear();
        } else {
            seen_round.extend(chrs.iter());
        }
    }
    total
}

#[aoc(day6, part2)]
fn part2(input: &Input) -> u32 {
    let mut total = 0;
    let mut seen_round = HashMap::new();
    let mut members_round = 0;
    for chrs in input.iter() {
        // empty = end of group
        if chrs.is_empty() {
            total += seen_round.values().filter(|c| **c == members_round).count() as u32;
            members_round = 0;
            seen_round.clear();
        } else {
            members_round += 1;
            chrs.iter()
                .for_each(|c| *seen_round.entry(c).or_insert(0) += 1);
        }
    }
    total
}
