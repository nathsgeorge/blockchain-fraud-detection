use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskSignal {
    pub graph_score: f64,
    pub timeseries_score: f64,
    pub cross_chain_score: f64,
    pub reporter_confidence_bps: u16,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum RiskLevel {
    Low,
    Medium,
    High,
    Critical,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FraudAssessment {
    pub weighted_score_bps: u16,
    pub level: RiskLevel,
}

#[derive(thiserror::Error, Debug)]
pub enum EngineError {
    #[error("score must be within [0,1]")]
    InvalidScore,
}

pub fn aggregate_signal(signal: &RiskSignal) -> Result<FraudAssessment, EngineError> {
    validate(signal)?;

    let base_score = (signal.graph_score * 0.45)
        + (signal.timeseries_score * 0.35)
        + (signal.cross_chain_score * 0.20);

    let confidence_multiplier = (signal.reporter_confidence_bps as f64 / 10_000.0).clamp(0.4, 1.0);
    let weighted = (base_score * confidence_multiplier * 10_000.0).round() as u16;

    Ok(FraudAssessment {
        weighted_score_bps: weighted,
        level: score_to_level(weighted),
    })
}

fn validate(signal: &RiskSignal) -> Result<(), EngineError> {
    let scores = [signal.graph_score, signal.timeseries_score, signal.cross_chain_score];
    if scores.iter().any(|s| *s < 0.0 || *s > 1.0) {
        return Err(EngineError::InvalidScore);
    }
    Ok(())
}

pub fn score_to_level(score_bps: u16) -> RiskLevel {
    match score_bps {
        0..=3999 => RiskLevel::Low,
        4000..=5999 => RiskLevel::Medium,
        6000..=7999 => RiskLevel::High,
        _ => RiskLevel::Critical,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn computes_weighted_score() {
        let signal = RiskSignal {
            graph_score: 0.9,
            timeseries_score: 0.8,
            cross_chain_score: 0.7,
            reporter_confidence_bps: 9000,
        };
        let out = aggregate_signal(&signal).expect("valid");
        assert!(out.weighted_score_bps > 7000);
        assert_eq!(out.level, RiskLevel::High);
    }

    #[test]
    fn rejects_invalid_score() {
        let signal = RiskSignal {
            graph_score: 1.1,
            timeseries_score: 0.5,
            cross_chain_score: 0.1,
            reporter_confidence_bps: 5000,
        };
        assert!(aggregate_signal(&signal).is_err());
    }
}
