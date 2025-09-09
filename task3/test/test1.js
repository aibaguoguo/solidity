//获取hardhat运行时环境
const hre = require("hardhat");

//执行测试案例前操作
beforeEach(async function () {
    //等待1s后执行
    console.log("wait 1s...");
    await new Promise((resolve) => setTimeout(resolve, 1000));
    console.log("beforeEach run...");
    
})

describe("test1", function () {
    it("test1", async function () {
        console.log("test1 run...");
    });
})

describe("test2", function () {
    it("test2", async function () {
        console.log("test2 run...");
    });
})