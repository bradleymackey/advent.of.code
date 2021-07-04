// --- Day 10: Adapter Array ---

use std::collections::HashMap;

#[aoc_generator(day10)]
fn parse_input(input: &str) -> Vec<i64> {
    let mut vec: Vec<i64> = input.lines().filter_map(|l| l.parse().ok()).collect();
    vec.push(0);
    vec.push(vec.iter().max().unwrap() + 3);
    vec.sort();
    vec
}

#[aoc(day10, part1)]
fn part1(input: &Vec<i64>) -> Option<i64> {
    let mut n1 = 0;
    let mut n3 = 0;
    for idx in 1..input.len() {
        let diff = input[idx] - input[idx - 1];
        match diff {
            1 => n1 += 1,
            3 => n3 += 1,
            _ => continue,
        }
    }
    Some(n1 * n3)
}

#[aoc(day10, part2)]
fn part2(input: &Vec<i64>) -> Option<i64> {
    let mut counts = HashMap::<i64, i64>::default();
    counts.insert(0, 1); // 1 way to reach zero
    for adapter in &input.as_slice()[1..] {
        // add number of ways to 'bridge gap' to this connector
        // there's a difference of either 1,2,3 allowed, so any possible
        // combination can bridge this gap
        let ways = [1, 2, 3]
            .iter()
            .map(|dist| counts.get(&(adapter - dist)).unwrap_or(&0))
            .sum();
        counts.insert(*adapter, ways);
    }
    let highest = input.iter().max()?;
    let result = counts.get(highest)?;
    Some(*result)
}
