// --- Day 9: Encoding Error ---

#[aoc_generator(day9)]
fn parse_input(input: &str) -> Vec<i64> {
    input.lines().filter_map(|l| l.parse().ok()).collect()
}

const WINDOW_SIZE: usize = 25;

fn invalid_number(input: &Vec<i64>) -> Option<i64> {
    'i: for i in WINDOW_SIZE..input.len() {
        let current = input[i];
        for j in (i - WINDOW_SIZE)..=i {
            for k in (i - WINDOW_SIZE)..=i {
                if j == k {
                    continue;
                }
                if input[j] + input[k] == input[i] {
                    continue 'i;
                }
            }
        }
        return Some(current);
    }
    None
}

#[aoc(day9, part1)]
fn part1(input: &Vec<i64>) -> Option<i64> {
    invalid_number(input)
}

#[aoc(day9, part2)]
fn part2(input: &Vec<i64>) -> Option<i64> {
    let target_number = invalid_number(input)?;
    for size in 2..input.len() {
        for upper in size..input.len() {
            let lower = upper - size;
            let slice = &input[lower..upper];
            if slice.iter().sum::<i64>() == target_number {
                let min = slice.iter().min()?;
                let max = slice.iter().max()?;
                return Some(min + max);
            }
        }
    }
    None
}
