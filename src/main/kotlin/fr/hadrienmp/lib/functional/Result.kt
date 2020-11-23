package fr.hadrienmp.lib.functional

fun <S, E> S.success(): Success<S, E> = Success(this)
fun <S, E> E.error(): Error<S, E> = Error(this)

interface Result<S, E> {
    companion object {
        fun <S, E> of(value: S?, error: E): Result<S, E> = value?.let(::Success) ?: Error(error)
    }

    infix fun <S2> map(f: (S) -> S2): Result<S2, E>
    infix fun <S2> flatMap(f: (S) -> Result<S2, E>): Result<S2, E>
    infix fun <E2> mapError(f: (E) -> E2): Result<S, E2>
    fun <T> fold(successF: (S) -> T, errorF: (E) -> T): T
    fun check(error: E, predicate: (S) -> Boolean): Result<S, E>
    fun onSuccess(f: (S) -> Unit): Result<S, E>
    fun onError(f: (E) -> Unit): Result<S, E>
    operator fun <S2> plus(other: Result<S2, E>): Result<Pair<S, S2>, E>
}

class Success<S, E>(private val value: S) : Result<S, E> {
    override fun <S2> map(f: (S) -> S2): Result<S2, E> = Success(f(value))
    override fun <S2> flatMap(f: (S) -> Result<S2, E>): Result<S2, E> = f(value)
    override fun <E2> mapError(f: (E) -> E2): Result<S, E2> = Success(value)
    override fun <T> fold(successF: (S) -> T, errorF: (E) -> T): T = successF(value)
    override fun check(error: E, predicate: (S) -> Boolean): Result<S, E> = when {
        predicate(value) -> this
        else -> Error(error)
    }

    override fun onSuccess(f: (S) -> Unit): Result<S, E> = apply { f(value) }
    override fun onError(f: (E) -> Unit): Result<S, E> = this
    override fun <S2> plus(other: Result<S2, E>): Result<Pair<S, S2>, E> = other.map { Pair(value, it) }
}

class Error<S, E>(private val value: E) : Result<S, E> {
    override fun <S2> map(f: (S) -> S2): Result<S2, E> = Error(value)
    override fun <S2> flatMap(f: (S) -> Result<S2, E>): Result<S2, E> = Error(value)
    override fun <E2> mapError(f: (E) -> E2): Result<S, E2> = Error(f(value))
    override fun <T> fold(successF: (S) -> T, errorF: (E) -> T): T = errorF(value)
    override fun check(error: E, predicate: (S) -> Boolean): Result<S, E> = this
    override fun onSuccess(f: (S) -> Unit): Result<S, E> = this
    override fun onError(f: (E) -> Unit): Result<S, E> = apply { f(value) }
    override fun <S2> plus(other: Result<S2, E>): Result<Pair<S, S2>, E> = Error(value)
}