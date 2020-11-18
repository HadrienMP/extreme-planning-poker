const sse = require('./sse');
const events = require('events');
const eventQueue = new events.EventEmitter();

module.exports.init = () => eventQueue.on('send', event => sse.send(event));
module.exports.publishFront = (name, data) => eventQueue.emit("send", {name: name, data: data})
module.exports.publish = (name, data) => eventQueue.emit(name, data)
module.exports.on = (eventName, listener) => eventQueue.on(eventName, listener);