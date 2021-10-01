use std::convert::TryFrom;
use std::collections::HashSet;
use std::convert::TryInto;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum State {
    Active,
    Inactive,
}

impl TryFrom<char> for State {
    type Error = &'static str;
    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '#' => Ok(State::Active),
            '.' => Ok(State::Inactive),
            _ => Err("Invalid character in input"),
        }
    }
}

#[derive(Debug, Clone)]
struct Cube<const N: usize> {
    cells: HashSet<[i32; N]>,
}

impl<const N: usize> Cube<N> {
    fn from_first_layer(layer: Vec<Vec<State>>) -> Self {
        assert!(N >= 2, "Dimension must be at least 2");
        let cells = layer.iter().enumerate().flat_map(|(y, row)| {
            row.iter().enumerate().flat_map(move |(x, state)| {
                let mut arr = [0; N];
                arr[0] = x as i32;
                arr[1] = y as i32;
                match state {
                    State::Active => Some(arr),
                    State::Inactive => None,
                }
            })
        }).collect();
        Cube {
            cells,
        }
    }

    /// The total number of cells that are active
    fn active_count(&self) -> usize {
        self.cells.len()
    }

    fn neighbors(&self, pos: &[i32; N], include_self: bool) -> Vec<[i32; N]> {

        fn _neighbours(pos: &Vec<i32>, include_self: bool) -> Vec<Vec<i32>> {
            let mut result = vec![];
            if pos.len() == 1 {
                let val = pos[0];
                result.push(vec![val - 1]);
                if include_self {
                    result.push(vec![val]);
                }
                result.push(vec![val + 1]);
            } else {
                let subs = _neighbours(&pos[1..].to_vec(), true);
                for x in pos[0] - 1..=pos[0] + 1 {
                    for sub in &subs {
                        let mut n = vec![];
                        n.push(x);
                        n.extend(sub.iter());
                        if include_self || n != *pos {
                            result.push(n);
                        }
                    }
                }
            }
            result
        }

        _neighbours(&pos.to_vec(), include_self).into_iter().map(|n| {
            n.try_into().unwrap()
        }).collect()
    }

    /// Get the state for this cell.
    fn state_at(&self, pos: &[i32; N]) -> State {
        if self.cells.contains(pos) {
            State::Active
        } else {
            State::Inactive
        }
    }

    /// Compute the next state for this position after a game of life round.
    fn next_state(&self, pos: &[i32; N]) -> State {
        let neighbors = self.neighbors(&pos, false);
        let active_neighbors = neighbors
            .iter()
            .filter(|pos| self.state_at(pos) == State::Active)
            .count();
        match self.state_at(pos) {
            State::Active if active_neighbors == 2 || active_neighbors == 3 => State::Active,
            State::Inactive if active_neighbors == 3 => State::Active,
            _ => State::Inactive,
        }
    }

    fn game_of_life(&mut self) {
        let current_active = self.active_count();
        let mut processed = HashSet::with_capacity(current_active);
        let mut new_cells = HashSet::with_capacity(current_active);
        // cells we already have in the model
        for pos in self.cells.iter() {
            let ns = self.neighbors(pos, true);
            for n in ns {
                if processed.contains(&n) {
                    continue;
                }
                processed.insert(n);
                let new_state = self.next_state(&n);
                match new_state {
                    State::Active => new_cells.insert(n),
                    State::Inactive => new_cells.remove(&n),
                };
            }
        }
        self.cells = new_cells;
    }
}


#[aoc_generator(day17)]
fn parse_input(input: &str) -> Vec<Vec<State>> {
    input
        .lines()
        .map(|line| line.chars().map(|c| State::try_from(c).unwrap()).collect())
        .collect()
}

#[aoc(day17, part1)]
fn part1(input: &Vec<Vec<State>>) -> usize {
    let mut cube: Cube<3> = Cube::from_first_layer(input.clone());
    for _ in 0..6 {
        cube.game_of_life();
    }
    cube.active_count()
}

#[aoc(day17, part2)]
fn part2(input: &Vec<Vec<State>>) -> usize {
    let mut cube: Cube<4> = Cube::from_first_layer(input.clone());
    for _ in 0..6 {
        cube.game_of_life();
    }
    cube.active_count()
}
