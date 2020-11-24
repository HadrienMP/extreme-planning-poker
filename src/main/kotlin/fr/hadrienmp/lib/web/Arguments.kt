package fr.hadrienmp.lib.web

import arrow.core.*
import java.lang.NumberFormatException

fun arguments(arguments: List<String>) =
    Arguments(arguments.filterNot { it.isBlank() }.map { argument(it) }.toMap())

private fun argument(argument: String): Pair<String, String> {
    val split = argument.split(Regex("="), 2)
    return Pair(split[0], split.getOrNull(1) ?: "")
}

data class Arguments(val value: Map<String, String> = emptyMap()) {
    fun get(key: String) = Either.fromNullable(value[key])
}

fun port(arguments: Arguments): Int = arguments.get("port").flatMap(String::parseInt).getOrElse { 3000 }

private fun String.parseInt(): Either<NumberFormatException, Int> = try {
    toInt().right()
} catch (e: NumberFormatException) {
    e.left()
}