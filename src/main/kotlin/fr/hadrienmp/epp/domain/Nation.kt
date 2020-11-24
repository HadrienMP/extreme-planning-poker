package fr.hadrienmp.epp.domain

import fr.hadrienmp.lib.functional.Result
import fr.hadrienmp.lib.functional.success
import kotlinx.collections.immutable.PersistentMap
import kotlinx.collections.immutable.persistentMapOf

data class Citizen(val id: CitizenId, val name: String)
data class CitizenId(val value: String)
data class Nation(val value: PersistentMap<CitizenId, Citizen> = persistentMapOf())

interface NationUpdated { val nation: Nation }
data class Enlisted(val citizen: Citizen, override val nation: Nation): NationUpdated

fun Nation.enlist(citizen: Citizen): Result<Enlisted, String> {
    val updated = Nation(value.put(citizen.id, citizen))
    return Enlisted(citizen, updated).success()
}

