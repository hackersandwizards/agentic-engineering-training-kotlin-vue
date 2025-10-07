package de.blume2000.finden.domain.model.produkte.produkt

import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import strikt.api.expectThat
import strikt.api.expectThrows
import strikt.assertions.isEqualTo
import strikt.assertions.isNotNull
import strikt.assertions.message

@Tag("unit")
internal class BeschreibungTest {

  @Test
  internal fun `Erstelle Beschreibung sofern der Wert valide ist`() {
    // Given
    val value = "Schöne Blumen für jeden Anlass"

    // When
    val beschreibung = Beschreibung.create(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(value)
  }

  @Test
  internal fun `Wenn der Wert leer ist wird keine Beschreibung initialisiert`() {
    // Given
    val emptyValue = ""
    val whitespaceValue = "   "

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung.create(emptyValue)
    }
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung.create(whitespaceValue)
    }
  }

  @Test
  internal fun `Wenn der Wert länger als 500 Zeichen ist wird keine Beschreibung initialisiert`() {
    // Given
    val tooLongValue = "a".repeat(501)

    // Then
    expectThrows<BeschreibungIstZuLangException> {
      Beschreibung.create(tooLongValue)
    }
  }

  @Test
  internal fun `Beschreibung mit exakt 500 Zeichen wird erstellt`() {
    // Given
    val exactly500Chars = "a".repeat(500)

    // When
    val beschreibung = Beschreibung.create(exactly500Chars)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(exactly500Chars)
  }

  @Test
  internal fun `Beschreibung mit einem Zeichen wird erstellt`() {
    // Given
    val singleChar = "A"

    // When
    val beschreibung = Beschreibung.create(singleChar)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(singleChar)
  }

  @Test
  internal fun `HTML Tags werden durch Sanitization entfernt`() {
    // Given
    val htmlValue = "<script>alert('xss')</script>Harmloser Text"

    // When
    val beschreibung = Beschreibung.create(htmlValue)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Harmloser Text")
  }

  @Test
  internal fun `HTML Entities werden korrekt behandelt`() {
    // Given
    val entityValue = "&lt;div&gt;Text&lt;/div&gt;"

    // When
    val beschreibung = Beschreibung.create(entityValue)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("<div>Text</div>")
  }

  @Test
  internal fun `Whitespace wird getrimmt`() {
    // Given
    val valueWithWhitespace = "   Blumen   "

    // When
    val beschreibung = Beschreibung.create(valueWithWhitespace)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Blumen")
  }

  @Test
  internal fun `Deutsche Sonderzeichen bleiben erhalten`() {
    // Given
    val germanText = "Schöne Blüten für süße Grüße"

    // When
    val beschreibung = Beschreibung.create(germanText)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(germanText)
  }

  @Test
  internal fun `Zwei Beschreibungen mit gleichem Wert sind gleich`() {
    // Given
    val value = "Gleicher Text"
    val beschreibung1 = Beschreibung.create(value)
    val beschreibung2 = Beschreibung.create(value)

    // Then
    expectThat(beschreibung1).isEqualTo(beschreibung2)
    expectThat(beschreibung1.asString()).isEqualTo(value)
  }

  @Test
  internal fun `HTML-only Inhalt wird nach Sanitization als leer erkannt`() {
    // Given
    val htmlOnlyValue = "<script>alert('xss')</script>"

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung.create(htmlOnlyValue)
    }
  }


}
