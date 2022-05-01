// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

interface IKlerosV2 {

    /***********************
          Kleros Core
    ************************/

    /** @dev Sets the caller's stake in a subcourt.
     *  @param _subcourtID The ID of the subcourt.
     *  @param _stake The new stake.
     */
    function setStake(uint96 _subcourtID, uint256 _stake) external;

    /** @dev Gets the cost of arbitration in a specified subcourt.
     *  @param _extraData Additional info about the dispute. We use it to pass the ID of the subcourt to create the dispute in (first 32 bytes)
     *  and the minimum number of jurors required (next 32 bytes).
     *  @return cost The arbitration cost.
     */
    function arbitrationCost(bytes memory _extraData) public view override returns (uint256 cost);

     /** @dev Gets the cost of appealing a specified dispute.
     *  @param _disputeID The ID of the dispute.
     *  @return cost The appeal cost.
     */
    function appealCost(uint256 _disputeID) public view returns (uint256 cost);

    /** @dev Gets the start and the end of a specified dispute's current appeal period.
     *  @param _disputeID The ID of the dispute.
     *  @return start The start of the appeal period.
     *  @return end The end of the appeal period.
     */
    function appealPeriod(uint256 _disputeID) public view returns (uint256 start, uint256 end);

    /***********************
      Dispute Kit Functions
    ************************/

    /** @dev Gets the current ruling of a specified dispute.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @return ruling The current ruling.
     */
    function currentRuling(uint256 _coreDisputeID) external view returns (uint256 ruling);

    /** @dev Returns the voting data from the most relevant round.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @return winningChoiece The winning choice of this round.
     *  @return tied Whether it's a tie or not.
     */
    function getLastRoundResult(uint256 _coreDisputeID) external view returns (uint256 winningChoiece, bool tied);

    /** @dev Gets the degree of coherence of a particular voter. This function is called by Kleros Core in order to determine the amount of the reward.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @param _coreRoundID The ID of the round in Kleros Core, not in the Dispute Kit.
     *  @param _voteID The ID of the vote.
     *  @return The degree of coherence in basis points.
     */
    function getDegreeOfCoherence(
        uint256 _coreDisputeID,
        uint256 _coreRoundID,
        uint256 _voteID
    ) external view returns (uint256);

    /** @dev Gets the number of jurors who are eligible to a reward in this round.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @param _coreRoundID The ID of the round in Kleros Core, not in the Dispute Kit.
     *  @return The number of coherent jurors.
     */
    function getCoherentCount(uint256 _coreDisputeID, uint256 _coreRoundID) external view returns (uint256);

    /** @dev Returns true if all of the jurors have cast their commits for the last round.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @return Whether all of the jurors have cast their commits for the last round.
     */
    function areCommitsAllCast(uint256 _coreDisputeID) external view returns (bool);

    /** @dev Returns true if all of the jurors have cast their votes for the last round.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @return Whether all of the jurors have cast their votes for the last round.
     */
    function areVotesAllCast(uint256 _coreDisputeID) external view returns (bool);

    /** @dev Returns true if the specified voter was active in this round.
     *  @param _coreDisputeID The ID of the dispute in Kleros Core, not in the Dispute Kit.
     *  @param _coreRoundID The ID of the round in Kleros Core, not in the Dispute Kit.
     *  @param _voteID The ID of the voter.
     *  @return Whether the voter was active or not.
     */
    function isVoteActive(
        uint256 _coreDisputeID,
        uint256 _coreRoundID,
        uint256 _voteID
    ) external view returns (bool);

    function getRoundInfo(
        uint256 _coreDisputeID,
        uint256 _coreRoundID,
        uint256 _choice
    )
        external
        view
        returns (
            uint256 winningChoice,
            bool tied,
            uint256 totalVoted,
            uint256 totalCommited,
            uint256 nbVoters,
            uint256 choiceCount
        );

    function getVoteInfo(
        uint256 _coreDisputeID,
        uint256 _coreRoundID,
        uint256 _voteID
    )
        external
        view
        returns (
            address account,
            bytes32 commit,
            uint256 choice,
            bool voted
        );
}