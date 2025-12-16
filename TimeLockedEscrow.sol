// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TimeLockedEscrow
/// @author Your Name
/// @notice Simple ETH escrow with time-lock and arbiter resolution
/// @dev Demonstrates safe fund custody, state management, and best practices
contract TimeLockedEscrow {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotAuthorized();
    error InvalidState();
    error EscrowNotExpired();
    error ZeroAddress();
    error NoFunds();

    /*//////////////////////////////////////////////////////////////
                                ENUMS
    //////////////////////////////////////////////////////////////*/

    enum EscrowState {
        AWAITING_PAYMENT,
        FUNDED,
        RELEASED,
        REFUNDED
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    address public immutable payer;
    address public immutable payee;
    address public immutable arbiter;

    uint256 public immutable releaseTime;
    EscrowState public state;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Funded(address indexed payer, uint256 amount);
    event Released(address indexed payee, uint256 amount);
    event Refunded(address indexed payer, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _payer,
        address _payee,
        address _arbiter,
        uint256 _releaseTime
    ) {
        if (_payer == address(0) || _payee == address(0) || _arbiter == address(0)) {
            revert ZeroAddress();
        }
        require(_releaseTime > block.timestamp, "Release time must be in future");

        payer = _payer;
        payee = _payee;
        arbiter = _arbiter;
        releaseTime = _releaseTime;

        state = EscrowState.AWAITING_PAYMENT;
    }

    /*//////////////////////////////////////////////////////////////
                              ESCROW LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Fund the escrow with ETH (payer only)
    function fund() external payable {
        if (msg.sender != payer) revert NotAuthorized();
        if (state != EscrowState.AWAITING_PAYMENT) revert InvalidState();
        if (msg.value == 0) revert NoFunds();

        state = EscrowState.FUNDED;
        emit Funded(msg.sender, msg.value);
    }

    /// @notice Release funds to the payee after the timelock
    function rel

