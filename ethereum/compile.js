var solc = require('solc');

var input = {
  language: 'Solidity',
  sources: {
    'contracts/Governance.sol': {
      content: 'contract C { function f() public { } }'
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

var output = JSON.parse(solc.compile(JSON.stringify(input)));

// `output` here contains the JSON output as specified in the documentation
// for (var contractName in output.contracts['Governance.sol']) {
//   console.log(
//     contractName +
//       ': ' +
//       output.contracts['Governance.sol'][contractName].evm.bytecode.object
//   );
// }