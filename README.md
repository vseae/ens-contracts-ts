# Harhat Startup

## 初始启动

```shell
git clone git@github.com:7Levy/hardhat-startup.git
npm install
```

## 脚本执行

```shell
yarn n #运行本地hardhat节点
yarn build #删除build目录并重新编译合约代码
yarn build:ts #删除dist并重新编译ts代码
yarn test #在本地节点测试合约
yarn test:trace #在本地节点测试合约(shows logs + calls)
yarn test:fulltrace #在本地测试合约(shows logs + calls + sloads + sstores)
yarn coverage #测试覆盖率
yarn size #合约大小计算
yarn deploy [network-name] #部署合约到指定网络
yarn deploy:verify [network-name] #部署并校验合约到指定网络
yarn lint #代码静态分析(sol和ts)
yarn fmt #格式化代码(sol和ts)
yarn merge #扁平化合约
yarn prepack #npm pack打包前执行
yarn prepare #npm install时执行，安装husky hooks
yarn prepublish #npm install时执行，编译合约和ts代码
```

