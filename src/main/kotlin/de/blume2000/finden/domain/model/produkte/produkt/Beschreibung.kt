package de.blume2000.finden.domain.model.produkte.produkt

import de.blume2000.util.sanitize
import org.jmolecules.ddd.annotation.ValueObject

@ValueObject
@ConsistentCopyVisibility
data class Beschreibung private constructor(
  private val value: String
) {
  companion object {
    const val MAX_LENGTH = 500

    fun create(rawValue: String): Beschreibung {
      validatePreSanitization(rawValue)
      val sanitizedValue = rawValue.sanitize()
      validatePostSanitization(sanitizedValue)
      return Beschreibung(sanitizedValue)
    }

    private fun validatePreSanitization(value: String) {
      require(value.isNotBlank()) {
        throw BeschreibungIstLeerException("Beschreibung darf nicht leer sein: '$value'")
      }
    }

    private fun validatePostSanitization(value: String) {
      require(value.isNotBlank()) {
        throw BeschreibungIstLeerException("Beschreibung ist nach Sanitization leer")
      }
      require(value.length <= MAX_LENGTH) {
        throw BeschreibungIstZuLangException(
          "Beschreibung überschreitet Maximum von $MAX_LENGTH Zeichen: ${value.length} Zeichen"
        )
      }
    }
  }

  fun asString(): String = value

  val length: Int
    get() = value.length
}
