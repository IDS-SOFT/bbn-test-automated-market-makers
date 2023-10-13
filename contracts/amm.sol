// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AutomatedMarketMaker {
    address owner;

    IERC20 public tokenA; // Token A in the trading pair
    IERC20 public tokenB; // Token B in the trading pair

    uint256 public reserveA; // Reserve of token A in the AMM
    uint256 public reserveB; // Reserve of token B in the AMM

    event TokensSwapped(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event CheckBalance(string text, uint amount);

    //complete argument details in scripts/deploy.ts to deploy the contract with arguments

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this fucntion");
        _;
    }

    // Add liquidity to the AMM
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer of tokenA failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer of tokenB failed");

        reserveA += amountA;
        reserveB += amountB;
    }

    // Swap tokenA for tokenB or vice versa
    function swapTokens(uint256 amountAIn, uint256 minAmountBOut) external {
        require(amountAIn > 0, "AmountAIn must be greater than zero");

        uint256 amountBOut = (amountAIn * reserveB) / reserveA;

        require(amountBOut >= minAmountBOut, "Slippage too high");

        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Transfer of tokenA failed");
        require(tokenB.transfer(msg.sender, amountBOut), "Transfer of tokenB failed");

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, amountAIn, amountBOut);
    }

    // Function to get the current exchange rate
    function getExchangeRate() external view returns (uint256) {
        return (reserveB * 1e18) / reserveA;
    }

    // Function to retrieve the reserves of both tokens
    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }
    
    function getBalance(address user_account) external returns (uint){
       uint user_bal = user_account.balance;
       emit CheckBalance(user_bal);
       return (user_bal);
    }
}
