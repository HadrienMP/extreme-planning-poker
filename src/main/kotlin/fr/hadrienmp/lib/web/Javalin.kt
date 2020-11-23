package fr.hadrienmp.lib.web

import io.javalin.Javalin

fun javalin(args: Array<String>): Javalin {
    return Javalin.create {
        logRequests(it)
        it.addStaticFiles("/public")
    }
        .start(port(arguments(args.toList())))
}