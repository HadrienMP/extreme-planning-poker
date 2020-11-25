import {Citizen, CitizenId, Error, Guest, Nation} from "./domain/nation";
import {List, Map} from "immutable";
import {fail, Result, success} from "./lib/Result";
import {Md5} from "ts-md5";

let nation: Nation = Map({});


export const get = () => nation;

export const footprint = () => Md5.hashStr(
    nation.toList().map(citizen => citizen.id + citizen.name).join()
);

export const enlist = (guest: Guest): Result<Citizen, Error> => {
    if (guest.id in nation) return fail("Already enlisted")
    if (guest.name in nation.values()) return fail("Name is already taken")
    let citizen = new Citizen(guest.id, guest.name, new Date());
    nation = nation.set(citizen.id, citizen)
    return success(citizen);
};

export const alive = (id: CitizenId): Result<Citizen, Error> =>
    findBy(id)
        .map(citizen => citizen.alive())
        .onSuccess(citizen => nation = nation.set(citizen.id, citizen));

export const radiate = (id: CitizenId) =>
    findBy(id).onSuccess(citizen => nation = nation.remove(citizen.id));

export const radiateAuto = (): List<Citizen> => {
    const toRadiate = nation.filterNot((citizen: Citizen, _) => citizen.isAlive());
    nation.removeAll(toRadiate.keys());
    return toRadiate.toList();
};

export const findBy = (id: CitizenId): Result<Citizen, Error> => {
    const citizen = nation.get(id)
    return citizen === undefined
        ? fail("Not a citizen")
        : success(citizen);
};
