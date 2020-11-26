import {Request, Response, Router} from "express";
import * as bus from "../infrastructure/bus";
import * as nation from "../nation/store";
import {parsePerson} from "../nation/routes";
import {cancelVote, vote, Vote} from "../nation/model";
import {clientError, send} from "../lib/ExpressUtils";

export const router = Router({strict: true});

router.post('/', (req:Request, res: Response) => {
    let voteVar = parseVote(req.body);
    vote(voteVar, nation.get())
        .onSuccess(nation.updateVotes)
        .onSuccess(_ => bus.publishFront("voteAccepted", voteVar))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

router.post('/cancel', (req, res) => {
    let person = parsePerson(req.body)
    cancelVote(person.id, nation.get())
        .onSuccess(nation.updateVotes)
        .onSuccess(_ => bus.publishFront("voteCancelled", person))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

function parseVote(probablyVote: any): Vote {
    return {citizen: probablyVote.citizen, ballot: probablyVote.cardCode};
}