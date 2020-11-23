package fr.hadrienmp.epp.domain

import fr.hadrienmp.lib.functional.success
import kotlinx.collections.immutable.PersistentMap
import kotlinx.collections.immutable.persistentMapOf

data class Citizen(val id: String, val name: String)
data class CitizenId(val value: String)
data class Nation(val value: PersistentMap<CitizenId, String> = persistentMapOf())
data class Enlisted(val citizen: Citizen, val nation: Nation)
fun Nation.enlist(citizen: Citizen) =
    Nation(value.put(CitizenId(citizen.id), citizen.name))
        .success<Nation, String>()
        .map { Enlisted(citizen, it) }

