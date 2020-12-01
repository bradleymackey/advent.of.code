// --- Day 1: Report Repair ---
// nested for loops = slow performance
// we speed things up by sorting the vec, then binary searching for the remainings elements
// this avoids huge numbers of checks and gives us fast performance searching for the desired
// element, there's still a nested-for on part 2, but only double instead of triple

#[aoc_generator(day1)]
fn parse_input(input: &str) -> Vec<u32> {
    let mut vec: Vec<u32> = input.lines().map(|line| line.parse().unwrap()).collect();
    vec.sort();
    vec
}

#[aoc(day1, part1)]
fn part1(input: &Vec<u32>) -> Option<u32> {
    let target = 2020u32;
    for (i, num) in input.iter().enumerate() {
        let remaining_sum = target - num;
        let (_, right) = input.split_at(i + 1);
        if let Ok(_idx) = right.binary_search(&remaining_sum) {
            return Some(num * remaining_sum);
        }
    }
    None
}

#[aoc(day1, part2)]
fn part2(input: &Vec<u32>) -> Option<u32> {
    let target = 2020u32;
    for (i, num_i) in input.iter().enumerate() {
        let remaining_sum = target - num_i;
        let (_, right) = input.split_at(i + 1);
        for (j, num_j) in right.iter().enumerate() {
            let remaining_sum = remaining_sum - num_j;
            let (_, right) = input.split_at(j + 1);
            if let Ok(_idx) = right.binary_search(&remaining_sum) {
                return Some(num_i * num_j * remaining_sum);
            }
        }
    }
    None
}
