// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TurbulenceSignalRelay — emits signals when fee volatility is detected
contract TurbulenceSignalRelay {
    event FeeTurbulenceSignal(bytes data);

    function broadcast(bytes calldata data) external {
        emit FeeTurbulenceSignal(data);
    }
}
