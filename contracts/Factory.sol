// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./TestContract.sol";

contract ContractFactory {
    // A mapping to keep track of used salts to prevent reusing them
    mapping(uint => bool) usedSalts;

    /**
     * @notice Create a new instance of TestContract with the given parameters.
     * @dev Deploys a new instance of TestContract using the CREATE2 opcode.
     *      Uses the given owner, wallet name, and salt to precompute the address.
     * @param _owner The address of the owner of the contract.
     * @param _walletName The name of the wallet.
     * @param _salt A unique uint256 used to precompute an address.
     * @param _bytecode The bytecode of the TestContract contract.
     */
    function createTestContract(
        address _owner,
        string memory _walletName,
        uint256 _salt,
        bytes memory _bytecode
    ) external payable returns (address) {
        require(!usedSalts[_salt], "Salt already used.");
        usedSalts[_salt] = true;

        bytes32 salt = bytes32(_salt);
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(_bytecode))
        );
        address contractAddress = address(uint160(uint256(hash)));

        // Deploy the contract using the precomputed address
        TestContract testContract = new TestContract{salt: salt}(_owner, _walletName);
        require(address(testContract) == contractAddress, "Invalid contract address.");

        return address(testContract);
    }
}
