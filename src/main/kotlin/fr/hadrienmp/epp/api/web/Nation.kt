package fr.hadrienmp.epp.api.web

import kotlinx.collections.immutable.PersistentMap
import kotlinx.collections.immutable.persistentMapOf

data class Citizen(val id: String, val name: String)
data class CitizenId(val value: String)
data class Nation(val value: PersistentMap<CitizenId, String> = persistentMapOf())
fun enlist(citizen: Citizen, nation: Nation) =
    Nation(nation.value.put(CitizenId(citizen.id), citizen.name))

