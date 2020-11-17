let clients = [];
exports.init = (req, res) => {
    const headers = {
        'Content-Type': 'text/event-stream',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache'
    };
    res.writeHead(200, headers);
    const clientId = Date.now();
    const newClient = {id: clientId, res};
    clients.push(newClient);
    req.on('close', () => {
        console.log(`${clientId} Connection closed`);
        clients = clients.filter(c => c.id !== clientId);
    });
}


exports.send = (data, event) => {
    let eventSse = ``;
    if (event) {
        eventSse = `event: ${event}\n`;
    }
    clients.forEach(client => client.res.write(`${eventSse}data: ${JSON.stringify(data)}\n\n`));
}