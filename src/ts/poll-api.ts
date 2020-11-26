import express from "express";
import * as bus from "./infra/bus";
import {updateVotes} from "./infra/store";
import {empty} from "./votes/domain";
import * as nation from "./infra/store";

export const router = express.Router({strict: true});
router.post('/close', (req, res) => {
    nation.updateVotes(nation.getVotes())
    bus.publishFront("pollClosed", {})
    res.sendStatus(200)
});

router.post('/start', (req, res) => {
    updateVotes(empty)
    bus.publishFront("pollStarted", {})
    res.sendStatus(200)
});