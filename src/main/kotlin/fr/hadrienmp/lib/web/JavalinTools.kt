package fr.hadrienmp.lib.web

import fr.hadrienmp.epp.api.web.routesLog
import io.javalin.core.JavalinConfig

fun logRequests(it: JavalinConfig) {
    it.requestLogger { ctx, executionTimeMs ->
        routesLog.info("[${ctx.method()}] - ${ctx.path()} - $executionTimeMs ms")
    }
}