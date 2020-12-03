use std::ops::{Add, AddAssign, Sub, SubAssign};

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub struct Vector2 {
    pub x: isize,
    pub y: isize,
}

impl std::fmt::Display for Vector2 {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

#[allow(dead_code)]
impl Vector2 {
    pub fn zero() -> Self {
        Vector2 { x: 0, y: 0 }
    }

    pub fn one() -> Self {
        Vector2 { x: 1, y: 1 }
    }

    pub fn min(&self) -> isize {
        std::cmp::min(self.x, self.y)
    }

    pub fn max(&self) -> isize {
        std::cmp::max(self.x, self.y)
    }

    pub fn new(x: isize, y: isize) -> Self {
        Vector2 { x: x, y: y }
    }

    /// creates a new vector from a tuple (x,y)
    pub fn from_tup(xy: (isize, isize)) -> Self {
        Vector2 { x: xy.0, y: xy.1 }
    }

    pub fn sum(&self) -> isize {
        self.x + self.y
    }

    pub fn product(&self) -> isize {
        self.x * self.y
    }

    pub fn distance_to_origin(&self) -> isize {
        self.x.abs() + self.y.abs()
    }

    pub fn distance_to(&self, other: &Vector2) -> isize {
        let x_dist = (self.x - other.x).abs();
        let y_dist = (self.y - other.y).abs();
        x_dist + y_dist
    }
}

impl Add for Vector2 {
    type Output = Vector2;
    fn add(self, other: Vector2) -> Vector2 {
        Vector2 {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl AddAssign for Vector2 {
    fn add_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x + other.x,
            y: self.y + other.y,
        };
    }
}

impl Sub for Vector2 {
    type Output = Vector2;
    fn sub(self, other: Vector2) -> Vector2 {
        Vector2 {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}

impl SubAssign for Vector2 {
    fn sub_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x - other.x,
            y: self.y - other.y,
        };
    }
}
