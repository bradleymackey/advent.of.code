use crate::common::vector2::Vector2;
use num::traits::Signed;
use num::Num;
use std::fmt;
use std::hash::Hash;

/// a direction that can also represent a compass direction
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
#[allow(dead_code)]
pub enum Direction {
    Up,
    Down,
    Left,
    Right,
}

use Direction::*;

impl fmt::Display for Direction {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.description())
    }
}

impl Direction {
    #[allow(dead_code)]
    pub fn description(&self) -> &str {
        match self {
            Up => "up",
            Down => "down",
            Left => "left",
            Right => "right",
        }
    }

    #[allow(dead_code)]
    pub fn from_char(letter: &char) -> Option<Self> {
        match letter {
            'U' => Some(Up),
            'D' => Some(Down),
            'L' => Some(Left),
            'R' => Some(Right),
            _ => None,
        }
    }

    pub fn vector<N>(&self) -> Vector2<N>
    where
        N: Copy,
        N: Ord,
        N: Num,
        N: Signed,
    {
        match self {
            Up => Vector2::new(N::zero(), N::one()),
            Down => Vector2::new(N::zero(), -N::one()),
            Left => Vector2::new(-N::one(), N::zero()),
            Right => Vector2::new(N::one(), N::zero()),
        }
    }
}

impl Direction {
    #[allow(dead_code)]
    pub fn compass(&self) -> &str {
        match self {
            Up => "north",
            Down => "south",
            Left => "west",
            Right => "east",
        }
    }

    #[allow(dead_code)]
    pub fn from_compass(dir: &str) -> Option<Self> {
        match dir {
            "north" => Some(Up),
            "south" => Some(Down),
            "west" => Some(Left),
            "east" => Some(Right),
            _ => None,
        }
    }
}
