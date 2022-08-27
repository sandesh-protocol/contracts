// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Strings {
    function bytes32ToString(bytes memory _bytes32)
        public
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory)
    {
        bytes memory baseBytes = bytes(_base);
        bytes memory valueBytes = bytes(_value);

        string memory tmpValue = new string(
            baseBytes.length + valueBytes.length
        );
        bytes memory newValue = bytes(tmpValue);

        uint256 i;
        uint256 j;

        for (i = 0; i < baseBytes.length; i++) {
            newValue[j++] = baseBytes[i];
        }

        for (i = 0; i < valueBytes.length; i++) {
            newValue[j++] = valueBytes[i];
        }

        return string(newValue);
    }
}

contract Sandesh {
    struct Conversation {
        string id;
        bool isGroup;
        string dappId;
    }

    struct Message {
        address to;
        address from;
        string contentCID;
        uint256 timestamp;
    }

    // Address of contract owner.
    address owner;

    // Mapping of address to conversationIds.
    mapping(address => Conversation[]) addressToConversations;

    // Mapping of conversationId to messages.
    mapping(string => Message[]) conversationIdToMessages;

    // Mapping to register Dapps.
    mapping(string => bool) private dappRegistry;

    constructor() {}

    // Register a new Dapp for the project.
    // Returns true if registered successfully.
    function registerDapp(string calldata _id) public returns (bool) {
        bool isUsed = dappRegistry[_id] != true;
        require(isUsed, "Unable to register dapp, already used id.");
        dappRegistry[_id] = true;
        return true;
    }

    function getConversationId(address sender, address reciever)
        private
        pure
        returns (string[2] memory)
    {
        bytes memory kSenderHash = abi.encodePacked(sender);
        bytes memory kRecieverHash = abi.encodePacked(reciever);
        string memory senderHash = Strings.bytes32ToString(kSenderHash);
        string memory recieverHash = Strings.bytes32ToString(kRecieverHash);

        string memory conversationId1 = Strings.concat(
            senderHash,
            recieverHash
        );
        string memory conversationId2 = Strings.concat(
            recieverHash,
            senderHash
        );
        return [conversationId1, conversationId2];
    }

    function sendPrivateMessage(
        address to,
        string calldata contentCID,
        string calldata dappId
    ) public returns (string memory) {
        require(
            dappRegistry[dappId],
            "Dapp doesn't exists. Please check Dapp id or register it using registerDapp"
        );

        // For Sender.
        string[2] memory conversationIds = getConversationId(msg.sender, to);

        // Check for conversations of sender.
        Conversation[] memory conversations = addressToConversations[
            msg.sender
        ];

        bool conversationExists = false;
        for (uint256 i = 0; i < conversations.length; i++) {
            if (
                conversationIdToMessages[conversationIds[0]].length > 0 ||
                conversationIdToMessages[conversationIds[1]].length > 0
            ) {
                // Conversation already exists.
                // call for already existing flow.
                Message memory message = Message(
                    to,
                    msg.sender, // TODO make sure msg.sender is same as address string
                    contentCID,
                    block.timestamp
                );

                uint8 index;
                if (conversationIdToMessages[conversationIds[0]].length > 0)
                    index = 0;
                else index = 1;

                conversationIdToMessages[conversationIds[index]].push(message);
                conversationExists = true;
            }
        }

        if (conversationExists == false) {
            Conversation memory conversation = Conversation(
                conversationIds[0],
                false,
                dappId
            );
            addressToConversations[msg.sender].push(conversation);
            addressToConversations[to].push(conversation);
            Message memory message = Message(
                to,
                msg.sender, // TODO make sure senderHash is same as address string
                contentCID,
                block.timestamp
            );
            conversationIdToMessages[conversationIds[0]].push(message);
        }
        return conversationIds[0];
    }

    function getConversations() public view returns (Conversation[] memory) {
        return addressToConversations[msg.sender];
    }

    function getMessages(string calldata _conversationId)
        public
        view
        returns (Message[] memory)
    {
        return conversationIdToMessages[_conversationId];
    }
}
