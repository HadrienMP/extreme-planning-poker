import {Nation} from "../nation-domain";
import {Map} from "immutable";
import {Md5} from "ts-md5";
import {CitizenId, findCitizenById} from "../voters/domain";
import {fail, Result} from "../lib/Result";
import {Error} from "../lib/error-management";

export type Ballot = string
export type Vote = { citizen: CitizenId, ballot: Ballot }
export enum VotesTypes { Open, Closed}
export type VotesValue = Map<CitizenId, Ballot>;
export class Votes {
    readonly type: VotesTypes;
    readonly value: Map<CitizenId, Ballot>;

    constructor(type: VotesTypes, votes: VotesValue) {
        this.type = type;
        this.value = votes;
    }

    update(f: (value: VotesValue) => VotesValue): Votes {
        return new Votes(this.type, f(this.value));
    }
    open = () => new Votes(VotesTypes.Open, this.value);
    close = () => new Votes(VotesTypes.Closed, this.value);
}
export const empty: Votes = new Votes(VotesTypes.Open, Map({}));
export const footprint = (votes: Votes): string =>
    Md5.hashStr(
        votes.value.reduce((reduction: string, value: Ballot, key: CitizenId) => reduction + key + value, "")
    ).toString();

export function cancelVote(id: string, nation: Nation): Result<Votes, Error> {
    if (nation.votes.type == VotesTypes.Closed) return fail("The poll is closed")
    return findCitizenById(id, nation.voters)
        .map(citizen => nation.votes.update(value => value.remove(citizen.id)));
}

export function vote(vote: Vote, nation: Nation): Result<Votes, Error> {
    if (nation.votes.type == VotesTypes.Closed) return fail("The poll is closed")
    return findCitizenById(vote.citizen, nation.voters)
        .map(citizen => nation.votes.update(value => value.set(citizen.id, vote.ballot)));
}