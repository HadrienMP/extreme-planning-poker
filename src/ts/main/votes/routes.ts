import {Request, Response, Router} from "express";
import * as bus from "../infra/bus";
import * as nation from "../infra/store";
import {parsePerson} from "../voters/routes";
import {clientError, send} from "../lib/error-management";
import {cancelVote, vote, Vote} from "./domain";

export const router = Router({strict: true});

router.post('/', (req:Request, res: Response) => {
    let voteVar = parseVote(req.body);
    vote(voteVar, nation.getNation())
        .onSuccess(nation.updateVotes)
        .onSuccess(_ => bus.publishFront("voteAccepted", voteVar))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

router.post('/cancel', (req, res) => {
    let person = parsePerson(req.body)
    cancelVote(person.id, nation.getNation())
        .onSuccess(nation.updateVotes)
        .onSuccess(_ => bus.publishFront("voteCancelled", person))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

function parseVote(probablyVote: any): Vote {
    return {citizen: probablyVote.citizen, ballot: probablyVote.cardCode};
}