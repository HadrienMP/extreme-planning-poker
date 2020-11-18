const express = require('express');
const router = express.Router();

const nation = require('../nation');
const ballots = require('../ballots');
const bus = require('../eventBus');

router.get('/', (req, res) => {
    res.json(nation.all());
});

router.post('/enlist', (req, res) => {
    let citizen = parseCitizen(req);
    if (nation.isCitizen(citizen.id) || nation.isNameTaken(citizen)) {
        res.status(400).json({
            "status": 400,
            "reason": "Already enlisted citizen"
        }).end()
    } else {
        nation.enlist(citizen);
        bus.publish("enlisted", citizen)
        res.sendStatus(200)
    }
});

router.post('/alive', (req, res) => {
    let citizen = parseCitizen(req);
    if (!nation.isCitizen(citizen.id)) {
        res.status(400).json({
            "status": 400,
            "reason": "You are not an enlisted citizen"
        }).end()
    } else {
        nation.alive(citizen);
        res.sendStatus(200)
    }
});

router.post('/leave', (req) => {
    let citizen = parseCitizen(req);
    nation.leave(citizen)
    ballots.cancel(citizen)
    bus.publish("citizenLeft", citizen)
});

function parseCitizen(req) {
    return {id: req.body.id, name: req.body.name};
}

module.exports = router;
