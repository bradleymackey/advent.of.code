// --- Day 4: Passport Processing ---
// rust has the best REGEX in the business, without a doubt
// single-complication of the regexes results in at least a 100x performance improvement
// complile and store! this gives the best performance!

use crate::common::parse_error::ParseError;
use lazy_static::lazy_static;
use regex::Regex;
use std::ops::RangeInclusive;
use std::str::FromStr;

#[derive(Debug, Default)]
struct Passport {
    byr: Option<i32>,
    iyr: Option<i32>,
    eyr: Option<i32>,
    hgt: Option<String>,
    hcl: Option<String>,
    ecl: Option<String>,
    pid: Option<String>,
    cid: Option<String>,
}

lazy_static! {
    static ref HEIGHT_REGEX: Regex =
        Regex::new(r"^(1([5-8][0-9]|9[0-3])cm|(59|6[0-9]|7[0-6])in)$").unwrap();
    static ref HAIR_REGEX: Regex = Regex::new(r"^#[0-9a-f]{6}$").unwrap();
    static ref EYE_REGEX: Regex = Regex::new(r"^(amb|blu|brn|gry|grn|hzl|oth)$").unwrap();
    static ref PID_REGEX: Regex = Regex::new(r"^[0-9]{9}$").unwrap();
}

impl Passport {
    /// part 1, simple presence check
    fn is_valid(&self) -> bool {
        self.byr.is_some()
            && self.iyr.is_some()
            && self.eyr.is_some()
            && self.hgt.is_some()
            && self.hcl.is_some()
            && self.ecl.is_some()
            && self.pid.is_some()
    }

    fn is_year_valid(yr: Option<i32>, range: RangeInclusive<i32>) -> bool {
        match yr {
            Some(y) => range.contains(&y),
            None => false,
        }
    }

    fn matches_regex(input: &Option<String>, regex: &Regex) -> bool {
        match input {
            Some(inp) => regex.is_match(inp),
            None => false,
        }
    }

    /// part 2, regexes help a lot
    fn is_extended_valid(&self) -> bool {
        Passport::is_year_valid(self.byr, 1920..=2002)
            && Passport::is_year_valid(self.iyr, 2010..=2020)
            && Passport::is_year_valid(self.eyr, 2020..=2030)
            && Passport::matches_regex(&self.hgt, &HEIGHT_REGEX)
            && Passport::matches_regex(&self.hcl, &HAIR_REGEX)
            && Passport::matches_regex(&self.ecl, &EYE_REGEX)
            && Passport::matches_regex(&self.pid, &PID_REGEX)
    }
}

impl FromStr for Passport {
    type Err = ParseError;

    /// assume we are passed a list of the items, in any order
    fn from_str(port_str: &str) -> Result<Self, Self::Err> {
        if port_str.is_empty() {
            return Err(ParseError);
        }
        let items = port_str.split(" ").filter(|s| s.len() > 0);
        let mut new_port: Passport = Default::default();
        for item in items {
            let parts: Vec<&str> = item.split(":").map(|l| l.trim()).collect();
            let ky = parts[0];
            let vl = parts[1];
            match ky {
                "byr" => new_port.byr = vl.parse().ok(),
                "iyr" => new_port.iyr = vl.parse().ok(),
                "eyr" => new_port.eyr = vl.parse().ok(),
                "hgt" => new_port.hgt = vl.parse().ok(),
                "hcl" => new_port.hcl = vl.parse().ok(),
                "ecl" => new_port.ecl = vl.parse().ok(),
                "pid" => new_port.pid = vl.parse().ok(),
                "cid" => new_port.cid = vl.parse().ok(),
                _ => {}
            };
        }
        Ok(new_port)
    }
}

#[aoc_generator(day4)]
fn parse_input(input: &str) -> Vec<Passport> {
    let mut ports = vec![];
    let mut accumulator = "".to_string();
    // peekable so we don't need to do an awkward extra check after the loop
    let mut lines = input.lines().map(|l| l.trim()).peekable();
    while let Some(line) = lines.next() {
        accumulator.push_str(line);
        accumulator.push_str(" ");
        match lines.peek() {
            // if the next line ends the passport, add the current
            Some(&"") | None => {
                if let Ok(new_port) = Passport::from_str(accumulator.as_str()) {
                    ports.push(new_port);
                }
                accumulator = "".to_string();
                // consume the separator
                let _ = lines.next();
            }
            Some(_) => continue,
        };
    }
    ports
}

#[aoc(day4, part1)]
fn part1(input: &Vec<Passport>) -> usize {
    input.into_iter().filter(|p| p.is_valid()).count()
}

#[aoc(day4, part2)]
fn part2(input: &Vec<Passport>) -> usize {
    input.into_iter().filter(|p| p.is_extended_valid()).count()
}
