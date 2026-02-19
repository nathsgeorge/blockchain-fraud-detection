use std::io::{self, Read};

use rust_risk_engine::{aggregate_signal, RiskSignal};

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).expect("failed to read stdin");

    let signal: RiskSignal = serde_json::from_str(&input).expect("invalid JSON payload");
    let assessment = aggregate_signal(&signal).expect("invalid signal");

    println!("{}", serde_json::to_string_pretty(&assessment).expect("serialize failed"));
}
