import {Response} from "express";
import {Error} from "../nation/model";

export function send(res: Response, error: JsonError) {
    res.status(error.status).json(error).end();
}

export class JsonError {
    readonly status: number;
    readonly reason: string;

    constructor(status: number, reason: string) {
        this.status = status;
        this.reason = reason;
    }
}
export const clientError = (error: Error) => new JsonError(400, error);