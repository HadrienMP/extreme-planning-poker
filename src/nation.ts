import express, {Request, Response} from "express";
import {Error, Guest} from "./domain/nation";
import * as bus from "./infrastructure/bus";
import * as nation from "./nationStore";

setInterval(() => {
    nation.radiateAuto().forEach(citizen => bus.publish("citizenLeft", citizen));
}, 1000)

export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    nation.enlist(person)
        .onSuccess(citizen => bus.publishFront("enlisted", citizen))
        .onSuccess(_ => res.json(nation.get()))
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/alive', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    nation.alive(person.id)
        .onSuccess(() => syncStates(req))
        .onSuccess(_ => res.status(200))
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/leave', req => {
    let person = parsePerson(req.body);
    nation.radiate(person.id);
    // todo rename citizenLeft to radiated ?
    bus.publishFront("citizenLeft", person)
});

function syncStates(req: Request) {
    if (req.body.footprint !== nation.footprint()) {
        bus.publishFront("sync", nation.get());
    }
}

const parsePerson = (probablyPerson: any): Guest => new Guest(probablyPerson.id, probablyPerson.name);
function send(res: Response, error: JsonError) {
    res.status(error.status).json(error).end();
}

class JsonError {
    readonly status: number;
    readonly reason: string;

    constructor(status: number, reason: string) {
        this.status = status;
        this.reason = reason;
    }
}
const clientError = (error: Error) => new JsonError(400, error);


module.exports = router;
