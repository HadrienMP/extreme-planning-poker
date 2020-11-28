import * as Voters from "./voters/domain";
import {Citizen} from "./voters/domain";
import * as Votes from "./votes/domain";
import {List} from "immutable";
import {Result} from "./lib/Result";
import {ErrorMsg} from "./lib/error-management"

export type Nation = { readonly voters: Voters.Voters, readonly votes: Votes.Votes }
export const empty: Nation = {voters: Voters.empty, votes: Votes.empty};
export const footprint = (nation: Nation) => Voters.footprint(nation.voters) + Votes.footprint(nation.votes);

export const create = (voters: Voters.Voters, votes: Votes.Votes): Nation => ({voters, votes})
export const radiate = (id: string, nation: Nation): Result<Nation, ErrorMsg> =>
    Voters.findCitizenById(id, nation.voters)
        .map(citizen => create(nation.voters.remove(citizen.id), nation.votes.remove(citizen.id)));

export function radiateInactive(nation: Nation): { radiated: List<Citizen>, updated: Nation } {
    let radiated = nation.voters.filterNot((citizen: Citizen) => citizen.isAlive()).toList();
    let updatedVoters = nation.voters.removeAll(radiated.map(citizen => citizen.id));
    let updatedVotes = nation.votes.removeAll(radiated.map(citizen => citizen.id));
    return {radiated, updated: {voters: updatedVoters, votes: updatedVotes}};
}