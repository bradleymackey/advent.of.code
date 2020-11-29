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

impl<'a, 'b> core::ops::Add<&'b Vector2> for &'a Vector2 {
    type Output = Vector2;

    fn add(self, other: &'b Vector2) -> Vector2 {
        Vector2 {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl<'a, 'b> core::ops::Sub<&'b Vector2> for &'a Vector2 {
    type Output = Vector2;

    fn sub(self, other: &'b Vector2) -> Vector2 {
        Vector2 {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}
