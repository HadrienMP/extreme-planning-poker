import express, {Request, Response} from "express";
import {enlist, Guest, markAlive, nationFootprint, radiate, radiateInactive} from "./model";
import * as bus from "../infrastructure/bus";
import * as nation from "./store";
import {getVoters, updateVoters} from "./store";
import {clientError, send} from "../lib/ExpressUtils";

setInterval(() => {
    let {radiated, updated} = radiateInactive(nation.getVoters());
    nation.updateVoters(updated);
    radiated.forEach(citizen => bus.publish("citizenLeft", citizen));
}, 1000);

export const router = express.Router({strict: true});

router.post('/enlist', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    enlist(person, nation.getVoters())
        .onSuccess(ok => nation.updateVoters(ok[1]))
        .onSuccess(ok => bus.publishFront("enlisted", ok[0]))
        .onSuccess(_ => res.json(nation.get()))
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/alive', (req: Request, res: Response) => {
    let person = parsePerson(req.body);
    markAlive(person.id, getVoters())
        .onSuccess(updateVoters)
        .onSuccess(() => syncStates(req))
        .onSuccess(_ => res.status(200))
        .mapError(clientError)
        .onError(error => send(res, error));
});

router.post('/leave', req => {
    let person = parsePerson(req.body);
    radiate(person.id, nation.getVoters())
        .onSuccess(updated => nation.updateVoters(updated))
        // todo rename citizenLeft to radiated ?
        .onSuccess(_ => bus.publishFront("citizenLeft", person));

});

function syncStates(req: Request) {
    if (req.body.footprint !== nationFootprint(nation.get())) {
        bus.publishFront("sync", nation.get());
    }
}

export const parsePerson = (probablyPerson: any): Guest =>
    new Guest(probablyPerson.id, probablyPerson.name);
