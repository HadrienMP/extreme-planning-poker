import {Response} from "express";

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

export type ErrorMsg = string;

export const clientError = (error: ErrorMsg) => new JsonError(400, error);