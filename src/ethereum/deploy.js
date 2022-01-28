import output from "./compile.js";
import HDWalletProvider from "@truffle/hdwallet-provider";
import Web3 from "web3";
import fs from "fs";

const provider = new HDWalletProvider(
  "orchard absorb series asthma hole scatter make flush pass high echo lady",
  "https://rinkeby.infura.io/v3/d2659fd6ed594183a92e29330e7b5f14"
);
const web3 = new Web3(provider);


const contractName = 'Governance'

const abi = output.contracts['Governance.sol'][contractName].abi;
const contractBytecode = output.contracts['Governance.sol'][contractName].evm.bytecode.object

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Attempting to deploy from account", accounts[0]);

  const contract = await new web3.eth.Contract(abi)
  .deploy({ data: contractBytecode })
  .send({ gas: '16000000', from: accounts[0] });

  const contractObject = {};

  contractObject["interface"] = contract.options.jsonInterface;
  contractObject["address"] = contract.options.address;


  fs.writeFile('contractObject.json', JSON.stringify(contractObject), ()=>{});

  console.log("Contract deployed to", contract.options.address);
};


deploy();

