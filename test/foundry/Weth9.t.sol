// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import { WETH9 } from "../../contracts/Weth9.sol";

contract Weth9Test is Test {
    WETH9 weth9;
    address user;
    uint256 depositAmount = 1 ether;

    function setUp() public {
        weth9 = new WETH9();
        user = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        vm.startPrank(user);
        vm.deal(user, depositAmount);
    }

    // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function testDepositToken() public {
        weth9.deposit{value: depositAmount}();
        uint256 wethBalance = weth9.balanceOf(user);

        // 驗證 Weth9 內的 user 持有的代幣餘額確實增加
        assertEq(wethBalance, depositAmount, "Deposit did not mint correct amount");
        vm.stopPrank();
    }

    // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function testDepositContractValue() public {
        // 取得合約原始餘額
        uint256 initialBalance = address(weth9).balance;

        weth9.deposit{value: depositAmount}();

        uint256 currentBalance = address(weth9).balance;
        // 驗證合約餘額與原始金額的差額為轉入金額
        assertEq(currentBalance - initialBalance, depositAmount, "Contract balance did not get correct balance");
        vm.stopPrank();
    }

    // 測項 3: deposit 應該要 emit Deposit event
    event Deposit(address indexed dst, uint wad);
    function testDepositEmitEvent() public {
        // 驗證觸發 Deposit event
        vm.expectEmit(true, false, false, true);
        emit Deposit(user, depositAmount);
        weth9.deposit{value: depositAmount}();
        vm.stopPrank();
    }

    // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function testWithdrawBurnToken() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();
        // 取得合約原始餘額
        uint256 initialBalance = weth9.totalSupply();
        weth9.withdraw(depositAmount);
        uint256 currentBalance = weth9.totalSupply();
        // 驗證合約餘額與原始金額的差額為提領金額
        assertEq(initialBalance - currentBalance, depositAmount, "Contract balance did not subtract withdraw amount");
        vm.stopPrank();
    }

    // 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function testWithdrawToUser() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();
        // 取得 user 原始餘額
        uint256 initialBalance = user.balance;
        weth9.withdraw(depositAmount);
        uint256 currentBalance = user.balance;
        // 驗證 user 餘額與原始金額的差額為提領金額
        assertEq(currentBalance - initialBalance, depositAmount, "User did not get correct amount");
        vm.stopPrank();
    }

    // 測項 6: withdraw 應該要 emit Withdraw event
    event Withdrawal(address indexed src, uint wad);
    function testWithdrawEmitEvent() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();
        // 驗證觸發 Withdrawal event
        vm.expectEmit(true, false, false, true);
        emit Withdrawal(user, depositAmount);
        weth9.withdraw(depositAmount);
        vm.stopPrank();
    }

    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function testTransfer() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();

        address receiver = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        weth9.transfer(receiver, depositAmount);

        // 驗證 token 有轉給 receiver
        assertEq(weth9.balanceOf(receiver), depositAmount, "Receiver did not get correct amount");
        vm.stopPrank();
    }

    // 測項 8: approve 應該要給他人 allowance
    function testApprove() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();

        address proxy = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        weth9.approve(proxy, depositAmount);

        // 驗證 approve 後代理人的 allowance 增加
        assertEq(weth9.allowance(user, proxy), depositAmount, "Proxy did not get allowance");
        vm.stopPrank();
    }

    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function testTransferFromGetAllowance() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();

        address proxy = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        weth9.approve(proxy, depositAmount);

        // 切換到 proxy 帳號
        vm.stopPrank();
        vm.startPrank(proxy);

        // proxy 使用 user 的 allowance
        bool result = weth9.transferFrom(user, proxy, depositAmount);

        // 驗證 proxy 可使用 user 的 allowance 減少
        assertEq(result, true, "User allowance did not allowed to use by proxy");
        vm.stopPrank();
    }

    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function testTransferFromDecreaseAllowance() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();

        address proxy = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        weth9.approve(proxy, depositAmount);

        // 切換到 proxy 帳號
        vm.stopPrank();
        vm.startPrank(proxy);

        uint256 initialAllowance = weth9.allowance(user, proxy);
        weth9.transferFrom(user, proxy, depositAmount);

        uint256 currentAllowance = weth9.allowance(user, proxy);
        // 驗證 proxy 可使用 user 的 allowance 減少
        assertEq(initialAllowance - currentAllowance, depositAmount, "Allowance for proxy did not decrease");
        vm.stopPrank();
    }

    // 測試 transferFrom 應該要 emit Transfer
    event Transfer(address indexed src, address indexed dst, uint wad);
    function testTransferFromEmitTransfer() public {
        // 將 amount 存入合約
        weth9.deposit{value: depositAmount}();

        address proxy = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        weth9.approve(proxy, depositAmount);

        // 切換到 proxy 帳號
        vm.stopPrank();
        vm.startPrank(proxy);

        // 驗證觸發 Transfer event
        vm.expectEmit(true, true, false, true);
        emit Transfer(user, proxy, depositAmount);

        // proxy 使用 user 的 allowance
        weth9.transferFrom(user, proxy, depositAmount);

        vm.stopPrank();
    }

    // 測試 transferFrom 的 allowance 不為 0
    function testTransferFromAllowanceNotZero() public {
        address proxy = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

        // 切換到 proxy 帳號
        vm.stopPrank();
        vm.startPrank(proxy);

        // 驗證觸發 Transfer event
        vm.expectRevert();

        // proxy 使用 user 的 allowance
        weth9.transferFrom(user, proxy, depositAmount);

        vm.stopPrank();
    }
}