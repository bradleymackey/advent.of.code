// --- Day 15: Rambunctious Recitation ---
//
use std::collections::HashMap;

#[aoc_generator(day15)]
fn parse_input(input: &str) -> Vec<u32> {
    input.split(",").map(|line| line.parse().unwrap()).collect()
}

#[aoc(day15, part1)]
fn part1(input: &Vec<u32>) -> u32 {
    get_number(input, 2020)
}

#[aoc(day15, part2)]
fn part2(input: &Vec<u32>) -> u32 {
    get_number(input, 30_000_000)
}

fn get_number(input: &Vec<u32>, turn_number: u32) -> u32 {
    // number -> turn it was last spoken
    let mut map = HashMap::new();
    let mut turn = 0;
    let mut num = 0;
    for val in input.iter() {
        turn += 1;
        num = *val;
        map.insert(num, turn);
    }
    while turn < turn_number {
        let prev_num = num;
        let prev_turn = turn;
        turn += 1;
        num = match map.get(&prev_num) {
            Some(last_seen_turn) => prev_turn - last_seen_turn,
            None => 0,
        };
        map.insert(prev_num, prev_turn);
    }
    num
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_nums() {
        let result = part1(&vec![1, 3, 2]);
        assert_eq!(result, 1);
    }

    #[test]
    fn test_nums_2() {
        let result = part1(&vec![2, 1, 3]);
        assert_eq!(result, 10);
    }

    #[test]
    fn test_nums_3() {
        let result = part1(&vec![1, 2, 3]);
        assert_eq!(result, 27);
    }
}
