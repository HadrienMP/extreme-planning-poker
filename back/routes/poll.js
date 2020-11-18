const express = require('express');
const ballots = require('../ballots');
const router = express.Router();
const bus = require('../eventBus');

router.post('/close', (req, res) => {
    bus.publishFront("pollClosed", {})
    res.sendStatus(200)
});

router.post('/start', (req, res) => {
    ballots.reset()
    bus.publishFront("pollStarted", {})
    res.sendStatus(200)
});

module.exports = router;
