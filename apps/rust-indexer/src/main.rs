use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AnchorEvent {
    signal_id: String,
    wallet: String,
    chain_id: u64,
    score_bps: u16,
    cluster_id: u64,
}

fn parse_event(payload: &str) -> Result<AnchorEvent, serde_json::Error> {
    serde_json::from_str(payload)
}

fn main() {
    let sample = r#"{"signal_id":"0xabc","wallet":"0xBEEF","chain_id":137,"score_bps":8533,"cluster_id":44}"#;
    match parse_event(sample) {
        Ok(event) => {
            println!(
                "indexed signal={} chain={} wallet={} score_bps={} cluster={}",
                event.signal_id, event.chain_id, event.wallet, event.score_bps, event.cluster_id
            );
        }
        Err(err) => {
            eprintln!("failed to decode anchor event: {err}");
            std::process::exit(1);
        }
    }
}
