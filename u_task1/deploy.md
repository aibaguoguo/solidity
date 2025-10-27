### hardhat 部署流程
* 初始化环境 npx hardhat --init
* 安装各种依赖 npm install --save-dev hardhat-deploy
npm install --save-dev dotenv
npm install --save-dev @openzeppelin/contracts
npm install @openzeppelin/contracts@4.9.5 hardhat@2.19.0
* 初始化本地账号环境 npx hardhat node
* 运行scripts脚本 npx hardhat run scripts/deploy.ts --network localhost
* 运行test npx hardhat test --network localhost

### 测试报告
* npm install --save-dev solidity-coverage
* 配置config require("solidity-coverage"); // 添加这行
* 执行命令
```node.js
npx hardhat coverage --network hardhat
npx hardhat coverage test/token.test.js
npx hardhat coverage --reporters html lcov text
```
​​% Stmts​：语句覆盖率（执行的代码行百分比）
​​% Branch​：分支覆盖率（if/else 等条件分支覆盖）
​​% Funcs​：函数覆盖率（被调用的函数百分比）
​​% Lines​：行覆盖率（等同于语句覆盖率）
​Uncovered Lines​：未覆盖的代码行号

### gas reporter
* 按照依赖 npm install --save-dev hardhat-gas-reporter
* 配置 hardhat.config.js
```javascript
require("hardhat-gas-reporter");
```
* 运行测试生成报告
```node.js
npx hardhat test --network localhost
```
