import {Ballot, Citizen, CitizenId, Entry, Error, Guest, GuestId, Nation} from "./model";
import {List, Map} from "immutable";
import {fail, Result, success} from "../lib/Result";
import {Md5} from "ts-md5";
import {none, some} from "typescript-monads";


let nation: Nation = Map({});


export const get = () => nation;

export const footprint = () => Md5.hashStr(
    nation.valueSeq().map(entry => entry.citizen.id + entry.citizen.name).join()
);

export const enlist = (guest: Guest): Result<Citizen, Error> => {
    if (guest.id in nation) return fail("Already enlisted")
    if (guest.name in nation.values()) return fail("Name is already taken")
    let citizen = new Citizen(guest.id, guest.name, new Date());
    nation = nation.set(citizen.id, {citizen: citizen, ballot: none()})
    return success(citizen);
};

export const alive = (id: CitizenId): Result<Citizen, Error> =>
    findCitizenBy(id).onSuccess(citizen => nation = update(citizen.alive(), nation));

function update(citizen: Citizen, nation: Nation): Nation {
    return nation.map((entry: Entry, _: CitizenId) => {
            return {citizen: citizen, ballot: entry.ballot}
        }
    );
}

export const radiate = (id: CitizenId) =>
    findCitizenBy(id).onSuccess(citizen => nation = nation.remove(citizen.id));

export const radiateAuto = (): List<Citizen> => {
    const toRadiate = nation.filterNot((entry: Entry, _: CitizenId) => entry.citizen.isAlive());
    nation.removeAll(toRadiate.keys());
    return toRadiate.valueSeq().map(entry => entry.citizen).toList();
};

export const findCitizenBy = (id: CitizenId): Result<Citizen, Error> => {
    const entry = nation.get(id)
    return entry === undefined
        ? fail("Not a citizen")
        : success(entry.citizen);
};

export const resetVotes = () => {
    nation = nation.map((entry: Entry, _: CitizenId) => {
        return {citizen: entry.citizen, ballot: none()}
    });
};

export const vote = (id: GuestId, ballot: Ballot) => {
    return findCitizenBy(id).onSuccess(citizen => nation = nation.set(id, {citizen: citizen, ballot: some(ballot)}));
};

export const cancelVote = (id: GuestId) => {
    return findCitizenBy(id).onSuccess(citizen => nation = nation.set(id, {citizen: citizen, ballot: none()}));
};