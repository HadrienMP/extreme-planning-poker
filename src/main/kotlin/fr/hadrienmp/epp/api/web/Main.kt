package fr.hadrienmp.epp.api.web

import fr.hadrienmp.lib.web.SseClients
import fr.hadrienmp.lib.web.javalin
import fr.hadrienmp.lib.web.render

val sseClients = SseClients()

fun main(args: Array<String>) {
    val app = javalin(args)
    app.get("/") { ctx -> ctx.html(render("index.pug")) }
    app.sse("/sse", sseClients::subscribe)
    app.post("/nation/enlist", ::enlist)
}
