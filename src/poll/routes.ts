import express from "express";
import * as bus from "../infrastructure/bus";
import {updateVotes} from "../nation/store";
import {emptyVotes} from "../nation/model";

export const router = express.Router({strict: true});
router.post('/close', (req, res) => {
    bus.publishFront("pollClosed", {})
    res.sendStatus(200)
});

router.post('/start', (req, res) => {
    updateVotes(emptyVotes)
    bus.publishFront("pollStarted", {})
    res.sendStatus(200)
});