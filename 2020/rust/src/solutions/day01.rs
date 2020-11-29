// use std::iter;

#[aoc_generator(day1)]
fn parse_input(input: &str) -> Vec<u32> {
    vec![1, 2, 3]
    // input.lines().map(|line| line.parse().unwrap()).collect()
}

#[aoc(day1, part1)]
fn part1(input: &Vec<u32>) -> u32 {
    10
    // input.iter().map(|mass| calculate_fuel(mass).unwrap()).sum()
}

#[aoc(day1, part2)]
fn part2(input: &Vec<u32>) -> u32 {
    10
    // map the weight of each module to the amount of fuel that it requires
    // input.iter().map(calculate_module_fuel).sum()
}
