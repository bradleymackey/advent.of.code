// --- Day 14: Docking Data ---
// implemented using bitwise operations alone, this is a fast implementation

use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::convert::From;
use std::str::FromStr;

/// 1 = presence of a masking bit
/// 0 = absencce of a masking bit
#[derive(Debug, Clone, Copy)]
struct Mask {
    ones: u64,
    zeros: u64,
    floating: u64,
}

impl Mask {
    fn blank() -> Self {
        Self::new(0, 0, 0)
    }
    fn new(ones: u64, zeros: u64, floating: u64) -> Self {
        Self {
            ones,
            zeros,
            floating,
        }
    }
    #[inline]
    fn apply_ones(&self, num: u64) -> u64 {
        num | self.ones
    }
    #[inline]
    fn apply_zeros(&self, num: u64) -> u64 {
        num & !self.zeros
    }
    #[inline]
    fn apply_one_zero(&self, num: u64) -> u64 {
        let num = self.apply_ones(num);
        let num = self.apply_zeros(num);
        num
    }
    /// Part 2 addresses.
    fn addresses(&self, addr: u64) -> Vec<u64> {
        let mut result = vec![];
        let addr = self.apply_ones(addr); // add 1 bits in, leaving zeros untouched
        let addr = addr & !self.floating; // zero-out floating bits in the input
        let bits_to_count = self.floating.count_ones();
        let count_upto = 2u32.pow(bits_to_count); // binary counter for the floating points
        for i in 0..count_upto as u64 {
            let mut candidate = addr;
            let mut bits_consumed = 0; // consume a bit 1-by-1 from the value to add
            for j in 0..u64::BITS as u64 {
                // determine if this bit index is actually a floating position
                let position = 1 << j;
                if position & self.floating != 0 {
                    let bit = (i >> bits_consumed) & 1; // last digit of the number to add
                    let value = bit << j; // adjusted for current floating mask position
                    candidate |= value;
                    bits_consumed += 1;
                    if bits_consumed == bits_to_count {
                        // optim: we've counted all the bits, so don't bother searching any more!
                        break;
                    }
                }
            }
            // candidate has been populated with the bit counter amount
            result.push(candidate);
        }
        result
    }
}

impl From<&str> for Mask {
    fn from(s: &str) -> Self {
        let mut zeros = 0;
        let mut ones = 0;
        let mut floating = 0;
        let mut value = 1;
        for digit in s.chars().into_iter().rev() {
            match digit {
                '0' => zeros += value,
                '1' => ones += value,
                _ => floating += value,
            }
            value <<= 1;
        }
        Self {
            ones,
            zeros,
            floating,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_mask_gen_ones() {
        let mask = "0XX1XX1";
        let mask = Mask::from(mask);
        assert_eq!(mask.ones, 0b0001001);
    }
    #[test]
    fn test_mask_gen_zeros() {
        let mask = "0XX1XX1";
        let mask = Mask::from(mask);
        assert_eq!(mask.zeros, 0b1000000);
    }
    #[test]
    fn test_mask_apply() {
        let mask = "0XX1XX1";
        let mask = Mask::from(mask);
        assert_eq!(mask.apply_one_zero(0b0000000), 0b0001001);
    }
    #[test]
    fn floating_mask_small() {
        let mask = "XXXX";
        let mask = Mask::from(mask);
        assert_eq!(mask.floating, 0b1111);
    }
    #[test]
    fn floating_mask_mixed() {
        let mask = "1111XXXX0000";
        let mask = Mask::from(mask);
        assert_eq!(mask.floating, 0b000011110000);
    }
    #[test]
    fn test_addresses_only_floating_2() {
        let mask = "XX";
        let mask = Mask::from(mask);
        let addrs = mask.addresses(0b11);
        assert_eq!(addrs, vec![0, 1, 2, 3]);
    }
    #[test]
    fn test_addresses_only_floating_3() {
        let mask = "XXX";
        let mask = Mask::from(mask);
        let addrs = mask.addresses(0b111);
        assert_eq!(addrs, vec![0, 1, 2, 3, 4, 5, 6, 7]);
    }
    #[test]
    fn test_addresses_mixed() {
        let mask = "11XX";
        let mask = Mask::from(mask);
        let addrs = mask.addresses(0b0000);
        assert_eq!(addrs, vec![0b1100, 0b1101, 0b1110, 0b1111]);
    }
    #[test]
    fn addresses_real_example() {
        let mask = "X1001X";
        let mask = Mask::from(mask);
        let addrs = mask.addresses(0b101010);
        assert_eq!(addrs, vec![0b011010, 0b011011, 0b111010, 0b111011]);
    }
}

#[derive(Debug, Clone, Copy)]
enum Action {
    SetMask(Mask),
    // key, value
    SetMemory(u64, u64),
}

impl From<&str> for Action {
    fn from(s: &str) -> Self {
        lazy_static! {
            static ref MEMORY_REGEX: Regex = Regex::from_str(r"^mem\[(\d+)\]\s=\s(\d+)$").unwrap();
            static ref MASK_REGEX: Regex = Regex::from_str(r"^mask\s=\s(.+)$").unwrap();
        }
        if MEMORY_REGEX.is_match(s) {
            let caps = MEMORY_REGEX.captures(s).unwrap();
            let addr: u64 = caps.get(1).unwrap().as_str().parse().unwrap();
            let val: u64 = caps.get(2).unwrap().as_str().parse().unwrap();
            Action::SetMemory(addr, val)
        } else {
            let caps = MASK_REGEX.captures(s).unwrap();
            let mask = Mask::from(caps.get(1).unwrap().as_str());
            Action::SetMask(mask)
        }
    }
}

#[derive(Debug, Clone)]
struct Program {
    mask: Mask,
    mem: HashMap<u64, u64>,
}

impl Program {
    fn new() -> Self {
        Self {
            mask: Mask::blank(),
            mem: HashMap::new(),
        }
    }
    fn run_part_1(&mut self, act: &Action) {
        match act {
            Action::SetMask(msk) => self.mask = msk.clone(),
            Action::SetMemory(key, val) => {
                let val = self.mask.apply_one_zero(*val);
                self.mem.insert(*key, val);
            }
        }
    }
    fn run_part_2(&mut self, act: &Action) {
        match act {
            Action::SetMask(msk) => self.mask = msk.clone(),
            Action::SetMemory(key, val) => {
                let addrs = self.mask.addresses(*key);
                for addr in addrs {
                    self.mem.insert(addr, *val);
                }
            }
        }
    }
}

#[aoc_generator(day14)]
fn parse_input(input: &str) -> Vec<Action> {
    input.lines().map(|l| Action::from(l)).collect()
}

#[aoc(day14, part1)]
fn part1(input: &Vec<Action>) -> u64 {
    let mut prog = Program::new();
    for act in input {
        prog.run_part_1(act);
    }
    prog.mem.values().sum()
}

#[aoc(day14, part2)]
fn part2(input: &Vec<Action>) -> u64 {
    let mut prog = Program::new();
    for act in input {
        prog.run_part_2(act);
    }
    prog.mem.values().sum()
}
