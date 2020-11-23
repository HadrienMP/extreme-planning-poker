package fr.hadrienmp.lib.web

import arrow.syntax.function.memoize
import com.beust.klaxon.Klaxon
import fr.hadrienmp.lib.functional.Result
import fr.hadrienmp.lib.functional.error
import fr.hadrienmp.lib.functional.success

val serializer: () -> Klaxon = { Klaxon() }.memoize()
fun Any.toJson() = serializer().toJsonString(this)
inline fun <reified T> String.parse(): Result<T, String> =
    serializer().parse<T>(this)
        ?.success()
        ?: "Unable to parse $this".error()