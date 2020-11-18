const express = require('express');
const router = express.Router();
const sse = require('../sse');
let bus = require("../eventBus");
const nation = require("../nation");
const ballots = require("../ballots");
bus.init()


router.get('/', (req, res) => {
    res.render('index');
});

router.get('/sse', sse.init);

bus.on("citizenLeft", citizen => {
    nation.leave(citizen)
    ballots.cancel(citizen)
    bus.publishFront("citizenLeft", citizen)
});

module.exports = router;
