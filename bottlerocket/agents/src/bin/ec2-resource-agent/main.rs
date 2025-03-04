/*!

Provides EC2 instances to be used for Bottlerocket tests.

!*/

mod ec2_provider;

use crate::ec2_provider::{Ec2Creator, Ec2Destroyer};
use agent_utils::init_agent_logger;
use resource_agent::clients::{DefaultAgentClient, DefaultInfoClient};
use resource_agent::error::AgentResult;
use resource_agent::{Agent, BootstrapData, Types};
use std::marker::PhantomData;

#[tokio::main]
async fn main() {
    init_agent_logger(env!("CARGO_CRATE_NAME"), None);
    let data = match BootstrapData::from_env() {
        Ok(ok) => ok,
        Err(e) => {
            eprintln!("Unable to get bootstrap data: {}", e);
            std::process::exit(1);
        }
    };
    if let Err(e) = run(data).await {
        eprintln!("{}", e);
        std::process::exit(1);
    };
}

async fn run(data: BootstrapData) -> AgentResult<()> {
    let types = Types {
        info_client: PhantomData::<DefaultInfoClient>::default(),
        agent_client: PhantomData::<DefaultAgentClient>::default(),
    };
    let agent = Agent::new(types, data, Ec2Creator {}, Ec2Destroyer {}).await?;
    agent.run().await
}
