package fr.hadrienmp.epp.infra

import fr.hadrienmp.epp.domain.Nation
import fr.hadrienmp.epp.domain.NationUpdated
import fr.hadrienmp.lib.functional.Result
import fr.hadrienmp.lib.functional.error
import fr.hadrienmp.lib.functional.success
import java.util.concurrent.atomic.AtomicReference


private val versionedNation = AtomicReference(VersionedNation())
internal data class VersionedNation(val version: Long = 0, val nation: Nation = Nation())

fun <T : NationUpdated> updateNation(updateFunction: (Nation) -> Result<T, String>): Result<T, String> {
    val current = versionedNation.get()
    return updateFunction(current.nation)
        .flatMap { updated ->
            val candidate = next(current, updated.nation)
            safelyUpdate(candidate)
            when (versionedNation.get()) {
                candidate -> updated.success()
                else -> "Nation version conflict".error()
            }
        }
}

private fun safelyUpdate(candidate: VersionedNation): VersionedNation {
    return versionedNation.getAndUpdate { current ->
        when (candidate.version) {
            current.version + 1 -> candidate
            else -> current
        }
    }
}

private fun next( current: VersionedNation, nation: Nation) =
    VersionedNation(current.version + 1, nation)

