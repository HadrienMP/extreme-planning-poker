import express, {Request, Response} from "express";
import {footprint, Nation, radiate, radiateInactive} from "../nation-domain";
import * as bus from "../infra/bus";
import * as nation from "../infra/store";
import {getVoters, updateVoters} from "../infra/store";
import {clientError, send} from "../lib/error-management";
import {enlist, Guest, markAlive} from "./domain";

setInterval(() => {
    let {radiated, updated} = radiateInactive(nation.get());
    nation.update(updated);
    radiated.forEach(citizen => bus.publish("citizenLeft", citizen));
}, 1000);

export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    enlist(person, nation.getVoters())
        .onSuccess(ok => nation.updateVoters(ok[1]))
        .onSuccess(ok => bus.publishFront("enlisted", ok[0]))
        .onSuccess(_ => res.json(toResponse(nation.get())))
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/alive', (req: Request, res: Response) => {
    let person = parsePerson(req.body.citizen);
    markAlive(person.id, getVoters())
        .onSuccess(updateVoters)
        .onSuccess(() => syncStates(req))
        .onSuccess(_ => res.status(200).end())
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/leave', req => {
    let person = parsePerson(req.body);
    radiate(person.id, nation.get())
        .onSuccess(updated => nation.update(updated))
        // todo rename citizenLeft to radiated ?
        .onSuccess(_ => bus.publishFront("citizenLeft", person));

});

function syncStates(req: Request) {
    if (req.body.footprint !== footprint(nation.get())) {
        console.log(`front ${req.body.footprint}\n back ${footprint(nation.get())}`);
        bus.publishFront("sync", toResponse(nation.get()));
    }
}

function toResponse(nation: Nation) {
    return {
        voters: nation.voters,
        votes: nation.votes.value
    }
}

export const parsePerson = (probablyPerson: any): Guest =>
    new Guest(probablyPerson.id, probablyPerson.name);
