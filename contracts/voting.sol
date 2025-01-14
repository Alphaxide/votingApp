// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
        
    }

    mapping(uint => Candidate) public candidates;

    mapping(address => bool) public voters;
    uint public candidatesCount;

    event Voted(uint candidateId);

    constructor() {
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    function addCandidate( string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);


    }
function vote (uint _candidateId) public {
    require(!voters[msg.sender], " You already voted");
    require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate coount");

    voters[msg.sender] = true;
    candidates[_candidateId].voteCount++;

    emit Voted(_candidateId);

}
}
