import {empty, Nation} from "../nation-domain";
import {Voters} from "../voters/domain";
import {Votes} from "../votes/domain";

let nation: Nation = empty;


export const get = () => nation;
export const update = (updated: Nation) => nation = updated;
export const getVoters = (): Voters => nation.voters;
export const updateVoters = (voters: Voters) => nation = {voters, votes: nation.votes};
export const getVotes = (): Votes => nation.votes;
export const updateVotes = (votes: Votes) => nation = {voters: nation.voters, votes};