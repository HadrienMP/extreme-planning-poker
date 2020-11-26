import {Map} from "immutable";
import {Maybe} from "typescript-monads";

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
export type Entry = {citizen: Citizen, ballot: Maybe<Ballot>}
export type Nation = Map<CitizenId, Entry>
export type Error = string
