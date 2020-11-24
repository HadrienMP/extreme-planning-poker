package fr.hadrienmp.lib.web

fun clientError(description: String) = ErrorResponse(400, description)
data class ErrorResponse(val status: Int, val description: String)