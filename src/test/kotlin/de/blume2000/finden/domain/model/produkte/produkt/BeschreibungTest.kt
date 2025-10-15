package de.blume2000.finden.domain.model.produkte.produkt

import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import strikt.api.expectThat
import strikt.api.expectThrows
import strikt.assertions.isEqualTo

@Tag("unit")
internal class BeschreibungTest {

  @Test
  internal fun `Erstelle Beschreibung sofern der Wert valide ist`() {
    // Given
    val value = "Eine wunderbare Blumenbeschreibung mit Details"

    // When
    val beschreibung = Beschreibung.create(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(value)
  }

  @Test
  internal fun `Wenn der Wert leer ist wird BeschreibungIstLeerException geworfen`() {
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
  internal fun `Wenn der Wert zu lang ist wird BeschreibungIstZuLangException geworfen`() {
    // Given
    val tooLongValue = "a".repeat(501)

    // Then
    expectThrows<BeschreibungIstZuLangException> {
      Beschreibung.create(tooLongValue)
    }
  }

  @Test
  internal fun `Erstelle Beschreibung mit exakt 500 Zeichen`() {
    // Given
    val exactlyMaxLength = "a".repeat(500)

    // When
    val beschreibung = Beschreibung.create(exactlyMaxLength)

    // Then
    expectThat(beschreibung.length).isEqualTo(500)
  }

  @Test
  internal fun `HTML-Tags werden bei der Sanitization entfernt`() {
    // Given
    val valueWithHtml = "<b>Schöne Blumen</b>"

    // When
    val beschreibung = Beschreibung.create(valueWithHtml)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Schöne Blumen")
  }

  @Test
  internal fun `XSS-Versuche werden durch Sanitization verhindert`() {
    // Given
    val xssAttempt = "<script>alert('xss')</script>"

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung.create(xssAttempt)
    }
  }

  @Test
  internal fun `Whitespace wird getrimmt aber Text bleibt erhalten`() {
    // Given
    val valueWithWhitespace = "   Blumenbeschreibung mit Inhalt   "

    // When
    val beschreibung = Beschreibung.create(valueWithWhitespace)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Blumenbeschreibung mit Inhalt")
  }

  @Test
  internal fun `Sonderzeichen und Umlaute bleiben erhalten`() {
    // Given
    val valueWithSpecialChars = "Schöne Rosen & Tulpen für 29,99€"

    // When
    val beschreibung = Beschreibung.create(valueWithSpecialChars)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(valueWithSpecialChars)
  }

  @Test
  internal fun `HTML-Entities werden korrekt unescaped`() {
    // Given
    val valueWithEntities = "Rosen &amp; Tulpen"

    // When
    val beschreibung = Beschreibung.create(valueWithEntities)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Rosen & Tulpen")
  }

  @Test
  internal fun `Beschreibung mit 499 Zeichen ist valide`() {
    // Given
    val value = "a".repeat(499)

    // When
    val beschreibung = Beschreibung.create(value)

    // Then
    expectThat(beschreibung.length).isEqualTo(499)
  }
}
