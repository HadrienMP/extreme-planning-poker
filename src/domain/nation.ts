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

export const isCitizen = (citizen: Citizen, nation: Nation): boolean => nation.has(citizen.id)

