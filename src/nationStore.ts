import {Citizen, CitizenId, Error, Guest, Nation} from "./domain/nation";
import {Map} from "immutable";
import {fail, Result, success} from "./lib/Result";

let nation: Nation = Map({});


export const enlist = (guest: Guest): Result<Citizen, Error> => {
    if (guest.id in nation) return fail("Already enlisted")
    if (guest.name in nation.values()) return fail("Name is already taken")
    let citizen = new Citizen(guest.id, guest.name, new Date());
    nation = nation.set(citizen.id, citizen)
    return success(citizen);
};

export const findBy = (id: CitizenId) => {
    const citizen = nation.get(id)
    return citizen === undefined
        ? fail("Not a citizen")
        : success(citizen);
};
