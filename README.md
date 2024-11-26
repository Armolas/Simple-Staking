# Simple Staking Smart Contract

This repository contains a **Simple Staking Smart Contract** written in Clarity for the Stacks blockchain. The contract allows users to stake their NFTs and earn fungible token (FT) rewards based on the staking duration. It integrates with external NFT and FT contracts to provide a seamless staking experience.

## Features

- **Stake NFTs**: Users can stake their NFTs to start earning rewards.
- **Earn FT Rewards**: Rewards are calculated based on the number of blocks the NFT has been staked.
- **Unstake NFTs**: Users can unstake their NFTs at any time and claim their accumulated rewards.
- **Claim Rewards**: Users can claim rewards for individual NFTs or all staked NFTs.
- **Track Staking Status**: View the status and staking details of NFTs.

## How It Works

1. Users stake their NFTs by calling the `stake-NFT` function.
2. The contract tracks staking details, including the block height and the staker's address.
3. Rewards are calculated based on the number of blocks since the NFT was last staked or claimed.
4. Users can unstake NFTs or claim their rewards at any time.

## Contract Overview

### Constants
- `profit-per-block`: The reward rate per block for staked NFTs.

### Data Structures
- **Maps**:
    - `NFT-status`: Tracks the staking status of NFTs, including the staker and the last staked height.
    - `user-stakes`: Maps users to the list of their staked NFTs.

### Public Functions
1. **Stake NFT**:  
     `stake-NFT (id uint)`  
     Stakes an NFT, transferring ownership to the contract.  
     - Requires the caller to own the NFT.
     - Updates staking details for the NFT.

2. **Unstake NFT**:  
     `unstake-NFT (id uint)`  
     Unstakes an NFT, transferring ownership back to the user and minting earned rewards.  
     - Requires the caller to be the staker.

3. **Claim One Reward**:  
     `claim-one (id uint)`  
     Claims rewards for a specific NFT without unstaking it.  
     - Requires the caller to be the staker.

4. **Claim All Rewards**:  
     `claim-rewards`  
     Claims rewards for all staked NFTs by the caller.

### Read-Only Functions
1. **Get Unclaimed Balance**:  
     `get-unclaimed-balance`  
     Returns the total rewards the caller can claim across all their staked NFTs.

2. **Check NFT Status**:  
     `check-NFT-status (id uint)`  
     Returns the staking status of a specific NFT.

3. **Get User Stakes**:  
     `get-user-stakes`  
     Returns the list of NFTs staked by the caller.

4. **Check Reward Rate**:  
     `check-reward-rate`  
     Returns the reward rate per block for the caller based on the number of staked NFTs.

## Deployment

1. Deploy the **NFT contract** (e.g., `simple-NFT`) and **FT contract** (e.g., `simple-FT`).
2. Deploy the **Simple Staking Smart Contract**.
3. Configure the staking contract to interact with the deployed NFT and FT contracts.

## Example Usage

1. **Stake an NFT**:
     ```clarity
     (contract-call? .simple-staking stake-NFT u1)
     ```
     Staking NFT with ID u1.

2. **Unstake an NFT**:
     ```clarity
     (contract-call? .simple-staking unstake-NFT u1)
     ```
     Unstaking NFT with ID u1 and claiming rewards.

3. **Claim Rewards for All NFTs**:
     ```clarity
     (contract-call? .simple-staking claim-rewards)
     ```

## Prerequisites

- A deployed NFT contract with a transfer and get-owner function.
- A deployed FT contract with a mint-stake-reward function.


## License

This project is licensed under the MIT License. See the LICENSE file for details.