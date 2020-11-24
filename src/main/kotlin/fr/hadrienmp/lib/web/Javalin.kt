package fr.hadrienmp.lib.web

import io.javalin.Javalin
import io.javalin.core.JavalinConfig
import org.slf4j.Logger
import org.slf4j.LoggerFactory.getLogger

fun javalin(args: Array<String>): Javalin {
    return Javalin.create {
        logRequests(it)
        it.addStaticFiles("/public")
    }.start(port(arguments(args.toList())))
}

val routesLog: Logger = getLogger("Routes")
private fun logRequests(it: JavalinConfig) {
    it.requestLogger { ctx, executionTimeMs ->
        routesLog.info("${ctx.status()} - [${ctx.method()}] ${ctx.path()} - $executionTimeMs ms")
    }
}