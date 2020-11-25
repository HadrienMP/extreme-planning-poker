import {Result, success, fail} from "../lib/Result";
import {Map} from "immutable";

export type CitizenId = string;
export type Citizen = { readonly id: CitizenId, readonly name: string, readonly lastSeen: Date}
export type Nation = Map<CitizenId, Citizen>
export type Error = string

export const enlist = (citizen: Citizen, nation: Nation): Result<Nation, Error> => {
    if (citizen.id in nation) return fail("Already enlisted")
    if (citizen.name in nation.values()) return fail("Name is already taken")
    return success(nation.set(citizen.id, citizen));
};

export const isCitizen = (citizen: Citizen, nation: Nation): boolean => nation.has(citizen.id)

