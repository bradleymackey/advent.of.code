#[derive(Debug, Copy, Clone)]
enum Operation {
    Add,
    Mul,
}

#[derive(Debug, Clone)]
enum Item {
    Digit(u8),
    Op(Operation),
    Nested(Vec<Item>),
}

/// Parses a computation row into it's elements and the index to continue at, if applicable.
fn sequence_parser(input: &str) -> (Vec<Item>, Option<usize>) {
    use Item::*;
    let mut result = vec![];
    let mut i = 0;
    let chars = input.chars().collect::<Vec<_>>();
    while i < input.len() {
        let c = chars[i];
        match c {
            '(' => {
                let (nest, next) = sequence_parser(&input[i + 1..]);
                result.push(Nested(nest));
                if let Some(next) = next {
                    i += next;
                }
            }
            ')' => return (result, Some(i + 1)),
            '+' => result.push(Op(Operation::Add)),
            '*' => result.push(Op(Operation::Mul)),
            '0'..='9' => result.push(Digit(c.to_digit(10).unwrap() as u8)),
            _ => {}
        }
        i += 1;
    }
    (result, None)
}

#[aoc_generator(day18)]
fn parse_input(input: &str) -> Vec<Vec<Item>> {
    input
        .lines()
        .map(|line| {
            let (result, _) = sequence_parser(line);
            result
        })
        .collect()
}

fn compute_row(input: &Vec<Item>) -> u64 {
    let mut total = 0;
    let mut op = &Operation::Add;
    for item in input {
        use Item::*;
        match item {
            Op(next_op) => op = next_op,
            Digit(value) => {
                let val = *value as u64;
                match op {
                    Operation::Add => total += val,
                    Operation::Mul => total *= val,
                }
            }
            Nested(items) => {
                let nest_total = compute_row(items);
                match op {
                    Operation::Add => total += nest_total,
                    Operation::Mul => total *= nest_total,
                }
            }
        }
    }
    total
}

fn force_addition_precedence(input: Vec<Item>) -> Vec<Item> {
    use Item::*;
    let mut result = vec![];
    let mut temp = vec![];
    for item in input {
        match item {
            // chunk results prior to a multiplication,
            // which will raise the precendence of the addition
            Op(Operation::Mul) => {
                result.push(Nested(temp.clone()));
                result.push(item);
                temp.clear();
            }
            Nested(items) => temp.push(Nested(force_addition_precedence(items))),
            _ => temp.push(item),
        }
    }
    // get last remaining temp items
    result.push(Nested(temp));
    result
}

#[aoc(day18, part1)]
fn part1(input: &Vec<Vec<Item>>) -> u64 {
    input.iter().map(|row| compute_row(row)).sum()
}

#[aoc(day18, part2)]
fn part2(input: &Vec<Vec<Item>>) -> u64 {
    input
        .clone()
        .into_iter()
        .map(|row| force_addition_precedence(row))
        .map(|row| compute_row(&row))
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_parse() {
        let str = "1 + (2 * (3 * 3))";
        println!("{:?}", sequence_parser(str));
    }

    #[test]
    fn test_compute() {
        let str = "1 + (2 * (3 * 3))";
        let (parsed, _) = sequence_parser(str);
        let total = compute_row(&parsed);
        assert_eq!(total, 19);
    }
}
