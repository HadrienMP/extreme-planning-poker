const express = require('express');
const router = express.Router();

const nation = require('../nation');
const ballots = require('../ballots');
const bus = require('../eventBus');
const hash = require("sha1")

router.post('/enlist', (req, res) => {
    let citizen = parseCitizen(req.body);
    if (nation.isCitizen(citizen.id) || nation.isNameTaken(citizen)) {
        res.status(400).json({
            "status": 400,
            "reason": "Already enlisted citizen"
        }).end()
    } else {
        nation.enlist(citizen);
        bus.publish("enlisted", citizen)
        res.json(state());
    }
});

router.post('/alive', (req, res) => {
    let citizen = parseCitizen(req.body.citizen);
    if (!nation.isCitizen(citizen.id)) {
        res.status(400).json({
            "status": 400,
            "reason": "You are not an enlisted citizen"
        }).end()
    } else {
        if (req.body.footprint !== footprint()) {
            bus.publish("sync", state());
        }
        nation.alive(citizen);
        res.sendStatus(200)
    }
});

router.post('/leave', (req) => {
    let citizen = parseCitizen(req.body);
    nation.leave(citizen)
    ballots.cancel(citizen)
    bus.publish("citizenLeft", citizen)
});

const state = () => ({
    nation: nation.all(),
    ballots: ballots.all()
});

const footprint = () => hash(nation.footprint() + ballots.footprint());

const parseCitizen = probablyCitizen => ({id: probablyCitizen.id, name: probablyCitizen.name});

module.exports = router;
