struct Proposal{
    bytes32 name; 
    uint voteCount; 
}

struct Voter {
    uint weight;
    bool voted;
    address delegate;
    uint vote;
}

contract Ballot{
    address public chairperson;
    mapping(address => Voter) public voters;

    Proposal[] public proposals;
    uint256 public startTime;
    uint256 public endTime;

    uint256 public startSetWeightTime;
    uint256 public endSetWeightTime;

    constructor(bytes32[] memory proposalNames, uint256 voteDuration, uint256 setWeightDuration) {
        chairperson = msg.sender;
        startTime = block.timestamp;
        endTime = block.timestamp + voteDuration;

        startSetWeightTime = block.timestamp;
        endSetWeightTime = block.timestamp + setWeightDuration;

        voters[chairperson].weight = 1;

        for (uint i =0; i< proposalNames.length; i++) {
            proposals.push(
                Proposal({
                    name: proposalNames[i],
                    voteCount: 0
                })
            );
        }
    }

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");

        require(voters[voter].weight == 0, "The voter weight is zero.");
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];

        require(sender.weight != 0, "you have no right to vote");
        require(!sender.voted, "The voter already voted.");
        require(to != msg.sender, "Found loop in delegation.");

        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate ;
            require(to != msg.sender, "Found loop in delegation.");
        }


        Voter storage _delegate = voters[to];
        require(_delegate.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if (_delegate.voted) {
            proposals[_delegate.vote].voteCount += sender.weight;
        } else {
            _delegate.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight !=0, "Has no right to vote");
        require(!sender.voted, "Already voted");

        uint256 timestamp = block.timestamp;
        require(timestamp >= startTime && timestamp <= endTime, "vote must between startTime endTime");

        require(!sender.voted, "Already voted");

        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public  view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p =0; p < proposals.length; p++) 
        {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

    function setVoterWeight(address voter, uint weight) public onlyChairperson {
        uint256 timestamp = block.timestamp;
        require(timestamp >= startSetWeightTime && timestamp <= endSetWeightTime, "setVoterWeight must between startTime endTime");

        voters[voter].weight = weight;
    }

}