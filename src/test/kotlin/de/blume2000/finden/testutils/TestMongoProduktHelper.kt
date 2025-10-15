package de.blume2000.finden.testutils

import de.blume2000.finden.adapter.passive.database.produkte.MongoBlumensorte
import de.blume2000.finden.adapter.passive.database.produkte.MongoKlassifikation
import de.blume2000.finden.adapter.passive.database.produkte.MongoPreis
import de.blume2000.finden.adapter.passive.database.produkte.MongoProdukt
import de.blume2000.finden.adapter.passive.database.produkte.MongoProduktfarbe
import de.blume2000.finden.adapter.passive.database.produkte.MongoVerfügbarkeit
import java.math.BigDecimal

@Suppress("LongParameterList")
fun erstelleMongoProdukt(
  id: String = "ABC123",
  nummer: String = "ABC123",
  name: String = "Test Produkt",
  preis: MongoPreis = MongoPreis(BigDecimal.TEN, "EUR"),
  streichpreis: MongoPreis = MongoPreis(BigDecimal.TEN, "EUR"),
  klassifikation: MongoKlassifikation? = MongoKlassifikation("11", "Strauss"),
  klassifikationId: String = "11",
  bildUrl: String = "https://res.cloudinary.com/blume2000/image/upload/c_fill,f_auto,h_%h%,q_auto,w_%w%",
  pdsUrlSeoName: String = "test-produkt",
  farben: List<MongoProduktfarbe>? = null,
  blumensorten: List<MongoBlumensorte>? = null,
  verfuegbarkeiten: List<MongoVerfügbarkeit>? = null,
  beschreibung: String? = null,
) = MongoProdukt(
  id = id,
  nummer = nummer,
  name = name,
  preis = preis,
  streichpreis = streichpreis,
  klassifikation = klassifikation,
  klassifikationId = klassifikationId,
  bildUrl = bildUrl,
  pdsUrlSeoName = pdsUrlSeoName,
  farben = farben,
  blumensorten = blumensorten,
  verfuegbarkeiten = verfuegbarkeiten,
  beschreibung = beschreibung,
)
