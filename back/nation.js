let nation = {};
module.exports.enlist = citizen => nation[citizen.id] = citizen;
module.exports.isCitizen = id => nation[id] !== undefined;
module.exports.isNameTaken = citizen => {
    for (let key in nation) {
        if (nation[key].name === citizen.name) {
            return true;
        }
    }
    return false;
}
module.exports.leave = citizen => delete nation[citizen.id];
module.exports.all = _ => nation