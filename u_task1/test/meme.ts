import hre from "hardhat";
import { describe, it } from "node:test";


describe("Meme", async function () {
    it("show accounts", async function () {
        const connection = await hre.network.connect();
        const [first, second] = await connection.ethers.getSigners();
        console.log("First account:", first.address);
        console.log("Second account:", second.address);
    });
});

