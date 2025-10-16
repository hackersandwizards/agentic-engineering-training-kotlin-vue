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
    val value = "Schöne rote Rosen für jeden Anlass"

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(value)
  }

  @Test
  internal fun `Wenn der Wert leer ist wird keine Beschreibung initialisiert`() {
    // Given
    val value = ""
    val value2 = "   "

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung(value)
    }
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung(value2)
    }
  }

  @Test
  internal fun `Beschreibung mit HTML-Content wird sanitiert`() {
    // Given
    val value = "<script>alert('xss')</script>Text"

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Text")
  }

  @Test
  internal fun `Beschreibung wird abgelehnt wenn sie nach Sanitization leer ist`() {
    // Given
    val value = "<script></script><b></b>"

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung(value)
    }
  }

  @Test
  internal fun `Beschreibung mit maximaler Länge wird akzeptiert`() {
    // Given
    val value = "a".repeat(500)

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(value)
  }

  @Test
  internal fun `Beschreibung mit zu großer Länge wird abgelehnt`() {
    // Given
    val value = "a".repeat(501)

    // Then
    expectThrows<BeschreibungIstZuLangException> {
      Beschreibung(value)
    }
  }

  @Test
  internal fun `Beschreibung mit Sonderzeichen wird akzeptiert`() {
    // Given
    val value = "100% natürlich & frisch! Ü Ö Ä ß"

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo(value)
  }

  @Test
  internal fun `Zwei Beschreibungen mit gleichem Wert sind gleich`() {
    // Given
    val value = "Schöne Blumen"
    val beschreibung1 = Beschreibung(value)
    val beschreibung2 = Beschreibung(value)

    // Then
    expectThat(beschreibung1).isEqualTo(beschreibung2)
  }

  @Test
  internal fun `Zwei Beschreibungen mit unterschiedlichen Werten sind nicht gleich`() {
    // Given
    val beschreibung1 = Beschreibung("Beschreibung 1")
    val beschreibung2 = Beschreibung("Beschreibung 2")

    // Then
    expectThat(beschreibung1 != beschreibung2).isEqualTo(true)
  }

  @Test
  internal fun `Beschreibung mit XSS-Attribut wird sanitiert`() {
    // Given
    val value = "<img src=x onerror='alert(1)'>Safe text"

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Safe text")
  }

  @Test
  internal fun `Beschreibung mit HTML-Entities wird dekodiert`() {
    // Given
    val value = "Preis: &euro; 29,99 &amp; kostenlos"

    // When
    val beschreibung = Beschreibung(value)

    // Then
    expectThat(beschreibung.asString()).isEqualTo("Preis: € 29,99 & kostenlos")
  }

  @Test
  internal fun `Beschreibung mit Whitespace wird nicht akzeptiert`() {
    // Given
    val value = "\t\n\r "

    // Then
    expectThrows<BeschreibungIstLeerException> {
      Beschreibung(value)
    }
  }
}
