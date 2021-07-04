// --- Day 9: Encoding Error ---

#[aoc_generator(day9)]
fn parse_input(input: &str) -> Vec<i32> {
    input.lines().filter_map(|l| l.parse().ok()).collect()
}

/// For part 1, the look-back size.
const LOOKBACK_SIZE: usize = 25;

fn invalid_number(input: &Vec<i32>) -> Option<i32> {
    'i: for i in LOOKBACK_SIZE..input.len() {
        let current = input[i];
        for j in (i - LOOKBACK_SIZE)..=i {
            for k in (i - LOOKBACK_SIZE)..=i {
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
fn part1(input: &Vec<i32>) -> Option<i32> {
    invalid_number(input)
}

/// For part 2. The minimum number of contiguous elements that make up the result.
const MIN_CONTIGUOUS_LEN: usize = 2;

#[aoc(day9, part2)]
fn part2(input: &Vec<i32>) -> Option<i32> {
    let target_number = invalid_number(input)?;
    for size in MIN_CONTIGUOUS_LEN..input.len() {
        for upper in size..input.len() {
            let lower = upper - size;
            let slice = &input[lower..upper];
            if slice.iter().sum::<i32>() == target_number {
                let min = slice.iter().min()?;
                let max = slice.iter().max()?;
                return Some(min + max);
            }
        }
    }
    None
}
