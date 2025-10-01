use rustler::types::BigInt;
use num_bigint::BigUint;
use num_traits::identities::One;
use num_traits::identities::Zero;
use num_bigint::Sign;


#[rustler::nif]
fn fib(n: u128) -> u128 {
    let mut a = 0;
    let mut b = 1;
    let mut i = 1;

    while i < n {
        b = a + b;
        a = b - a;
        i += 1;
    }

    b
}


#[rustler::nif]
fn fib_bignums(n: u128) -> BigInt {
    let mut a = BigUint::zero();
    let mut b = BigUint::one();
    let mut i = 1;

    while i < n {
        b = &a + &b;
        a = &b - &a;
        i += 1;
    }

    BigInt::from_biguint(Sign::Plus, b)
}

const PHI: f64 = 1.618033988749895;

fn inv_sqrt(x: f64) -> f64 {
    let i = x.to_bits();
    let x2 = x * 0.5;
    let mut y = f64::from_bits(0x5FE6EB50C7B537A9 - (i >> 1));
    y = y * (1.5 - x2 * y * y);
    y = y * (1.5 - x2 * y * y);
    y * (1.5 - x2 * y * y)
}

#[rustler::nif]
fn phi_formula(n: i32) -> f64 {
    ((PHI.powi(n) - (-PHI).powi(-n)) * inv_sqrt(5.0)).ceil()
}


#[rustler::nif]
fn golden_ratio(n: f64) -> f64 {

    let mut a = 0.0;
    let mut b = 1.0;
    let mut i = 1.0;

    while i < n {
        b = a + b;
        a = b - a; 
        i += 1.0;
    }

    if b < a || b < 0.0 || a < 0.0 {
        panic!("overflow")
    }
    

    b / a
}


rustler::init!("Elixir.TurboFibonacci");
