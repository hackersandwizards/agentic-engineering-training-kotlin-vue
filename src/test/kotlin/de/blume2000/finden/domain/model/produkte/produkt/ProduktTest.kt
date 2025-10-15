package de.blume2000.finden.domain.model.produkte.produkt

import de.blume2000.finden.domain.model.produkte.produkt.preis.Preis
import de.blume2000.finden.testutils.erstelleProdukt
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import strikt.api.expectThat
import strikt.api.expectThrows
import strikt.assertions.isEqualTo
import strikt.assertions.isNotNull
import strikt.assertions.isNull
import java.math.BigDecimal
import java.util.Currency
import java.util.Locale

@Tag("unit")
internal class ProduktTest {
  @Test
  internal fun `Wirft eine StreichpreisIstNiedrigerAlsPreisException wenn der Streichpreis kleiner ist als der Preis`() {
    // Then
    expectThrows<StreichpreisIstNiedrigerAlsPreisException> {
      erstelleProdukt(
        preis = Preis(BigDecimal.TEN, Currency.getInstance(Locale.GERMANY)),
        streichpreis = Preis(BigDecimal.ONE, Currency.getInstance(Locale.GERMANY))
      )
    }
  }

  @Test
  internal fun `verwende pdsUrl`() {
    val pdsPfad = "20002902-beste-mama"
    // GIVEN
    val produktMitPdsUrl = erstelleProdukt(pdsUrl = ProduktdetailseiteUrlSeoName(pdsPfad))
    // THEN
    expectThat(produktMitPdsUrl.getProduktDetailseiteUrlPfad()).isEqualTo(
      "/p/" +
        pdsPfad
    )
  }

  @Test
  internal fun `Erstelle Produkt mit gültiger Beschreibung`() {
    // Given
    val beschreibungValue = "Wunderschöne Rosen in Rot"

    // When
    val produkt = erstelleProdukt(beschreibung = beschreibungValue)

    // Then
    expectThat(produkt.beschreibung).isNotNull()
    expectThat(produkt.beschreibung?.asString()).isEqualTo(beschreibungValue)
  }

  @Test
  internal fun `Erstelle Produkt mit null Beschreibung für Rückwärtskompatibilität`() {
    // Given / When
    val produkt = erstelleProdukt(beschreibung = null)

    // Then
    expectThat(produkt.beschreibung).isNull()
  }

  @Test
  internal fun `Produkt copy() Funktion aktualisiert Beschreibung korrekt`() {
    // Given
    val originalBeschreibung = "Original Beschreibung"
    val aktualierteBeschreibung = "Aktualisierte Beschreibung"
    val original = erstelleProdukt(beschreibung = originalBeschreibung)

    // When
    val kopiertes = original.copy(beschreibung = Beschreibung.create(aktualierteBeschreibung))

    // Then
    expectThat(kopiertes.beschreibung?.asString()).isEqualTo(aktualierteBeschreibung)
    expectThat(kopiertes.nummer).isEqualTo(original.nummer)
    expectThat(kopiertes.name).isEqualTo(original.name)
  }

  @Test
  internal fun `Produkt copy() von null zu gültiger Beschreibung`() {
    // Given
    val original = erstelleProdukt(beschreibung = null)
    val neueBeschreibung = "Neue Beschreibung"

    // When
    val kopiertes = original.copy(beschreibung = Beschreibung.create(neueBeschreibung))

    // Then
    expectThat(original.beschreibung).isNull()
    expectThat(kopiertes.beschreibung).isNotNull()
    expectThat(kopiertes.beschreibung?.asString()).isEqualTo(neueBeschreibung)
  }

  @Test
  internal fun `Produkt copy() von gültiger Beschreibung zu null`() {
    // Given
    val original = erstelleProdukt(beschreibung = "Ursprüngliche Beschreibung")

    // When
    val kopiertes = original.copy(beschreibung = null)

    // Then
    expectThat(original.beschreibung).isNotNull()
    expectThat(kopiertes.beschreibung).isNull()
  }
}
