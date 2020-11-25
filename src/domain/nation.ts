import {Result, success, fail} from "../lib/Result";
import {Map} from "immutable";

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
}

export type Nation = Map<CitizenId, Citizen>
export type Error = string

export const enlist = (guest: Guest, nation: Nation): Result<Citizen, Error> => {
    if (guest.id in nation) return fail("Already enlisted")
    if (guest.name in nation.values()) return fail("Name is already taken")
    return success(new Citizen(guest.id, guest.name, new Date()));
};

export const isCitizen = (citizen: Citizen, nation: Nation): boolean => nation.has(citizen.id)

