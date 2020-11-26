import {List, Map} from "immutable";
import {Md5} from "ts-md5";
import {fail, Result, success} from "../lib/Result";

export type GuestId = string;

export class Guest {
    readonly id: GuestId
    readonly name: string

    constructor(id: GuestId, name: string) {
        this.id = id;
        this.name = name;
    }
}

export type CitizenId = string;

export class Citizen {
    readonly id: CitizenId;
    readonly name: string;
    readonly lastSeen: Date;

    constructor(id: GuestId, name: string, lastSeen: Date) {
        this.id = id;
        this.name = name;
        this.lastSeen = lastSeen;
    }

    alive = (): Citizen => new Citizen(this.id, this.name, new Date());
    isAlive = (): boolean => (new Date().getTime() - this.lastSeen.getTime()) < 2000;
}

export type Vote = { citizen: Citizen, ballot: Ballot }
export type Ballot = string
export type Voters = Map<CitizenId, Citizen>
export type Votes = Map<CitizenId, Ballot>
export type Nation = { readonly voters: Voters, readonly votes: Votes }
export type Error = string

export const emptyNation: Nation = {voters: Map({}), votes: Map({})};
export const emptyVotes: Votes = Map({});
export const nationFootprint = (nation: Nation) =>
    Md5.hashStr(votersFootprint(nation.voters) + votesFootprint(nation.votes));
export const votersFootprint = (voters: Voters): string =>
    Md5.hashStr(voters.valueSeq().map(citizen => citizen.id + citizen.name).join()).toString();
export const votesFootprint = (votes: Votes): string =>
    Md5.hashStr(
        votes.reduce((reduction: string, value: Ballot, key: CitizenId) => reduction + key + value)
    ).toString();

export const enlist = (guest: Guest, voters: Voters): Result<[Citizen, Voters], Error> => {
    if (guest.id in voters) return fail("Already enlisted");
    if (guest.name in voters.values()) return fail("Name is already taken");
    let citizen = new Citizen(guest.id, guest.name, new Date());
    return success([citizen, voters.set(citizen.id, citizen)]);
};

export function findCitizenById(id: CitizenId, voters: Map<CitizenId, Citizen>): Result<Citizen, Error> {
    const citizen = voters.get(id)
    return citizen === undefined
        ? fail("Not a citizen")
        : success(citizen);
}

export function cancelVote(id: string, nation: Nation) {
    return findCitizenById(id, nation.voters).map(citizen => nation.votes.remove(citizen.id));
}

export function radiateInactive(voters: Voters): {radiated: List<Citizen>, updated: Voters} {
    let radiated = voters.filterNot((citizen: Citizen) => citizen.isAlive()).toList();
    let updated = voters.removeAll(radiated.map(citizen => citizen.id));
    return {radiated, updated};
}

export function markAlive(id: string, voters: Map<CitizenId, Citizen>) {
    return findCitizenById(id, voters).map(citizen => voters.set(citizen.id, citizen.alive()));
}

export const radiate = (id: string, voters: Voters) =>
    findCitizenById(id, voters).map(citizen => voters.remove(citizen.id));

export function vote(vote: Vote, nation: Nation) {
    return findCitizenById(vote.citizen.id, nation.voters).map(citizen => nation.votes.set(citizen.id, vote.ballot));
}