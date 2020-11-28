import {Request, Response} from "express";
import * as bus from "./bus";

let clients: Client[] = [];

class Client {
    id: string;
    response: Response
    constructor(id: string, response: Response) {
        this.id = id;
        this.response = response;
    }
}

export function init(req: Request, res: Response) {
    const headers = {
        'Content-Type': 'text/event-stream',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache'
    };
    res.writeHead(200, headers);

    setInterval(() => res.write("event: ping\ndata: stay alive\n\n"), 3000);

    const newClient = new Client(Date.now().toString(), res);
    clients.push(newClient);

    req.on('close', () => {
        console.log(`${newClient.id} Connection closed`);
        clients = clients.filter(c => c.id !== newClient.id);
        bus.publishFront("areYouAlive", {});
        setTimeout(_ => {
            bus.publish("radiate", {});
        }, 1000)
    });
}

export function send(data: any, event: string = "") {
    let eventSse = event ? `event: ${event}\n` : ``;
    clients.forEach(client => client.response.write(`${eventSse}data: ${JSON.stringify(data)}\n\n`));
}