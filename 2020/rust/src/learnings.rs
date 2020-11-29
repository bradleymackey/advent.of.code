// we need to dereference refs in rust!
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
