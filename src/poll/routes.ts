import express from "express";
import * as bus from "../infrastructure/bus";
import * as nation from "../nation/store";

export const router = express.Router({strict: true});
router.post('/close', (req, res) => {
    bus.publishFront("pollClosed", {})
    res.sendStatus(200)
});

router.post('/start', (req, res) => {
    nation.resetVotes();
    bus.publishFront("pollStarted", {})
    res.sendStatus(200)
});