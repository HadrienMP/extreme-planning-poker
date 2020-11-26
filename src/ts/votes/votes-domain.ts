import {Nation} from "../nation-domain";
import {Map} from "immutable";
import {Md5} from "ts-md5";
import {Citizen, CitizenId, findCitizenById} from "../voters/voters-domain";

export type Ballot = string
export type Vote = { citizen: CitizenId, ballot: Ballot }
export type Votes = Map<CitizenId, Ballot>
export const empty: Votes = Map({});
export const footprint = (votes: Votes): string =>
    Md5.hashStr(
        votes.reduce((reduction: string, value: Ballot, key: CitizenId) => reduction + key + value, "")
    ).toString();

export function cancelVote(id: string, nation: Nation) {
    return findCitizenById(id, nation.voters).map(citizen => nation.votes.remove(citizen.id));
}

export function vote(vote: Vote, nation: Nation) {
    return findCitizenById(vote.citizen, nation.voters).map(citizen => nation.votes.set(citizen.id, vote.ballot));
}