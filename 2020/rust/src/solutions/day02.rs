// --- Day 2: Password Philosophy ---
// with help from: https://qubyte.codes/blog/parsing-input-from-stdin-to-structures-in-rust
// maybe just use the `recap` crate in the future - it does a lot of this parsing work for us!
// I'm really a fan of the ability to write unit tests so easily! This definetly encourages safe
// code.

use crate::common::parse_error::ParseError;
use lazy_static::lazy_static;
use regex::Regex;
use std::ops::RangeInclusive;
use std::str::FromStr;

#[derive(Debug)]
struct Condition {
    character: char,
    range: RangeInclusive<usize>,
}

impl Condition {
    /// interpret the range values an indices (subtract 1 from each,
    /// since they are not zero-indexed to begin with)
    fn range_indexes(&self) -> (usize, usize) {
        (self.range.start() - 1, self.range.end() - 1)
    }
}

#[derive(Debug)]
struct Password {
    passwd: String,
    cond: Condition,
}

impl Password {
    fn new(passwd: &str, character: char, min: usize, max: usize) -> Self {
        let cond = Condition {
            character,
            range: min..=max,
        };
        Password {
            passwd: String::from(passwd),
            cond,
        }
    }

    /// returns true if the key character condition is valid on the password
    /// (part 1)
    fn is_valid_count_range(&self) -> bool {
        let key_chars = self
            .passwd
            .chars()
            .filter(|&c| c == self.cond.character)
            .count();
        self.cond.range.contains(&key_chars)
    }

    /// returns true if the key character condition is valid on the password
    /// interpreted here as range positions in the string
    /// (part 2)
    fn is_valid_char_position(&self) -> bool {
        let chars: Vec<char> = self.passwd.chars().collect();
        let key_chr = self.cond.character;
        let (fst_idx, snd_idx) = self.cond.range_indexes();
        let (fst_chr, snd_chr) = (chars[fst_idx], chars[snd_idx]);
        let (fst_match, snd_match) = (fst_chr == key_chr, snd_chr == key_chr);
        (fst_match || snd_match) && fst_chr != snd_chr
    }
}

const PASSWORD_REGEX: &str = r"^(\d+)-(\d+) (\w): (\w+)$";

impl FromStr for Password {
    type Err = ParseError;

    fn from_str(password_str: &str) -> Result<Self, Self::Err> {
        lazy_static! {
            // lazy static ensures this regex will only be created once
            static ref REG: Regex = Regex::new(PASSWORD_REGEX).unwrap();
        }

        REG.captures(password_str)
            .ok_or(ParseError)
            .and_then(|cap| {
                Ok(Password::new(
                    &cap[4],
                    // we implement From<> for Int error and char error to
                    // our custom error type
                    cap[3].parse()?,
                    cap[1].parse()?,
                    cap[2].parse()?,
                ))
            })
    }
}

#[aoc_generator(day2)]
fn parse_input(input: &str) -> Vec<Password> {
    input.lines().map(|line| line.parse().unwrap()).collect()
}

#[aoc(day2, part1)]
fn part1(input: &Vec<Password>) -> usize {
    input
        .into_iter()
        .filter(|pw| pw.is_valid_count_range())
        .count()
}

#[aoc(day2, part2)]
fn part2(input: &Vec<Password>) -> usize {
    input
        .into_iter()
        .filter(|pw| pw.is_valid_char_position())
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn password_no_cond() {
        let pw = Password::new("abcd", 'n', 0, 0);
        assert!(pw.is_valid_count_range());
    }
    #[test]
    fn password_one_char_valid() {
        let pw = Password::new("abcd", 'a', 1, 3);
        assert!(pw.is_valid_count_range());
    }
    #[test]
    fn password_one_char_not_valid() {
        let pw = Password::new("bcd", 'a', 1, 3);
        assert!(!pw.is_valid_count_range());
    }
    #[test]
    fn one_pos_valid() {
        let pw = Password::new("abcde", 'a', 1, 3);
        assert!(pw.is_valid_char_position());
    }
    #[test]
    fn no_pos_invalid() {
        let pw = Password::new("cdefg", 'b', 1, 3);
        assert!(!pw.is_valid_char_position());
    }
    #[test]
    fn two_pos_invalid() {
        let pw = Password::new("cccccccccc", 'c', 2, 9);
        assert!(!pw.is_valid_char_position());
    }
}
