pragma solidity ^0.5.8;

/// @title Interface for interacting with the CryptoKitties Core contract created by Dapper Labs Inc.
contract KittyCore {
	function approve(address, uint256) external;
	function ownerOf(uint256 _tokenId) public view returns (address owner);
	function transferFrom(address _from, address _to, uint256 _tokenId) external;
	function transfer(address _to, uint256 _tokenId) external;
	function getKitty(uint256 _id) external view returns (
		bool isGestating,
		bool isReady,
		uint256 cooldownIndex,
		uint256 nextActionAt,
		uint256 siringWithId,
		uint256 birthTime,
		uint256 matronId,
		uint256 sireId,
		uint256 generation,
		uint256 genes
	);
	mapping (uint256 => address) public kittyIndexToApproved;
}