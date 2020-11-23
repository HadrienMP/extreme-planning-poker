package fr.hadrienmp.lib.web

import arrow.syntax.function.memoize
import de.neuland.pug4j.Pug4J
import de.neuland.pug4j.PugConfiguration
import de.neuland.pug4j.template.ClasspathTemplateLoader
import de.neuland.pug4j.template.PugTemplate


val loader = ClasspathTemplateLoader("views")
val config = PugConfiguration().apply { templateLoader = loader }

fun render(relativePath: String, data: Map<String, Any> = emptyMap()): String =
        Pug4J.render(template(relativePath), data)

val memoize = { it: String -> config.getTemplate(it) }.memoize()

fun template(relativePath: String): PugTemplate {
    return memoize.invoke(relativePath)
}

