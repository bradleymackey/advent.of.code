// --- Day 16: Ticket Translation ---
use std::collections::{HashMap, HashSet};
use std::convert::{From, TryInto};
use std::ops::RangeInclusive;

const FIELD_COUNT: usize = 20;

#[derive(Debug, Clone)]
struct Field {
    name: String,
    rule1: RangeInclusive<u32>,
    rule2: RangeInclusive<u32>,
}

impl Field {
    fn matches_value(&self, value: &u32) -> bool {
        self.rule1.contains(&value) || self.rule2.contains(&value)
    }
}

impl Field {
    /// Parsing helper for getting range from string range like '123-456'
    fn parse_range(s: &str) -> RangeInclusive<u32> {
        let mut range = s.split("-").map(|n| n.parse::<u32>().unwrap()).into_iter();
        RangeInclusive::new(range.next().unwrap(), range.next().unwrap())
    }
}

impl From<&str> for Field {
    // departure location: 28-184 or 203-952
    fn from(s: &str) -> Self {
        let mut parts = s.split(": ").into_iter();
        let name = parts.next().unwrap().to_string();
        let ranges = parts
            .next()
            .unwrap()
            .split(" or ")
            .into_iter()
            .map(|s| Field::parse_range(s))
            .collect::<Vec<_>>();
        Self {
            name,
            rule1: ranges[0].clone(),
            rule2: ranges[1].clone(),
        }
    }
}

#[derive(Debug, Clone)]
struct Ticket {
    values: [u32; FIELD_COUNT],
}

impl From<&str> for Ticket {
    fn from(s: &str) -> Self {
        let nums: Vec<_> = s.split(",").map(|n| n.parse::<u32>().unwrap()).collect();
        let values: [_; FIELD_COUNT] = nums.as_slice().try_into().unwrap();
        Self { values }
    }
}

#[derive(Debug)]
struct Manifest {
    fields: [Field; FIELD_COUNT],
    my_ticket: Ticket,
    other_tickets: Vec<Ticket>,
}

impl From<&str> for Manifest {
    fn from(s: &str) -> Self {
        let mut lines = s.lines();
        let fields: [Field; FIELD_COUNT] = (0..FIELD_COUNT)
            .map(|_| lines.next().unwrap())
            .map(|l| Field::from(l))
            .collect::<Vec<_>>()
            .try_into()
            .ok()
            .unwrap();
        lines.next();
        lines.next();
        let my_ticket = lines.next().unwrap();
        let my_ticket = Ticket::from(my_ticket);
        lines.next();
        lines.next();
        let mut other_tickets = vec![];
        while let Some(ticket) = lines.next() {
            let other = Ticket::from(ticket);
            other_tickets.push(other);
        }
        Self {
            fields,
            my_ticket,
            other_tickets,
        }
    }
}

impl Manifest {
    fn is_valid(&self, ticket: &Ticket) -> bool {
        for v in ticket.values.iter() {
            let is_valid = self
                .fields
                .iter()
                .map(|f| f.matches_value(&v))
                .collect::<Vec<_>>()
                .contains(&true);
            if !is_valid {
                return false;
            }
        }
        true
    }
    fn invalid_sum(&self, ticket: &Ticket) -> u32 {
        let mut total = 0;
        for v in ticket.values.iter() {
            let is_valid = self
                .fields
                .iter()
                .map(|f| f.matches_value(&v))
                .collect::<Vec<_>>()
                .contains(&true);
            if !is_valid {
                total += v;
            }
        }
        total
    }
}

#[aoc_generator(day16)]
fn parse_input(input: &str) -> Manifest {
    Manifest::from(input)
}

#[aoc(day16, part1)]
fn part1(input: &Manifest) -> u32 {
    input
        .other_tickets
        .iter()
        .map(|t| input.invalid_sum(t))
        .sum()
}

#[aoc(day16, part2)]
fn part2(input: &Manifest) -> u64 {
    let mut possible = HashMap::new();
    for i in 0..FIELD_COUNT {
        let all_candidates: HashSet<_> = (0..FIELD_COUNT).collect();
        possible.insert(i, all_candidates);
    }

    let mut indexes = [0_usize; FIELD_COUNT];

    let tickets: Vec<_> = input.other_tickets.iter().filter(|t| input.is_valid(t)).collect();
    while possible.len() > 0 {
        for ticket in tickets.iter() {
            for i in 0..FIELD_COUNT {
                let field = &input.fields[i];
                for j in 0..FIELD_COUNT {
                    let value = ticket.values[j];
                    let contains = field.rule1.contains(&value) || field.rule2.contains(&value);
                    if !contains {
                        if let Some(entry) = possible.get_mut(&i) {
                            entry.remove(&j);
                        }
                    }
                }
            }
        }

        let confirmed_candidates: Vec<(usize, usize)> = possible.iter().filter_map(|(k, v)| {
            if v.len() == 1 {
                Some((*k, *v.iter().next().unwrap()))
            } else {
                None
            }
        }).collect();

        for (key, value) in confirmed_candidates {
            indexes[key] = value;
            possible.remove(&key);
            // also remove from all other keys
            for k in possible.clone().keys() {
                possible.get_mut(&k).unwrap().remove(&value);
            }
        }

    }

    // the first 6 are the values that we want, get them out of our ticket
    let my_ticket_values = indexes[0..6].iter().map(|idx| input.my_ticket.values[*idx] as u64);
    my_ticket_values.product()
}
