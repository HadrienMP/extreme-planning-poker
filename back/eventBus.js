const sse = require('./sse');
const events = require('events');
const eventQueue = new events.EventEmitter();

module.exports.init = () => eventQueue.on('send', event => sse.send(event));

module.exports.publish = (name, data) => eventQueue.emit("send", {name: name, data: data})