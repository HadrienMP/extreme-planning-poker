import express, {Request, Response} from "express";
import {Citizen, enlist, Guest, isCitizen, Nation} from "./domain/nation";
import {Map} from "immutable";
import * as bus from "./infrastructure/bus";
import * as nationStore from "./nationStore";


export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    enlist(parsePerson(req.body), nationStore.get())
        .onSuccess(nationStore.add)
        .onSuccess(citizen => bus.publishFront("enlisted", citizen))
        .onSuccess(_ => res.json(state()))
        .mapError((error): JsonError => ({status: 400, reason: error}))
        .onError((error: JsonError) => res.status(error.status).json(error).end());
});

type JsonError = { status: number, reason: string }

router.post('/alive', (req: Request, res: Response) => {
    let citizen = parsePerson(req.body);
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
    let citizen = parsePerson(req.body);
    nation.leave(citizen)
    ballots.cancel(citizen)
    bus.publishFront("citizenLeft", citizen)
});

const state = () => ({
    nation: nation.all(),
    ballots: ballots.all()
});

const footprint = () => hash.Md5.(nation.footprint() + ballots.footprint());

const parsePerson = (probablyPerson: any): Guest => new Guest(probablyPerson.id, probablyPerson.name);

module.exports = router;
