import express, {Request, Response} from "express";
import {footprint, Nation, radiate} from "../nation/domain";
import * as bus from "../infra/bus";
import * as nation from "../infra/store";
import {getVoters, updateVoters} from "../infra/store";
import {clientError, send} from "../lib/error-management";
import {enlist, Guest, markAlive} from "./domain";

export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    enlist(person, nation.getVoters())
        .onSuccess(ok => nation.updateVoters(ok[1]))
        .onSuccess(ok => bus.publishFront("enlisted", ok[0]))
        .onSuccess(_ => res.json(toResponse(nation.getNation())))
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
    radiate(person.id, nation.getNation())
        .onSuccess(updated => nation.update(updated))
        // todo rename citizenLeft to radiated ?
        .onSuccess(_ => bus.publishFront("citizenLeft", person));

});

function syncStates(req: Request) {
    if (req.body.footprint !== footprint(nation.getNation())) {
        console.log(`front ${req.body.footprint}\n back ${footprint(nation.getNation())}`);
        bus.publishFront("sync", toResponse(nation.getNation()));
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
