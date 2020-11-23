package fr.hadrienmp.lib.web

import io.javalin.http.sse.SseClient
import java.util.concurrent.ConcurrentLinkedQueue

data class SseClients(val clients: ConcurrentLinkedQueue<SseClient> = ConcurrentLinkedQueue<SseClient>()) {
    fun subscribe(client: SseClient) {
        clients.add(client)
        client.onClose { clients.remove(client) }
    }
}
data class SseEvent(val name: String, val data: Any)

infix fun SseEvent.sendTo(clients: SseClients) {
    clients.clients.forEach { client ->
        client.sendEvent(this.toJson())
    }
}
