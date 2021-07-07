// --- Day 12: Rain Risk ---
// Compass:
//
//     N
//   W   E
//     S
//
// Corresponds to Left, Right, Up, Down.
// And the 2d plane x-axis and y-axis.

use crate::common::direction::Direction;
use crate::common::vector2::Vector2;
use std::convert::From;

#[derive(Debug, Clone, Copy)]
enum Rotation {
    Left,
    Right,
    Reverse,
    Noop,
}

impl Direction {
    fn rotated(&self, rot: Rotation) -> Self {
        match rot {
            Rotation::Left => self.rotated_left(),
            Rotation::Right => self.rotated_right(),
            Rotation::Reverse => self.reversed(),
            Rotation::Noop => *self,
        }
    }
}

#[derive(Debug, Clone, Copy)]
enum Action {
    Rotate(Rotation),
    Move(Vector2<i32>),
    MoveForward(i32),
}

impl From<&str> for Action {
    fn from(s: &str) -> Self {
        use Action::*;
        let chars: Vec<_> = s.chars().into_iter().collect();
        let first = chars[0];
        let amount = chars.iter().skip(1).collect::<String>().parse().unwrap();
        match first {
            'F' => MoveForward(amount),
            'L' => {
                let degrees = amount % 360;
                Rotate(match degrees {
                    0 => Rotation::Noop,
                    90 => Rotation::Left,
                    180 => Rotation::Reverse,
                    270 => Rotation::Right,
                    _ => panic!(),
                })
            }
            'R' => {
                let degrees = amount % 360;
                Rotate(match degrees {
                    0 => Rotation::Noop,
                    90 => Rotation::Right,
                    180 => Rotation::Reverse,
                    270 => Rotation::Left,
                    _ => panic!(),
                })
            }
            'N' => Move(Vector2::new(0, amount)),
            'S' => Move(Vector2::new(0, -amount)),
            'E' => Move(Vector2::new(amount, 0)),
            'W' => Move(Vector2::new(-amount, 0)),
            _ => panic!(),
        }
    }
}

#[aoc_generator(day12)]
fn parse_input(input: &str) -> Vec<Action> {
    input.lines().map(|l| Action::from(l)).collect()
}

#[aoc(day12, part1)]
fn part1(input: &Vec<Action>) -> i32 {
    let mut ship = Vector2::zero();
    let mut direction = Direction::Right;
    for action in input {
        match action {
            Action::Move(vec) => ship += *vec,
            Action::Rotate(dir) => direction = direction.rotated(*dir),
            Action::MoveForward(amount) => ship += direction.vector().scaled(*amount),
        }
    }
    ship.man_distance_to_origin()
}

#[aoc(day12, part2)]
fn part2(input: &Vec<Action>) -> i32 {
    let mut ship = Vector2::zero();
    let mut waypoint = Vector2::new(10, 1);
    for action in input {
        match action {
            Action::Move(vec) => waypoint += *vec,
            Action::Rotate(dir) => match dir {
                Rotation::Noop => {}
                Rotation::Reverse => waypoint = -waypoint,
                Rotation::Left => waypoint = waypoint.rotate_left_about_origin(),
                Rotation::Right => waypoint = waypoint.rotate_right_about_origin(),
            },
            Action::MoveForward(amount) => ship += waypoint.scaled(*amount),
        }
    }
    ship.man_distance_to_origin()
}
