// --- Day 13: Shuttle Search ---

use std::convert::From;

#[derive(Debug)]
struct Timetable {
    earliest: u64,
    /// Out of service 'x' -> None
    buses: Vec<Option<u64>>,
}

impl From<&str> for Timetable {
    fn from(s: &str) -> Self {
        let mut lines = s.lines().into_iter();
        let earliest: u64 = lines.next().unwrap().parse().unwrap();
        let buses: Vec<Option<u64>> = lines
            .next()
            .unwrap()
            .split(",")
            .into_iter()
            .map(|b| b.parse().ok())
            .collect();
        Self { earliest, buses }
    }
}

impl Timetable {
    fn real_buses(&self) -> Vec<u64> {
        self.buses.clone().into_iter().filter_map(|e| e).collect()
    }
}

#[aoc_generator(day13)]
fn parse_input(input: &str) -> Timetable {
    Timetable::from(input)
}

#[aoc(day13, part1)]
fn part1(input: &Timetable) -> Option<u64> {
    let real_buses = input.real_buses();
    for i in input.earliest.. {
        for bus in real_buses.iter() {
            if i % bus == 0 {
                let wait_mins = i - input.earliest;
                return Some(wait_mins * bus);
            }
        }
    }
    None
}

#[aoc(day13, part2)]
fn part2(input: &Timetable) -> u64 {
    // can't take credit for figuring this out -> see reddit
    // I originally used chinese remainder theorem, but this is much cleaner
    //
    // step in increments of the first bus until the second is 'in sync'
    // then step in increments of both (multiplied) until the third is 'in sync', and
    // we reach the result in a few hundred iterations!
    let mut factor = 1;
    let mut bus_num = 0;
    let mut time = 0;
    for bus in input.buses.iter() {
        bus_num += 1;
        if let Some(bus) = bus {
            while (time + bus_num) % bus != 0 {
                time += factor;
            }
            factor *= bus;
        }
    }

    time + 1
}
