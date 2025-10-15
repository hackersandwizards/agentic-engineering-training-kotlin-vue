package de.blume2000.finden.adapter.passive.database.produkte

import de.blume2000.finden.domain.model.produkte.produkt.BeschreibungIstLeerException
import de.blume2000.finden.domain.model.produkte.produkt.BeschreibungIstZuLangException
import de.blume2000.finden.testutils.erstelleMongoProdukt
import de.blume2000.finden.testutils.erstelleProdukt
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import strikt.api.expectThat
import strikt.api.expectThrows
import strikt.assertions.isEqualTo
import strikt.assertions.isNotNull
import strikt.assertions.isNull

@Tag("unit")
internal class MongoProduktMappingTest {

  @Test
  internal fun `MongoProdukt nachProdukt() konvertiert String zu Beschreibung`() {
    // Given
    val beschreibungValue = "Test Beschreibung für Produkt"
    val mongoProdukt = erstelleMongoProdukt(beschreibung = beschreibungValue)

    // When
    val produkt = mongoProdukt.nachProdukt()

    // Then
    expectThat(produkt.beschreibung).isNotNull()
    expectThat(produkt.beschreibung?.asString()).isEqualTo(beschreibungValue)
  }

  @Test
  internal fun `MongoProdukt nachProdukt() behandelt null beschreibung korrekt`() {
    // Given
    val mongoProdukt = erstelleMongoProdukt(beschreibung = null)

    // When
    val produkt = mongoProdukt.nachProdukt()

    // Then
    expectThat(produkt.beschreibung).isNull()
  }

  @Test
  internal fun `MongoProdukt vonProdukt() konvertiert Beschreibung zu String`() {
    // Given
    val beschreibungValue = "Test Beschreibung für Produkt"
    val produkt = erstelleProdukt(beschreibung = beschreibungValue)

    // When
    val mongoProdukt = MongoProdukt.vonProdukt(produkt)

    // Then
    expectThat(mongoProdukt.beschreibung).isEqualTo(beschreibungValue)
  }

  @Test
  internal fun `MongoProdukt vonProdukt() behandelt null Beschreibung korrekt`() {
    // Given
    val produkt = erstelleProdukt(beschreibung = null)

    // When
    val mongoProdukt = MongoProdukt.vonProdukt(produkt)

    // Then
    expectThat(mongoProdukt.beschreibung).isNull()
  }

  @Test
  internal fun `MongoProdukt nachProdukt() wirft Exception bei leerem beschreibung String`() {
    // Given
    val mongoProdukt = erstelleMongoProdukt(beschreibung = "")

    // Then
    expectThrows<BeschreibungIstLeerException> {
      mongoProdukt.nachProdukt()
    }
  }

  @Test
  internal fun `MongoProdukt nachProdukt() wirft Exception bei zu langer beschreibung`() {
    // Given
    val tooLongBeschreibung = "a".repeat(501)
    val mongoProdukt = erstelleMongoProdukt(beschreibung = tooLongBeschreibung)

    // Then
    expectThrows<BeschreibungIstZuLangException> {
      mongoProdukt.nachProdukt()
    }
  }
}
