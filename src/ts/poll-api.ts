import express from "express";
import * as bus from "./infra/bus";
import {updateVotes} from "./infra/store";
import {empty} from "./votes/votes-domain";

export const router = express.Router({strict: true});
router.post('/close', (req, res) => {
    bus.publishFront("pollClosed", {})
    res.sendStatus(200)
});

router.post('/start', (req, res) => {
    updateVotes(empty)
    bus.publishFront("pollStarted", {})
    res.sendStatus(200)
});