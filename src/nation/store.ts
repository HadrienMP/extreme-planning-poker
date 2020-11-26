import {emptyNation, Nation, Voters, Votes} from "./model";


let nation: Nation = emptyNation;

export const get = () => nation;
export const getVoters = (): Voters => nation.voters;
export const updateVoters = (voters: Voters) => nation = {voters, votes: nation.votes};
export const updateVotes = (votes: Votes) => nation = {voters: nation.voters, votes};