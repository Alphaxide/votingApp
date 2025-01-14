import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String rpcUrl = "http://127.0.0.1:9545"; // Ganache RPC URL
  final String contractAddress = "0xEd6029A0Efc08c72210274c822fddD72F18B6e6A"; // Contract address
  final String privateKey = "b0d27a89e359809c5db5e6056c8b1494a6c8d28990a94344df59c5e25af957ac"; // Private key

  late Web3Client _client;
  late Credentials _credentials;
  late EthereumAddress _contractAddr;
  late DeployedContract _contract;

  BlockchainService() {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    _contractAddr = EthereumAddress.fromHex(contractAddress);
  }

  Future<void> loadContract() async {
    final abi = '''
    [
      {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "candidateId",
            "type": "uint256"
          }
        ],
        "name": "Voted",
        "type": "event"
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "name": "candidates",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "id",
            "type": "uint256"
          },
          {
            "internalType": "string",
            "name": "name",
            "type": "string"
          },
          {
            "internalType": "uint256",
            "name": "voteCount",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function",
        "constant": true
      },
      {
        "inputs": [],
        "name": "candidatesCount",
        "outputs": [
          {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
          }
        ],
        "stateMutability": "view",
        "type": "function",
        "constant": true
      },
      {
        "inputs": [
          {
            "internalType": "address",
            "name": "",
            "type": "address"
          }
        ],
        "name": "voters",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "view",
        "type": "function",
        "constant": true
      },
      {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "_candidateId",
            "type": "uint256"
          }
        ],
        "name": "vote",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
    '''; // ABI pasted here

    _contract = DeployedContract(
        ContractAbi.fromJson(abi, "Voting"), _contractAddr);
  }

  // Function to get the list of candidates
  Future<List<Map<String, dynamic>>> getCandidates() async {
    final candidatesCountFunction = _contract.function("candidatesCount");
    final candidatesCountResult = await _client.call(
      contract: _contract,
      function: candidatesCountFunction,
      params: [],
    );
    final candidatesCount = candidatesCountResult[0].toInt();

    List<Map<String, dynamic>> candidates = [];
    for (int i = 0; i < candidatesCount; i++) {
      final function = _contract.function("candidates");
      final candidateData = await _client.call(
        contract: _contract,
        function: function,
        params: [BigInt.from(i)],
      );

      candidates.add({
        'id': candidateData[0].toInt(), // Ensure the id is an integer
        'name': candidateData[1],
        'voteCount': candidateData[2].toString(),
      });
    }

    return candidates;
  }

  // Function to vote for a candidate
  Future<void> vote(int candidateId) async {
    final function = _contract.function("vote");
    final transaction = Transaction.callContract(
      contract: _contract,
      function: function,
      parameters: [BigInt.from(candidateId)],
      gasPrice: EtherAmount.inWei(BigInt.from(20000000000)), // Set gas price
      maxGas: 100000, // Set gas limit
    );

    await _client.sendTransaction(
      _credentials,
      transaction,
      chainId: 1337, // Ganache default chain ID
    );
  }
}
