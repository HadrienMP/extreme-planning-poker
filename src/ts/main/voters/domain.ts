import {Map, Seq} from "immutable";
import {fail, Result, success} from "../lib/Result";
import {ErrorMsg} from "../lib/error-management";

export type Voters = Map<CitizenId, Citizen>
export type CitizenId = string;
export type GuestId = string;
export class Guest {
    readonly id: GuestId
    readonly name: string

    constructor(id: GuestId, name: string) {
        this.id = id;
        this.name = name;
    }
}
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

export const empty: Voters = Map({});

export const enlist = (guest: Guest, voters: Voters, now: Date = new Date())
    : Result<[Citizen, Voters], ErrorMsg> => {

    if (guest.id in voters)
        return fail("Already enlisted");

    if (voters.find(value => value.name === guest.name))
        return fail("Name is already taken");

    let citizen = new Citizen(guest.id, guest.name, now);
    return success([citizen, voters.set(citizen.id, citizen)]);
};

export function markAlive(id: string, voters: Map<CitizenId, Citizen>) {
    return findCitizenById(id, voters).map(citizen => voters.set(citizen.id, citizen.alive()));
}

function jojo(id: CitizenId, voters: Map<CitizenId, Citizen>): Result<Citizen, ErrorMsg> {
    console.log(id, JSON.stringify(voters));
    return fail("Not a citizen");
}

export function findCitizenById(id: CitizenId, voters: Map<CitizenId, Citizen>): Result<Citizen, ErrorMsg> {
    const citizen = voters.get(id)
    return citizen === undefined
        ? jojo(id, voters)
        : success(citizen);
}
export const footprint = (voters: Voters): string =>
    voters.valueSeq()
        .sortBy(value => value.id)
        .map(citizen => citizen.id + citizen.name)
        .join("");
