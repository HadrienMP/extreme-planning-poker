let nation = {};
module.exports.enlist = citizen => nation[citizen.id] = citizen;
module.exports.isCitizen = id => nation[id] !== undefined;
module.exports.leave = citizen => delete nation[citizen.id];
module.exports.all = _ => nation