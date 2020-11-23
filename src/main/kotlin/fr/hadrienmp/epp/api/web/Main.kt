package fr.hadrienmp.epp.api.web

import fr.hadrienmp.lib.web.*
import io.javalin.Javalin
import org.slf4j.Logger
import org.slf4j.LoggerFactory

val routesLog: Logger = LoggerFactory.getLogger("Routes")

fun main(args: Array<String>) {
    val app = Javalin
        .create {
            logRequests(it)
            it.addStaticFiles("/public")
        }
        .start(port(arguments(args.toList())))

    app.get("/") { ctx ->
        ctx.html(render("index.pug"))
    }

    app.sse("/sse", sseClients::subscribe)

    app.post("/nation/enlist") { ctx ->
        parseCitizen(ctx.body())
            .flatMap(nation::enlist)
            .onSuccess(::updateNation)
            .onSuccess(::notifyEnlisted)
            .onSuccess { ctx.status(200) }
            .mapError(::clientError)
            .onError { error -> ctx.json(error).status(error.status) }
    }
}

private fun parseCitizen(body: String) = body
    .parse<Citizen>()

val sseClients = SseClients()
var nation = Nation()
fun updateNation(updated: Enlisted) {
    nation = updated.nation
}
private fun notifyEnlisted(enlisted: Enlisted) {
    SseEvent("enlisted", enlisted.citizen) sendTo sseClients
}

fun clientError(description: String) = ErrorResponse(400, description)
data class ErrorResponse(val status: Int, val description: String)
