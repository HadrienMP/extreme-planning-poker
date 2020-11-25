import express, {Request, Response} from "express";
import {Citizen, enlist, isCitizen, Nation} from "./domain/nation";
import {Map} from "immutable";
import * as bus from "./infrastructure/bus";
import {Md5} from 'ts-md5/dist/md5';


export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    let citizen = parseCitizen(req.body);
    let nation: Nation = Map({});
    enlist(citizen, nation)
        .onSuccess(updated => {
            nation = updated;
            bus.publishFront("enlisted", citizen)
            res.json(state());
        })
        .onError(errorMessage => {
            const error = { "status": 400, "reason": errorMessage };
            res.status(error.status).json(error).end()
        })
});

router.post('/alive', (req: Request, res: Response) => {
    let citizen = parseCitizen(req.body);
    let nation: Nation = Map({});
    if (isCitizen(citizen, nation)) {
        if (req.body.footprint !== footprint()) {
            bus.publishFront("sync", state());
        }
        nation.alive(citizen);
        res.sendStatus(200)
    } else {
        const error = {"status": 400, "reason": "You are not an enlisted citizen"};
        res.status(400).json(error).end()
    }
});

router.post('/leave', req => {
    let citizen = parseCitizen(req.body);
    nation.leave(citizen)
    ballots.cancel(citizen)
    bus.publishFront("citizenLeft", citizen)
});

const state = () => ({
    nation: nation.all(),
    ballots: ballots.all()
});

const footprint = () => hash.Md5.(nation.footprint() + ballots.footprint());

const parseCitizen = (probablyCitizen: any): Citizen =>
    {
        id: probablyCitizen.id,
        name: probablyCitizen.name
        lastSeen: new Date();
    };

module.exports = router;
