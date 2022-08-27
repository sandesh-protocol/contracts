// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct Conversation {
  string id;
  bool isGroup;
  string dappId;
}

struct Message {
  address to;
  address from;
  string contentCID;
  uint timestamp;
}

contract Sandesh {

  // Address of contract owner.
  address owner;

  // Mapping of address to conversationIds.
  mapping(address => Conversation[]) addressToConversationId;

  // Mapping of conversationId to messages.
  mapping(string => Message[]) conversationIdToMessage;

  // Mapping to register Dapps.
  mapping(string => bool) private dappRegistry;

  constructor() {}


  // Register a new Dapp for the project.
  // Returns true if registered successfully. 
  function registerDapp(string calldata _id) public returns(bool){
    bool isUsed = dappRegistry[_id] != true;
    require(isUsed, "Unable to register dapp, already used id.");
    dappRegistry[_id] = true;
    return true;
  }

}