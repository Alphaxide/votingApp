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
  List<dynamic> candidates = [];

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

  void _vote(int id) async {
    await _blockchainService.vote(id);
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
                return ListTile(
                  title: Text("Candidate ${index + 1}"),
                  subtitle: Text("Votes: ${candidates[index].voteCount}"),
                  trailing: ElevatedButton(
                    onPressed: () => _vote(index + 1),
                    child: Text("Vote"),
                  ),
                );
              },
            ),
    );
  }
}
