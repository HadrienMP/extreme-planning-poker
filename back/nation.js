const bus = require("./eventBus")
const hash = require("sha1")

let nation = {};

setInterval(() => {
    for (let id in nation) {
        let lastDiff = Date.now() - nation[id].lastSeen
        if (lastDiff > 2000) {
            bus.publish("citizenLeft", nation[id].citizen)
            delete nation[id]
        }
    }
}, 1000)

module.exports.enlist = citizen => nation[citizen.id] = {
    lastSeen: Date.now(),
    citizen
};
module.exports.alive = citizen => {
    if (nation[citizen.id])
        nation[citizen.id].lastSeen = Date.now()
};
module.exports.isCitizen = id => nation[id] !== undefined;
module.exports.isNameTaken = citizen => {
    for (let key in nation) {
        if (nation[key].citizen.name === citizen.name) {
            return true;
        }
    }
    return false;
}
module.exports.leave = citizen => delete nation[citizen.id];
module.exports.all = _ => {
    let result = {}
    for (let key in nation) {
        result[key] = (nation[key].citizen)
    }
    return result;
}
module.exports.footprint = () => {
    let flat = ""
    for (let id in nation) {
        flat += id + nation[id].citizen.name;
    }
    return hash(flat);
};