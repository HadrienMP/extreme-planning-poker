import {Map} from "immutable";
import {fail, Result, success} from "../lib/Result";
import {Md5} from "ts-md5";
import {Error} from "../lib/error-management";

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
export const enlist = (guest: Guest, voters: Voters): Result<[Citizen, Voters], Error> => {
    if (guest.id in voters) return fail("Already enlisted");
    if (guest.name in voters.values()) return fail("Name is already taken");
    let citizen = new Citizen(guest.id, guest.name, new Date());
    return success([citizen, voters.set(citizen.id, citizen)]);
};

export function markAlive(id: string, voters: Map<CitizenId, Citizen>) {
    return findCitizenById(id, voters).map(citizen => voters.set(citizen.id, citizen.alive()));
}

function jojo(id: CitizenId, voters: Map<CitizenId, Citizen>): Result<Citizen, Error> {
    console.log(id, JSON.stringify(voters));
    return fail("Not a citizen");
}

export function findCitizenById(id: CitizenId, voters: Map<CitizenId, Citizen>): Result<Citizen, Error> {
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
