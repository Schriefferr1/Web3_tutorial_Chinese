//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// FundMe
// 1. 让FundMe的参与者，基于 mapping 来领取相应数量的通证
// 2. 让FundMe的参与者，transfer 通证
// 3. 在使用完成以后，需要burn 通证

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20 {
    FundMe fundMe;//fundMe 存的就是一个链上地址（理想情况是 FundMe 合约或其代理的地址），只是带了 FundMe 这个 ABI 类型标签，便于直接调函数。取原始地址用 address(fundMe)
//FundMe类型名随意，链上不看名字，只看地址 + calldata。
//可把 FundMe 换成任何合法标识符（如 IFund）。但源码里必须有对应的类型或接口声明，否则编译不过。

//不能随意改函数名或参数类型。它们决定 4 字节选择器；与目标合约不一致就调用失败。


    constructor(address fundMeAddr) ERC20("FundTokenERC20", "FT") {
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public {
        require(fundMe.fundersToAmount(msg.sender) >= amountToMint, "You cannot mint this many tokens");
        require(fundMe.getFundSuccess(), "The fundme is not completed yet");
        _mint(msg.sender, amountToMint);
        fundMe.setFunderToAmount(msg.sender, fundMe.fundersToAmount(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public {
        // complete cliam
        require(balanceOf(msg.sender) >= amountToClaim, "You dont have enough ERC20 tokens");
        require(fundMe.getFundSuccess(), "The fundme is not completed yet");
        /*to add */
        // burn amountToClaim Tokens       
        _burn(msg.sender, amountToClaim);
    }
}
