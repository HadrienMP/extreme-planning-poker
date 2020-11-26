import {Md5} from "ts-md5";
import * as Voters from "./voters/voters-domain";
import * as Votes from "./votes/votes-domain";

export type Nation = { readonly voters: Voters.Voters, readonly votes: Votes.Votes }

export const empty: Nation = { voters: Voters.empty, votes: Votes.empty };
export const footprint = (nation: Nation) => Md5.hashStr
    (Voters.footprint(nation.voters)
    + Votes.footprint(nation.votes) );

