import {Result} from "typescript-monads";

type CitizenId = string;
class Citizen {
    id: CitizenId;
    name: string;

    constructor(id: CitizenId, name: string) {
        this.id = id;
        this.name = name;
    }
}
type Nation = Map<CitizenId, Citizen>

export const enlist = (citizen: Citizen, nation: Nation) => {
    if (citizen.id in nation) return Result.fail("Already enlisted")
    if (citizen.name in nation.values()) return Result.fail("Name is already taken")
    nation.values
};