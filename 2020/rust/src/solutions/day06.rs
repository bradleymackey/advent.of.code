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
fn part1(input: &Input) -> usize {
    let mut total = 0;
    let mut seen_round = HashSet::new();
    for ans in input.iter() {
        match ans[..] {
            [] => {
                total += seen_round.len();
                seen_round.clear();
            }
            _ => {
                for ch in ans.iter() {
                    seen_round.insert(ch);
                }
            }
        }
    }
    total
}

#[aoc(day6, part2)]
fn part2(input: &Input) -> usize {
    let mut total = 0;
    let mut seen_round = HashMap::new();
    let mut members_round = 0;
    for ans in input.iter() {
        match ans[..] {
            [] => {
                // empty = end of round, add where all members have it
                total += seen_round
                    .values()
                    .filter(|cnt| **cnt == members_round)
                    .count();
                members_round = 0;
                seen_round.clear();
            }
            _ => {
                // add 1 to the count for this character
                for ch in ans.iter() {
                    *seen_round.entry(ch).or_insert(0) += 1;
                }
                members_round += 1;
            }
        }
    }
    total
}
