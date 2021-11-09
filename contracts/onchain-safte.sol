pragma solidity ^0.8.0;

import './@openzeppelin/contracts/utils/math/SafeMath.sol';
import './@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract onchainSAFTE {
    using SafeMath for uint256;
    struct SAFTE {
        string name;
        string desc;
        address contractInitiator;
        address investor;
        address project;
        IERC20 stablecoin;
        IERC20 projectToken;
        uint256 upfront;
        uint256 investmentAmount;
        uint256 investmentTime;
        uint256[] vestingUnlockCycle;
        uint256[] unlockAmount;
        bool invested;
        bool cancelled;
    }

    SAFTE[] public safte;
    /// @dev added the below parameters seperately as solidity only supports 14 stacks
    mapping (uint256 => bool) unlocked;
    mapping (uint256 => uint256) totalTokens;

    function createSAFTE(string memory _name, string memory _desc, address _investor, address _project, address _stablecoin, IERC20 _projectToken, uint256 _upfront, uint256 _investmentAmount, uint256[] memory _vestingUnlockCycle, uint256[] memory _unlockAmount) external {
        require(_vestingUnlockCycle.length == _unlockAmount.length, "ERR");
        uint256 _totalTokens = _upfront;
        uint256 n;
        while (_vestingUnlockCycle.length > n) {
            _totalTokens = _totalTokens.add(_unlockAmount[n]);
            n++;
        }
        IERC20(_projectToken).transferFrom(msg.sender, address(this), _totalTokens);
        safte.push(SAFTE({name: _name, desc: _desc, investor: _investor, project: _project, stablecoin: IERC20(_stablecoin), projectToken: IERC20(_projectToken), contractInitiator: msg.sender, upfront: _upfront, investmentAmount: _investmentAmount, investmentTime: 0, vestingUnlockCycle: _vestingUnlockCycle, unlockAmount: _unlockAmount, invested: false, cancelled: false}));
    }

    function cancelSAFTE(uint256 _id) external {
        require(msg.sender == safte[_id].contractInitiator || safte[_id].project == msg.sender, "you're not the contract initiator or the project");
        require(safte[_id].cancelled == false && safte[_id].invested == false, "already invested or cancelled");
        IERC20(safte[_id].projectToken).transfer(msg.sender, totalTokens[_id]);
        totalTokens[_id] = 0;
        safte[_id].cancelled = true;
    }

    function transact(uint256 _id) external {
        SAFTE storage _safte = safte[_id];
        require(msg.sender == _safte.investor, "you're not the investor");
        require(_safte.cancelled == false && _safte.invested == false, "already invested or cancelled");
        IERC20(_safte.stablecoin).transferFrom(msg.sender, _safte.project, _safte.investmentAmount);
        IERC20(_safte.projectToken).transfer(_safte.investor, _safte.upfront);
        _safte.investmentTime = block.timestamp;
        _safte.invested = true;
    }

    function claimUnlockedTokens(uint256 _id, uint256 _unlockNumber) external {
        SAFTE storage _safte = safte[_id];
        require(msg.sender == _safte.investor, "you're not the investor");
        require(_safte.cancelled == false && _safte.invested == true, "not invested or cancelled");
        require(block.timestamp >= _safte.investmentTime + _safte.vestingUnlockCycle[_unlockNumber], "not yet unlocked");
        require(unlocked[_unlockNumber] == false, "already claimed");
        IERC20(_safte.projectToken).transfer(_safte.investor, _safte.unlockAmount[_unlockNumber]);
        unlocked[_unlockNumber] = true;
    }
}