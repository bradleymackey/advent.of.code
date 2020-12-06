use num::{Num, Signed, Unsigned};
use std::fmt::Display;
use std::ops::{Add, AddAssign, Sub, SubAssign};

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub struct Vector2<N: Num + Ord + Copy> {
    pub x: N,
    pub y: N,
}

// rust note: even though I've specified N: Num
// in the type definition, I have to include the trait bound here too!
// very weird, since this should already be the case
#[allow(dead_code)]
impl<N> Vector2<N>
where
    N: Num + Ord + Copy,
{
    pub fn new(x: N, y: N) -> Self {
        Vector2 { x, y }
    }

    pub fn zero() -> Self {
        Vector2 {
            x: N::zero(),
            y: N::zero(),
        }
    }

    pub fn one() -> Self {
        Vector2 {
            x: N::one(),
            y: N::one(),
        }
    }

    pub fn min(&self) -> N {
        std::cmp::min(self.x, self.y)
    }

    pub fn max(&self) -> N {
        std::cmp::max(self.x, self.y)
    }

    /// creates a new vector from a tuple (x,y)
    pub fn from_tup(xy: (N, N)) -> Self {
        Vector2 { x: xy.0, y: xy.1 }
    }

    pub fn sum(&self) -> N {
        self.x + self.y
    }

    pub fn product(&self) -> N {
        self.x * self.y
    }
}

#[allow(dead_code)]
impl<N> Vector2<N>
where
    N: Num + Ord + Copy + Signed,
{
    pub fn distance_to_origin(&self) -> N {
        self.x.abs() + self.y.abs()
    }

    pub fn distance_to(&self, other: &Self) -> N {
        let x_dist = (self.x - other.x).abs();
        let y_dist = (self.y - other.y).abs();
        x_dist + y_dist
    }
}

#[allow(dead_code)]
impl<N> Vector2<N>
where
    N: Num + Ord + Copy + Unsigned,
{
    pub fn distance_unsigned_to_origin(&self) -> N {
        self.x + self.y
    }

    pub fn distance_unsigned_to(&self, other: &Self) -> N {
        let x_dist = if self.x > other.x {
            self.x - other.x
        } else {
            other.x - self.x
        };
        let y_dist = if self.y > other.y {
            self.y - other.y
        } else {
            other.y - self.y
        };
        x_dist + y_dist
    }
}

impl<N> Display for Vector2<N>
where
    N: Num + Ord + Display + Copy,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "(x:{}, y:{})", self.x, self.y)
    }
}

impl<N> Add for Vector2<N>
where
    N: Num + Ord + Copy,
{
    type Output = Self;
    fn add(self, other: Self) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl<N> AddAssign for Vector2<N>
where
    N: Num + Ord + Copy,
{
    fn add_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x + other.x,
            y: self.y + other.y,
        };
    }
}

impl<N> Sub for Vector2<N>
where
    N: Num + Ord + Copy,
{
    type Output = Self;
    fn sub(self, other: Self) -> Self {
        Vector2 {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}

impl<N> SubAssign for Vector2<N>
where
    N: Num + Ord + Copy,
{
    fn sub_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x - other.x,
            y: self.y - other.y,
        };
    }
}
