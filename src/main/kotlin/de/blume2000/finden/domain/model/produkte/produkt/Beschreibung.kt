package de.blume2000.finden.domain.model.produkte.produkt

import de.blume2000.util.sanitize
import org.jmolecules.ddd.annotation.ValueObject

@ValueObject
data class Beschreibung private constructor(
  private val value: String
) {
  fun asString(): String = value

  companion object {
    private const val MAX_LENGTH = 500

    fun create(rawValue: String): Beschreibung {
      if (rawValue.isBlank()) {
        throw BeschreibungIstLeerException("Beschreibung darf nicht leer sein")
      }

      val sanitized = rawValue.sanitize()

      if (sanitized.isBlank()) {
        throw BeschreibungIstLeerException("Beschreibung darf nicht leer sein nach Bereinigung")
      }

      if (sanitized.length > MAX_LENGTH) {
        throw BeschreibungIstZuLangException("Beschreibung darf maximal $MAX_LENGTH Zeichen haben: aktuell ${sanitized.length}")
      }

      return Beschreibung(sanitized)
    }
  }
}
