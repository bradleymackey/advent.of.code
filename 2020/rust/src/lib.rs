extern crate aoc_runner;
#[macro_use]
extern crate aoc_runner_derive;

mod common {
    pub mod direction;
    pub mod vector2;
}

mod solutions {
    pub mod day01;
}

// define the the year that we are running aoc for
aoc_lib! { year = 2020 }
