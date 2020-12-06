use num::Num;
use std::cmp::{max, min};
use std::fmt::{Display, Formatter};
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

    /// (x: 0, y: 0) - the origin
    pub fn zero() -> Self {
        Vector2 {
            x: N::zero(),
            y: N::zero(),
        }
    }

    /// (x: 1, y: 1)
    pub fn one() -> Self {
        Vector2 {
            x: N::one(),
            y: N::one(),
        }
    }

    /// the minumum of the x and y values
    pub fn min(&self) -> N {
        min(self.x, self.y)
    }

    /// the maximum of the x and y values
    pub fn max(&self) -> N {
        max(self.x, self.y)
    }

    /// creates a new vector from a tuple (x,y)
    pub fn from_tup(xy: (N, N)) -> Self {
        Vector2 { x: xy.0, y: xy.1 }
    }

    /// summation of the x and y components
    pub fn sum(&self) -> N {
        self.x + self.y
    }

    /// product of the x and y components
    pub fn product(&self) -> N {
        self.x * self.y
    }

    /// the manhattan distance between these 2 points
    pub fn man_distance_to(&self, other: &Self) -> N {
        let x_dist = max(self.x, other.x) - min(self.x, other.x);
        let y_dist = max(self.y, other.y) - min(self.y, other.y);
        x_dist + y_dist
    }

    /// the manhattan distance to the origin
    pub fn man_distance_to_origin(&self) -> N {
        self.man_distance_to(&Self::zero())
    }
}

impl<N> Display for Vector2<N>
where
    N: Num + Ord + Display + Copy,
{
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
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
