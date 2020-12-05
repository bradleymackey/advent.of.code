// we need to dereference refs in rust (to get the actual values out)
fn swap(a: &mut i32, b: &mut i32) {
    let tmp = *a;
    *a = *b;
    *b = tmp;
}

// internal swap, returns a number
pub fn testSwap() -> i32 {
    let mut a = 99_i32;
    let mut b = 100_i32;
    swap(a, b);
    a
}

#[allow(dead_code)]
pub fn ref_keyword() {
    // pattern match -> x = bool
    let x = false;
    // pattern match -> x = &bool
    let x = &false;
    // pattern match -> x = bool
    let &x = &false;
    // pattern match -> x = &bool
    let ref x = false;
    // pattern match -> x = &&bool
    let ref x = &false;
}

// cfg(test) indicates that this code should only be included if testing!
// this means smaller binaries when not compiling for tests
#[cfg(test)]
mod tests {
    #[test]
    fn example_test() {
        assert!(true);
    }
}

// this means that #[cfg(test)] can be included in other cases to run code only for unit tests,
// even if that code itself is not a unit test

pub fn my_cool_function() {
    let mut people = 0;
    people += 1;
    // only include the next block when testing!
    #[cfg(test)]
    {
        // people set to 100 only if testing
        people = 100;
    }
    // people = 100 when testing
    println!("{}", people);
}

// cfg can also have possible other arguments
// https://doc.rust-lang.org/reference/conditional-compilation.html
//
// The function is only included in the build when compiling for macOS
#[cfg(target_os = "macos")]
pub fn macos_only() {
    let best_os = "macos";
}
