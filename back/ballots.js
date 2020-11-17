let ballots = {};
module.exports.add = ballot => ballots[ballot.citizen] = ballot.cardCode;
module.exports.cancel = citizenId => delete ballots[citizenId];
module.exports.reset = _ => ballots = {};