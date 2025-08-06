// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

/// @title FeeTurbulenceSentinel — detects gas volatility in basefee between blocks
contract FeeTurbulenceSentinel is ITrap {
    uint256 public constant THRESHOLD_PERCENT = 3; // Trigger on >3% basefee change

    function collect() external view override returns (bytes memory) {
        return abi.encode(block.basefee);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes("Insufficient data"));

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        if (previous == 0) return (false, bytes("Previous basefee is zero"));

        uint256 delta = current > previous ? current - previous : previous - current;
        uint256 percentChange = (delta * 100) / previous;

        if (percentChange >= THRESHOLD_PERCENT) {
            return (true, abi.encode("Basefee volatility >3%"));
        }

        return (false, bytes("Basefee stable"));
    }
}
