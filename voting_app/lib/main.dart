import 'package:flutter/material.dart';
import 'services/blockchain.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VotingPage(),
    );
  }
}

class VotingPage extends StatefulWidget {
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final BlockchainService _blockchainService = BlockchainService();
  List<Map<String, dynamic>> candidates = [];

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    await _blockchainService.loadContract();
    final results = await _blockchainService.getCandidates();
    setState(() {
      candidates = results;
    });
  }

  void _vote(int candidateId) async {
    await _blockchainService.vote(candidateId);
    // Reload the candidates after voting to update the UI
    _loadCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voting App")),
      body: candidates.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                return ListTile(
                  title: Text(candidate['name']),
                  subtitle: Text("Votes: ${candidate['voteCount']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _vote(candidate['id']),
                    child: Text("Vote"),
                  ),
                );
              },
            ),
    );
  }
}
