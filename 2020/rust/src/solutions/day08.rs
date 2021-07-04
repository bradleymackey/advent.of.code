// --- Day 8: Handheld Halting ---

use crate::common::parse_error::ParseError;
use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashSet;
use std::str::FromStr;

#[derive(Debug, Clone, Copy)]
enum Operation {
    Acc(isize),
    Jmp(isize),
    Nop(isize),
}

impl FromStr for Operation {
    type Err = ParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        lazy_static! {
            static ref OP_REGEX: Regex = Regex::from_str(r"^([a-z]+)\s([+-])(\d+)$").unwrap();
        }
        let captures = OP_REGEX.captures(s).ok_or(ParseError)?;
        let op_name = captures.get(1).ok_or(ParseError)?.as_str();
        let sign: char = captures.get(2).ok_or(ParseError)?.as_str().parse()?;
        let amount: isize = captures.get(3).ok_or(ParseError)?.as_str().parse()?;
        let shift = match sign {
            '+' => Ok(amount),
            '-' => Ok(-amount),
            _ => Err(ParseError),
        }?;
        match op_name {
            "acc" => Ok(Operation::Acc(shift)),
            "jmp" => Ok(Operation::Jmp(shift)),
            "nop" => Ok(Operation::Nop(shift)),
            _ => Err(ParseError),
        }
    }
}

#[derive(Debug)]
enum ComputerFinished {
    Looped,
    Terminated,
}

#[derive(Debug)]
struct Computer {
    acc: isize,
    pc: isize,
    program: Vec<Operation>,
    seen: HashSet<isize>,
    loop_flag: bool,
}

impl Computer {
    fn new(program: Vec<Operation>) -> Self {
        Self {
            acc: 0,
            pc: 0,
            program,
            seen: HashSet::default(),
            loop_flag: false,
        }
    }
    fn reset_run_state(&mut self) {
        self.acc = 0;
        self.pc = 0;
        self.loop_flag = false;
        self.seen.clear();
    }
    fn run_op(&mut self, op: &Operation) {
        use Operation::*;
        match op {
            Acc(dist) => {
                self.pc += 1;
                self.acc += dist;
            }
            Jmp(dist) => {
                self.pc += dist;
            }
            Nop(_) => {
                self.pc += 1;
            }
        }
        if self.seen.contains(&self.pc) {
            self.loop_flag = true;
        }
        self.seen.insert(self.pc);
    }
    /// Get the op that the program counter is currently pointing to.
    fn current_op(&self) -> Option<Operation> {
        // program counter should only ever be positive, otherwise it's a program error
        assert!(self.pc >= 0);
        let pc_usize = self.pc.wrapping_abs() as usize;
        let op = self.program.get(pc_usize)?.clone();
        Some(op)
    }
    /// For the index in the `program`, invert jmp => nop or nop => jmp accordingly
    fn invert_jmp_or_nop(&mut self, index: usize) {
        use Operation::*;
        match self.program[index] {
            Acc(_) => {}
            Jmp(dist) => {
                self.program[index] = Nop(dist);
            }
            Nop(dist) => {
                self.program[index] = Jmp(dist);
            }
        }
    }
    /// Run the computer until one of the possible outcomes occurs.
    fn run(&mut self) -> ComputerFinished {
        loop {
            match self.current_op() {
                Some(op) => {
                    self.run_op(&op);
                    if self.loop_flag {
                        return ComputerFinished::Looped;
                    }
                }
                // assume if we can't get an op, it's out of range,
                // therefore is terminated
                None => return ComputerFinished::Terminated,
            }
        }
    }
}

#[aoc_generator(day8)]
fn parse_input(input: &str) -> Vec<Operation> {
    input.lines().filter_map(|l| l.parse().ok()).collect()
}

#[aoc(day8, part1)]
fn part1(input: &Vec<Operation>) -> Option<isize> {
    let mut comp = Computer::new(input.clone());
    match comp.run() {
        ComputerFinished::Looped => Some(comp.acc),
        ComputerFinished::Terminated => None,
    }
}

#[aoc(day8, part2)]
fn part2(input: &Vec<Operation>) -> Option<isize> {
    // Attempts every possible swap until we find one that terminates.
    // We know that if the computer loops at any point, it's an infinite
    // loop, so that run can be disregarded.
    let mut comp = Computer::new(input.clone());
    for ins_index in 0..input.len() {
        comp.invert_jmp_or_nop(ins_index);
        match comp.run() {
            ComputerFinished::Looped => {}
            ComputerFinished::Terminated => return Some(comp.acc),
        }
        // we looped, so try the next instruction.
        // but first reset the state.
        comp.invert_jmp_or_nop(ins_index);
        comp.reset_run_state();
    }
    None
}
