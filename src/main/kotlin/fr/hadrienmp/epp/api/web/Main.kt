package fr.hadrienmp.epp.api.web

import fr.hadrienmp.epp.domain.Citizen
import fr.hadrienmp.epp.domain.Enlisted
import fr.hadrienmp.epp.domain.enlist
import fr.hadrienmp.epp.spi.updateNation
import fr.hadrienmp.lib.web.*
import io.javalin.http.Context
import org.jetbrains.annotations.NotNull
import org.slf4j.Logger
import org.slf4j.LoggerFactory

val routesLog: Logger = LoggerFactory.getLogger("Routes")

fun main(args: Array<String>) {
    val app = javalin(args)
    app.get("/") { ctx -> ctx.html(render("index.pug")) }
    app.sse("/sse", sseClients::subscribe)
    app.post("/nation/enlist", ::enlist)
}

private fun enlist(ctx: Context) {
    parseCitizen(ctx.body())
        .flatMap { citizen -> updateNation { nation -> nation.enlist(citizen) } }
        .onSuccess(::notifyEnlisted)
        .onSuccess { ctx.status(200) }
        .mapError(::clientError)
        .onError { error -> ctx.json(error).status(error.status) }
}

private fun parseCitizen(body: String) = body.parse<Citizen>()

val sseClients = SseClients()
private fun notifyEnlisted(enlisted: Enlisted) {
    SseEvent("enlisted", enlisted.citizen) sendTo sseClients
}

fun clientError(description: String) = ErrorResponse(400, description)
data class ErrorResponse(val status: Int, val description: String)
