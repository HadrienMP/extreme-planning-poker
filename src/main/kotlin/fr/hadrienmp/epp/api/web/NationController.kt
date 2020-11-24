package fr.hadrienmp.epp.api.web

import fr.hadrienmp.epp.domain.*
import fr.hadrienmp.epp.infra.updateNation
import fr.hadrienmp.lib.web.*
import io.javalin.http.Context

fun enlist(ctx: Context) {
    parseCitizen(ctx.body())
        .flatMap { citizen -> updateNation { nation -> nation.enlist(citizen) } }
        .onSuccess(::notifyEnlisted)
        .onSuccess { enlisted -> ctx.status(200).result(enlisted.nation.toFront().toJson()) }
        .mapError(::clientError)
        .onError { error -> ctx.result(error.toJson()).status(error.status) }
}

data class FrontNation(val nation: Map<String, FrontCitizen>, val ballots: Map<String, String> = emptyMap())
private fun Nation.toFront() = FrontNation(this.value.mapKeys { it.key.value }.mapValues { it.value.toFront() })

data class FrontCitizen(val id: String, val name: String) {
    fun toCore() = Citizen(CitizenId(id), name)
}
private fun Citizen.toFront() = FrontCitizen(id.value, name)
private fun parseCitizen(body: String) = body.parse<FrontCitizen>().map { it.toCore() }

private fun notifyEnlisted(enlisted: Enlisted) {
    SseEvent("enlisted", enlisted.citizen.toFront()) sendTo sseClients
}
