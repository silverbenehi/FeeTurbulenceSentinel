# FeeTurbulenceSentinel

## Objective
Create a highly responsive Drosera trap that:
Monitors the block.basefee fluctuations between consecutive Ethereum blocks,
Implements the standard collect() / shouldRespond() Drosera interface,
Triggers a response whenever the basefee changes by more than 2% compared to the previous block,
Integrates seamlessly with an on-chain alert contract to broadcast turbulence signals.

## Problem
Ethereum's basefee mechanism directly influences transaction costs and network activity. Sudden or frequent shifts in the basefee may indicate network congestion spikes, fee market turbulence, or even manipulation attempts.
For dApps relying on gas cost predictability, DeFi protocols, or DAOs, such turbulence can impact user experience and contract behavior. Detecting these rapid basefee fluctuations in real-time allows proactive responses.

## Solution
The FeeTurbulenceSentinel trap captures the current block's basefee at each block, compares it to the previous one, and if the change exceeds the 2% threshold, it triggers an alert via a dedicated signaling contract.
This setup enables continuous monitoring of fee volatility, offering timely alerts for automation or human operators to take necessary action.

## Trap Logic Summary

**Contract: FeeTurbulenceSentinel.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract FeeTurbulenceSentinel is ITrap {
    uint256 public constant thresholdPercent = 2;

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, bytes("Insufficient data"));
        }

        uint256 currentBasefee = abi.decode(data[0], (uint256));
        uint256 previousBasefee = abi.decode(data[1], (uint256));

        uint256 diff = currentBasefee > previousBasefee ? currentBasefee - previousBasefee : previousBasefee - currentBasefee;
        uint256 percentChange = (diff * 100) / previousBasefee;

        if (percentChange > thresholdPercent) {
            return (true, abi.encode("Basefee turbulence detected"));
        }

        return (false, bytes("No significant turbulence"));
    }
}
```

## Response Contract

**Contract: TurbulenceSignalRelay.sol**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TurbulenceSignalRelay {
    event TurbulenceSignal(bytes data);

    function broadcast(bytes calldata data) external {
        emit TurbulenceSignal(data);
    }
}
```
## What It Solves

- Detects frequent and meaningful volatility in gas fees,
- Provides a robust on-chain alerting mechanism for gas market turbulence,
- Enables protocols and operators to react quickly to changing network conditions,
- Supports high-frequency triggering with minimal false negatives.


## Deployment & Setup Instructions

Deploy both contracts with Foundry or your preferred tool:


```solidity
forge create src/FeeTurbulenceSentinel.sol:FeeTurbulenceSentinel --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
forge create src/TurbulenceSignalRelay.sol:TurbulenceSignalRelay --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>
```

Update drosera.toml with deployed addresses and function:

[traps.fee_turbulence_sentinel]

path = "out/FeeTurbulenceSentinel.sol/FeeTurbulenceSentinel.json"
response_contract = "<TurbulenceSignalRelay address>"
response_function = "broadcast(bytes)"


Apply configuration:

```solidity
DROSERA_PRIVATE_KEY=0xYOUR_PRIVATE_KEY drosera apply
```

## Testing the Trap

- Watch the basefee values change naturally on an active Ethereum testnet,
- Observe logs or events emitted by the TurbulenceSignalRelay contract,
- Confirm that alerts trigger at approximately every block where basefee changes >2%

## Potential Improvements

- Allow dynamic threshold adjustment via a setter function,
- Incorporate other block header fields (e.g., gaslimit) for a more comprehensive volatility check,
- Forward alerts to off-chain systems or multisig wallets for emergency intervention.

## Metadata
- Created: August 6, 2025
- Author: Erbenehi
- Telegram: @cruborpa
- Discord: emmanuelebenehi
- X : @silverbenehi
