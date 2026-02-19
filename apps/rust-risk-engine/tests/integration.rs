use rust_risk_engine::{aggregate_signal, RiskLevel, RiskSignal};

#[test]
fn critical_path_example() {
    let signal = RiskSignal {
        graph_score: 1.0,
        timeseries_score: 0.95,
        cross_chain_score: 0.9,
        reporter_confidence_bps: 10_000,
    };

    let out = aggregate_signal(&signal).expect("should aggregate");
    assert_eq!(out.level, RiskLevel::Critical);
    assert!(out.weighted_score_bps >= 9000);
}
