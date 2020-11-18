const hash = require("sha1")

let ballots = {};
module.exports.add = ballot => ballots[ballot.citizen] = ballot.cardCode;
module.exports.cancel = citizenId => delete ballots[citizenId];
module.exports.reset = () => ballots = {};
module.exports.footprint = () => {
    let flat = ""
    for (let citizen in ballots) {
        flat += citizen + ballots[citizen];
    }
    return hash(flat);
};
module.exports.all = () => {
    let result = {}
    for (let citizen in ballots) {
        result[citizen] = ballots[citizen];
    }
    return result;
};