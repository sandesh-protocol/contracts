import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Sandesh } from '../typechain-types'
import { Signer } from "ethers";

const DAPP_ID = 'TEST_DAPP_ID';
const MESSAGE_CID = "hi there";

describe("Sandesh contract tests", function () {
  let sandeshk: any
  beforeEach(async () => {
    const Strings = await ethers.getContractFactory("Strings");
    const strings = await Strings.deploy();
    await strings.deployed();
    const Sandesh = await ethers.getContractFactory("Sandesh"
    );
    sandeshk = await Sandesh.deploy();
  });

  describe("Dapp Id", async function () {
    it("Should not create dapps with same id", async function () {
      await sandeshk.registerDapp(DAPP_ID);

      // Registering again with same dapp id.
      const tx = sandeshk.registerDapp(DAPP_ID);
      await expect(tx).to.be.revertedWith('Unable to register dapp, already used id.');
    });
  });

  describe("Messages", async function () {
    it("Send Messages", async function () {
      await sandeshk.registerDapp(DAPP_ID);
      const [owner, other] = await ethers.getSigners();
      const tx = sandeshk.callStatic.sendPrivateMessage(other.address, MESSAGE_CID, DAPP_ID);
      // Sends message successfuly.
      await expect(tx).is.string;
    });

    describe("Chats", async function () {
      let conversationId: string

      this.beforeEach(async () => {
        await sandeshk.registerDapp(DAPP_ID);
        const [owner, other] = await ethers.getSigners();
        await sandeshk.sendPrivateMessage(other.address, MESSAGE_CID, DAPP_ID);
      })
      describe("For Sender", () => {
        it("Read Conversation", async function () {
          // Fetching all conversations.
          const tx = await sandeshk.getConversations();
          expect(tx).to.be.an('array');
          conversationId = tx[0].id
        });

        it("Read Messages", async function () {
          // Fetching all conversations.
          const tx = await sandeshk.getMessages(conversationId);
          expect(tx).to.be.an('array');
        });

      });
      describe("For Reciever", () => {
        it("Read Conversation", async function () {

          const [owner, other] = await ethers.getSigners();
          // Fetching all conversations.
          const tx = await sandeshk.connect(other).getConversations();
          expect(tx).to.be.an('array');
          conversationId = tx[0].id
        });

        it("Read Messages", async function () {

          const [owner, other] = await ethers.getSigners();
          // Fetching all conversations.
          const tx = await sandeshk.connect(other).getMessages(conversationId);
          expect(tx).to.be.an('array');
        });

      });
    });
  });


});
