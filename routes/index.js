const express = require('express');
const router = express.Router();
const sse = require('./sse');

const events = require('events');
const eventQueue = new events.EventEmitter();

const nation = {};
let ballots = {}

router.get('/', (req, res) => {
    res.render('index', {"nation": nation});
});
router.get('/test', (req, res) => {
    res.render('test', {"nation": nation});
});

router.post('/enlist', (req, res) => {
    if (nation[req.body.id]) {
        res.json({
            "status": 400,
            "reason": "Already enlisted citizen"
        })
        res.sendStatus(400)
    } else {
        nation[req.body.id] = {id: req.body.id, name: req.body.name}
        eventQueue.emit("send", {name: "enlisted", data: {"id": req.body.id, "name": req.body.name}})
        res.sendStatus(200)
    }
});

router.get('/nation', (req, res) => {
    res.json(nation);
});

router.post('/vote', (req, res) => {
    if (!nation[req.body.citizen]) {
        res.json({
             "status": 400,
             "reason": "Only citizen are allowed to vote, this vote is not from an enlisted citizen"
         })
        res.sendStatus(400)
    } else {
        ballots[req.body.citizen] = req.body.cardCode
        eventQueue.emit("send", {name: "voteAccepted", data: {"citizen": req.body.citizen, "cardCode": req.body.cardCode}})
        res.sendStatus(200)
    }
});

router.post('/vote/cancel', (req, res) => {
    delete ballots[req.body.id]
    eventQueue.emit("send", {name: "voteCancelled", data: {"id": req.body.id, "name": req.body.name}} )
    res.sendStatus(200)
});

router.post('/poll/close', (req, res) => {
    eventQueue.emit("send", {name: "pollClosed", data: {}})
    res.sendStatus(200)
});

router.post('/poll/start', (req, res) => {
    ballots = {}
    eventQueue.emit("send", {name: "pollStarted", data: {}})
    res.sendStatus(200)
});

router.get('/sse', sse.init);
eventQueue.on('send', event => sse.send(event));

module.exports = router;
