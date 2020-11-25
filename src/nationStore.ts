import {Citizen, Nation} from "./domain/nation";
import {Map} from "immutable";

let nation: Nation = Map({});

export const get = () => nation;
export const add = (citizen: Citizen) => nation = nation.set(citizen.id, citizen);