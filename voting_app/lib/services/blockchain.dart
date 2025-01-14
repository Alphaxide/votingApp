import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String rpcUrl = "http://127.0.0.1:7545"; // Ganache RPC
  final String contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";
  final String privateKey = "YOUR_WALLET_PRIVATE_KEY";

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
    final abi = '''[ABI_JSON_HERE]'''; // Copy ABI from Truffle build
    _contract = DeployedContract(
        ContractAbi.fromJson(abi, "Voting"), _contractAddr);
  }

  Future<List<dynamic>> getCandidates() async {
    final function = _contract.function("candidates");
    final candidates = await _client.call(
        contract: _contract, function: function, params: []);
    return candidates;
  }

  Future<void> vote(int candidateId) async {
    final function = _contract.function("vote");
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [BigInt.from(candidateId)]),
    );
  }
}
