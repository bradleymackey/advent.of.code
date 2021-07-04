// --- Day 7: Handy Haversacks ---

use crate::common::parse_error::ParseError;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::{HashMap, HashSet, VecDeque};
use std::str::FromStr;

/// Keys a given bag in the carosel.
type BagID = String;
/// Direct relationships between parent bags and child bags.
/// For a given parent bag ID, stores the number of children of a given bag.
type BagCarosel = HashMap<BagID, HashMap<BagID, u32>>;

/**
 * returns `None` if a child cannot be parsed
 */
fn child_bag(string: &str) -> Option<(BagID, u32)> {
    lazy_static! {
        // bag(s) <- optionally match the 's'
        static ref CHILD_REGEX: Regex = Regex::from_str(r"^(\d+)\s(.*)\sbags?$").unwrap();
    }
    // there may be 'contains no other bags'
    // so we question mark unwrap the optional to return 'None'
    // in the event that the regex did not match
    let captures = CHILD_REGEX.captures(string)?;
    let amount = captures.get(1)?.as_str().parse().unwrap();
    let name = captures.get(2)?.as_str().to_string();
    Some((name, amount))
}

/// assume we are passed a list of the items, in any order
fn parent_bag(bag: &str) -> Result<(BagID, HashMap<BagID, u32>), ParseError> {
    if bag.is_empty() {
        return Err(ParseError);
    }
    lazy_static! {
        // bag(s) <- optionally match the 's'
        static ref BAG_REGEX: Regex =
            Regex::from_str(r"^(.*)\sbags?\scontain\s(.*)\.$").unwrap();
    }
    let captures = BAG_REGEX.captures(bag).ok_or(ParseError)?;
    let our_bag = captures.get(1).ok_or(ParseError)?.as_str();

    let mut children = HashMap::default();
    let other_bags = captures.get(2).ok_or(ParseError)?.as_str();
    const BAG_LIST_DELIMITER: &str = ", ";
    for other in other_bags.split(BAG_LIST_DELIMITER) {
        if let Some((name, count)) = child_bag(other) {
            children.insert(name, count);
        }
    }
    Ok((BagID::from(our_bag), children))
}

#[aoc_generator(day7)]
fn parse_input(input: &str) -> BagCarosel {
    input.lines().filter_map(|line| parent_bag(line).ok()).collect()
}

#[aoc(day7, part1)]
fn part1(input: &BagCarosel) -> usize {
    // this could be made a load more efficient if we build a graph,
    // then resolve bottom-down from the shiny gold bag
    let target = "shiny gold";
    let mut queue = VecDeque::default();
    queue.push_back(target);

    let mut seen = HashSet::<&BagID>::default();
    while let Some(target) = queue.pop_front() {
        for (name, children) in input {
            if seen.contains(name) {
                continue;
            }
            if children.contains_key(target) {
                queue.push_back(name);
                seen.insert(name);
            }
        }
    }
    seen.len()
}

#[aoc(day7, part2)]
fn part2(input: &BagCarosel) -> u32 {
    // Computes the number of bags held within a given bag
    fn holds(input: &BagCarosel, target: &BagID) -> u32 {
        input
            .get(target)
            .unwrap()
            .iter()
            // add direct children, then all indirect children
            .map(|(child_name, count)| count + count * holds(input, child_name))
            .sum()
    }

    let target = BagID::from("shiny gold");
    holds(input, &target)
}
