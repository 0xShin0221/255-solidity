// This code has not been professionally audited, therefore I cannot make any promises about
// safety or correctness. Use at own risk.
contract ChecksEffectsInteractions {

    mapping(address => uint) balances;

    function deposit() public payable {
        balances[msg.sender] = msg.value;
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount);

        balances[msg.sender] -= amount;

        msg.sender.transfer(amount);
    }
}

contract Reentrancy {
    // INSECURE
    mapping (address => uint) private userBalances;
    // INSECURE
    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)(""); // At this point, the caller's code is executed, and can call withdrawBalance again
        require(success);
        userBalances[msg.sender] = 0;
    }


    function withdrawBalanceValid() public {
        uint amountToWithdraw = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        (bool success, ) = msg.sender.call.value(amountToWithdraw)(""); // The user's balance is already 0, so future invocations won't withdraw anything
        require(success);
    }
}

contract CrossFunctionReentrancy public{

    // Invalid
    // mapping (address => uint) private userBalances;

    // function transfer(address to, uint amount) {
    //     if (userBalances[msg.sender] >= amount) {
    //     userBalances[to] += amount;
    //     userBalances[msg.sender] -= amount;
    //     }
    // }

    // function withdrawBalance() public {
    //     uint amountToWithdraw = userBalances[msg.sender];
    //     (bool success, ) = msg.sender.call.value(amountToWithdraw)(""); // At this point, the caller's code is executed, and can call transfer()
    //     require(success);
    //     userBalances[msg.sender] = 0;
    // }

    mapping (address => uint) private userBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;

    // Invalid
    // function withdrawReward(address recipient) public {
    //     uint amountToWithdraw = rewardsForA[recipient];
    //     rewardsForA[recipient] = 0;
    //     (bool success, ) = recipient.call.value(amountToWithdraw)("");
    //     require(success);
    // }

    // function getFirstWithdrawalBonus(address recipient) public {
    //     require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

    //     rewardsForA[recipient] += 100;
    //     withdrawReward(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
    //     claimedBonus[recipient] = true;
    // }


    function untrustedWithdrawReward(address recipient) public {
        uint amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToWithdraw)("");
        require(success);
    }

    function untrustedGetFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        claimedBonus[recipient] = true;
        rewardsForA[recipient] += 100;
        untrustedWithdrawReward(recipient); // claimedBonus has been set to true, so reentry is impossible
    }

}

contract ValidMutexReentrancy{

    mapping (address => uint) private balances;
    bool private lockBalances;

    function deposit() payable public returns (bool) {
        require(!lockBalances);
        lockBalances = true;
        balances[msg.sender] += msg.value;
        lockBalances = false;
        return true;
    }

    function withdraw(uint amount) payable public returns (bool) {
        require(!lockBalances && amount > 0 && balances[msg.sender] >= amount);
        lockBalances = true;

        (bool success, ) = msg.sender.call.value(amount)("");

        if (success) { // Normally insecure, but the mutex saves it
            balances[msg.sender] -= amount;
        }

        lockBalances = false;
        return true;
    }
}

// INSECURE - you will need to carefully ensure that there are no ways for a lock to be claimed and never released
contract StateHolder {
    uint private n;
    address private lockHolder;

    function getLock() {
        require(lockHolder == address(0));
        lockHolder = msg.sender;
    }

    function releaseLock() {
        require(msg.sender == lockHolder);
        lockHolder = address(0);
    }

    function set(uint newState) {
        require(msg.sender == lockHolder);
        n = newState;
    }
}