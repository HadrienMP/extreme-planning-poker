import {Response, Request, Router} from "express";
import * as bus from "../infrastructure/bus";
import * as nation from "../nation/store";
import {parsePerson} from "../nation/routes";
import {Vote} from "../nation/model";
import {clientError, send} from "../lib/ExpressUtils";

export const router = Router({strict: true});

router.post('/', (req:Request, res: Response) => {
    let vote = parseVote(req.body);
    nation.vote(vote.citizen.id, vote.ballot)
        .onSuccess(_ => bus.publishFront("voteAccepted", vote))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

router.post('/cancel', (req, res) => {
    let person = parsePerson(req.body)
    nation.cancelVote(person.id)
        .onSuccess(_ => bus.publishFront("voteCancelled", person))
        .onSuccess(_ => res.sendStatus(200))
        .mapError(clientError)
        .onError(error => send(res, error))
});

function parseVote(probablyVote: any): Vote {
    return {citizen: probablyVote.citizen, ballot: probablyVote.cardCode};
}