package de.blume2000.finden.domain.model.produkte.produkt

import de.blume2000.util.sanitize
import org.jmolecules.ddd.annotation.ValueObject

@ValueObject
data class Beschreibung(
  private var value: String
) {
  init {
    if (value.isBlank()) {
      throw BeschreibungIstLeerException("Beschreibung darf nicht leer sein")
    }
    value = value.sanitize()
    if (value.isBlank()) {
      throw BeschreibungIstLeerException("Beschreibung darf nach Sanitization nicht leer sein")
    }
    if (value.length > 500) {
      throw BeschreibungIstZuLangException("Beschreibung darf maximal 500 Zeichen lang sein, ist aber ${value.length}")
    }
  }

  fun asString(): String = value
}
