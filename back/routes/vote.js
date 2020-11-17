const express = require('express');
const nation = require('../nation');
const ballots = require('../ballots');
const router = express.Router();
const bus = require('../eventBus');

router.post('/', (req, res) => {
    let ballot = parseBallot(req);
    if (nation.isCitizen(ballot.citizen)) {
        ballots.add(ballot);
        bus.publish("voteAccepted", ballot)
        res.sendStatus(200)
    } else {
        res.json({
            "status": 400,
            "reason": "Only citizen are allowed to vote, this vote is not from an enlisted citizen"
        })
        res.sendStatus(400)
    }
});

router.post('/cancel', (req, res) => {
    let citizen = parseCitizen(req)
    delete ballots.cancel(citizen.id)
    bus.publish("voteCancelled", citizen)
    res.sendStatus(200)
});

function parseCitizen(req) {
    return {id: req.body.id, name: req.body.name};
}

function parseBallot(req) {
    return {citizen: req.body.citizen, cardCode: req.body.cardCode};
}

module.exports = router;