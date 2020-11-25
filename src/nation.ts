import express, {Request, Response} from "express";
import {Error, Guest, isCitizen} from "./domain/nation";
import * as bus from "./infrastructure/bus";
import * as nation from "./nationStore";


export const router = express.Router({strict: true});

function send(res: Response, error: JsonError) {
    res.status(error.status).json(error).end();
}

router.post('/enlist', (req: Request, res: Response) => {
    nation.enlist(parsePerson(req.body))
        .onSuccess(citizen => bus.publishFront("enlisted", citizen))
        .onSuccess(_ => res.json(state()))
        .mapError(clientError)
        .onError(error => send(res, error));
});

class JsonError {
    readonly status: number;
    readonly reason: string;

    constructor(status: number, reason: string) {
        this.status = status;
        this.reason = reason;
    }
}
const clientError = (error: Error) => new JsonError(400, error);

router.post('/alive', (req: Request, res: Response) => {
    let citizen = parsePerson(req.body);
    nation.findBy(citizen.id)
        .mapError(error => {
            {status: 400, reason: error}
        })
        .mapError((error): JsonError => ({status: 400, reason: error}))
    if (isCitizen(citizen)) {
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
