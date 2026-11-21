# tim-26
# CartMap

Multiplatformska aplikacija za poređenje cena proizvoda i planiranje kupovine na osnovu lokacije. Korisnici sastavljaju liste za kupovinu, porede cenu cele korpe u obližnjim supermarketima i na mapi pronalaze prodavnice koje im najviše odgovaraju. Cene i podaci o prodavnicama preuzimaju se iz dostupnih izvora i API-ja, a administratori kroz backoffice prate i uređuju katalog i podatke koji se prikazuju u sistemu.

## Tim

| Ime i prezime | Broj indeksa | GitHub nalog |
| --- | --- | --- |
| Anja Aprcović | 70/24 SI | [anjaaprcovic7024](https://github.com/anjaaprcovic7024) |
| Luka Stoiljković | 116/24 SI | [lukastoiljkovic](https://github.com/lukastoiljkovic) |

## Zahtevi za temu

1. **Uloge.** Kupci koriste mobilnu aplikaciju za sastavljanje lista, pregled cena i pronalaženje prodavnica, dok administratori kroz backoffice upravljaju katalogom proizvoda, podacima o prodavnicama i proverom podataka o cenama. Članovi domaćinstva mogu da dele listu za kupovinu i da je zajednički ažuriraju.
2. **Stanja.** Lista za kupovinu prolazi kroz najmanje četiri stanja: u pripremi, spremna za kupovinu, kupovina u toku i završena. Korisnik može da menja stavke i količine dok priprema listu, a zatim da označava proizvode kao kupljene.
3. **Pravila.** Svaka stavka liste ima količinu i konkretno pakovanje proizvoda, a ukupna cena korpe računa se prema cenama u izabranim prodavnicama. Više članova domaćinstva može istovremeno da menja istu deljenu listu. Server proverava da li je korisnik član liste i da li stavka već postoji. Dozvoljava dodavanje i izmenu stavki samo članovima liste. Ako dva člana istovremeno dodaju isti proizvod u istom pakovanju, server objedinjuje njihove izmene sabiranjem količina, umesto da kreira duplikat. Odbija izmene korisnika koji nisu članovi liste, kao i izmene liste koja je već završena. Server takođe proverava ispravnost i ažurnost podataka o cenama pre nego što ih prikaže korisnicima.
4. **Rad bez mreže.** Korisnik može da otvori prethodno sačuvanu listu i bez internet veze da označava proizvode kao kupljene, menja količine i dodaje nove stavke. Sve izmene se lokalno čuvaju na uređaju, a kada se internet veza ponovo uspostavi, aplikacija ih šalje serveru na proveru i sinhronizaciju. Ako neka izmena nije dozvoljena prema pravilima deljene liste, server je odbija i aplikacija obaveštava korisnika.
5. **Posao za osoblje.** Administratori kroz backoffice na većem ekranu pregledaju i uređuju katalog proizvoda, prodavnice, cenovnike i status osvežavanja podataka iz povezanih izvora. To podrazumeva rad sa većim brojem zapisa i pregledima koji nisu pogodni za mali ekran telefona.
6. **Javni sadržaj.** Javni veb bez prijave prikazuje proizvode, njihove uporedive cene, prodavnice i dostupne ponude. Ovaj sadržaj je koristan i korisnicima koji još nemaju nalog, a može da se indeksira u pretraživačima.

## Delovi sistema

| Deo | Korisnici | Tehnologija | Platforme |
| --- | --- | --- | --- |
| Mobilna aplikacija | kupci | Flutter | Android |
| Backoffice | administratori | Flutter | Windows, veb (Chrome) |
| Javni veb | svi posetioci | Jaspr | pregledač |
| Server | mobilna aplikacija, backoffice i javni veb | Relic 1.2.0, PostgreSQL | Linux (Docker) |
| Domenski paket | svi delovi sistema | Dart | sve |

Svi delovi sistema koriste isti domenski paket napisan u Dartu, u kome se nalaze zajednički modeli i domenska pravila. Server čuva podatke, obrađuje izmene, proverava pravila i usklađuje izmene koje dolaze od više korisnika. Podaci o cenama i prodavnicama mogu da se preuzimaju iz dostupnih API-ja; server ih obrađuje i čuva podatke potrebne za poređenje cena i prikaz vremena poslednjeg ažuriranja.

## Osnovni tok korišćenja

1. Korisnik pretražuje proizvode i dodaje ih na listu za kupovinu.
2. Aplikacija poredi cenu proizvoda i ukupnu cenu korpe u prodavnicama u izabranom radijusu od lokacije ili adrese korisnika.
3. Korisnik pregleda prodavnice na mapi i može da uporedi kupovinu cele korpe u jednoj prodavnici sa raspodelom kupovine na više prodavnica.
4. Tokom kupovine označava kupljene proizvode; lista se zatim označava kao završena.
5. Ako nema internet, korisnik može da nastavi rad sa prethodno sačuvanom listom, a izmene se sinhronizuju kada se veza vrati.

## Struktura repozitorijuma

| Folder | Šta je |
| --- | --- |
| `apps/mobile` | Flutter aplikacija za kupce (Android) |
| `apps/backoffice` | Flutter aplikacija za administratore (Windows i veb) |
| `apps/server` | server u Dartu na Relic-u, migracije baze i početni podaci |
| `packages/domain` | čist Dart paket: model, stanja, pravila, prava (`AccessPolicy`), izračunavanja |
| `packages/use_cases` | portovi (repozitorijumi) koje implementiraju lažni podaci i HTTP klijent |
| `packages/blocs` | Bloc-ovi za mobilnu aplikaciju i backoffice, uključujući prijavu |
| `packages/api_contract` | ugovor klijent-server: putanje, kodovi grešaka, JSON oblici; ne uvozi domen, Flutter ni `dart:io` |
| `packages/api_mapping` | prevod domen ↔ ugovor u oba smera, i za greške; koriste ga klijenti i server |
| `packages/api_client` | HTTP repozitorijumi, isti kod za oba klijenta, na VM-u i u pregledaču |

Projekat je monorepo sa pub workspace-om (`pubspec.yaml` u korenu).

## Pokretanje

Potrebni su Docker (Docker Desktop na Windows-u i macOS-u) i Flutter.

### Baza i server

Iz korena repozitorijuma, iz čistog klona:

```sh
cp .env.example .env    # Windows: copy .env.example .env
docker compose up -d
```

`compose.yaml` podiže tri servisa:

| Servis | Šta radi | Adresa |
| --- | --- | --- |
| `db` | PostgreSQL 17 | `localhost:5436` |
| `migrate` | dbmate primeni migracije iz `apps/server/migrations`, pa izlazi | nema |
| `server` | server u Dartu na Relic-u, slika iz `apps/server/Dockerfile` | http://localhost:8080 |

Kada je baza prazna, server upisuje početne podatke. Lozinka baze, `DEMO_PASSWORD`, `JWT_SECRET`, ključ izvora cena i portovi su u `.env`, koji nije u git-u.

Provera: `docker compose ps -a` (servis `migrate` je `Exited (0)`) i `curl localhost:8080/health` (odgovor `ok`; u PowerShell-u `curl.exe`).

| Komanda | Šta radi |
| --- | --- |
| `docker compose logs server` | ispis servera; `logs migrate` za migracije |
| `docker compose up -d --build server` | nova slika servera posle izmene u `apps/server` ili u paketima |
| `docker compose down` | gasi sistem, podaci ostaju |
| `docker compose down -v` | gasi sistem i briše bazu; sledeći `up -d` kreće od nule |
| `docker compose stop server` | zaustavlja server (provera poruke „Server nije dostupan“) |

Server bez kontejnera, za debugger: `docker compose stop server`, pa u `apps/server` pokrenuti `dart run bin/server.dart`.

Istek prijave: u `.env` postaviti `SESSION_TTL_MINUTES=1`, pa `docker compose up -d server`.

### Aplikacije

Prvo `flutter pub get` u korenu. Svaka aplikacija u svom terminalu:

```sh
cd apps/mobile
flutter run                          # Android emulator nalazi server na 10.0.2.2:8080
```

```sh
cd apps/backoffice
flutter run -d windows               # desktop
flutter run -d chrome --web-port 8081   # pregledač; port mora biti u CORS_ORIGINS
```

Telefon na mreži: `flutter run --dart-define=SERVER_URL=http://<IP računara>:8080`. Bez servera, nad lažnim podacima: `--dart-define=CARTMAP_FAKE=true`.

### Demo nalozi

Lozinka za sve naloge je `DEMO_PASSWORD` iz `.env` (u `.env.example`: `cartmap-demo`).

| Nalog | Uloga | Aplikacija | Napomena |
| --- | --- | --- | --- |
| `kupac1` | kupac | mobilna | član svih lista l1–l10 |
| `kupac2` | kupac | mobilna | član deljenih lista l1, l5, l7, l9 |
| `kupac3` | kupac | mobilna | član samo liste l11; za proveru tuđe liste |
| `admin1` | administrator | backoffice | |

### Pozivi mimo aplikacije

Istovremeno dodavanje istog proizvoda na deljenu listu (prolazi samo jedan poziv):

```sh
cd apps/server
dart run tool/concurrent_add.dart
```

Primeri sa `curl`-om (bash; token iz odgovora na prijavu):

```sh
TOKEN=$(curl -s localhost:8080/api/v1/sessions -H 'Content-Type: application/json' \
  -d '{"username":"kupac1","password":"cartmap-demo"}' | sed 's/.*"token":"\([^"]*\)".*/\1/')

# pravilo iz domena: količina van granica -> 422 quantity-out-of-range, min 1, max 99
curl -s localhost:8080/api/v1/lists/l2/items -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' -d '{"productId":"mleko","quantity":150}'

# akcija backoffice-a od kupca -> 403 not-allowed
curl -s localhost:8080/api/v1/prices/price-0/status -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' -d '{"status":"approved"}'

# tuđa lista (l11 je od kupac3) -> 403 not-a-member
curl -s localhost:8080/api/v1/lists/l11/items -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' -d '{"productId":"hleb","quantity":1}'
```

## Odluke za KT2

**Pravilo koje zavisi od drugih korisnika.** Vrsta: ograničen broj. Kada dva člana deljene liste dodaju isti proizvod u istom pakovanju, količine se sabiraju u jednu stavku, a zbir ne sme da pređe 99 (`ItemTotalTooLarge`). Konačno odlučuje server: izmena liste ide u transakciji koja listu prvo zaključa (`SELECT ... FOR UPDATE`), pa domen proveri pravilo nad svežim podacima. Drugi istovremeni poziv čeka prvi i vidi njegov zbir. Baza ima `PRIMARY KEY (list_id, product_id)` (nema duplikata) i `CHECK (quantity BETWEEN 1 AND 99)` kao poslednju zaštitu. Odbačeno: samo `INSERT ... ON CONFLICT DO UPDATE` sa `CHECK`-om u bazi, jer bi pravilo tada živelo u SQL-u, a ne u domenu, i ne bi pokrilo stanje liste (završena lista).

**Šta vidi onaj ko je zakasnio.** Poruku iz domena („Na listi bi bilo 120 komada, a najviše je 99…“), a aplikacija odmah ponovo učita liste, pa vidi i tuđu izmenu. Isto važi za završenu listu i za cenu koju je drugi administrator već odbio.

**Kupljeno se šalje kao stanje** (`{"bought": true}`), ne kao „prebaci“, pa dva ista istovremena poziva daju isti rezultat. Odbačeno: toggle, gde bi dva klika poništila jedan drugi.

**Šta od zapisa vidi koja uloga.** Kupac vidi samo liste kojima je član i samo potvrđene cene; administrator vidi sve cene, a liste kupaca ne vidi. Sve je u `AccessPolicy` u domenu.

**Novac, vreme i stanja na mreži.** Cena je ceo broj dinara (`priceRsd`), vreme je ISO 8601 u UTC-u, a stanja i uloge su imena iz domena (`preparing`, `approved`, `shopper`…). Odbačeno: decimalni broj za cenu (greške zaokruživanja) i lokalno vreme bez zone.

**Deo velike liste.** Cene se traže sa `offset` i `limit` (najviše 200), a odgovor nosi i `total`; klijent učitava stranice dok ne dobije sve.

**Ko sme šta.** Kupac: svoje liste i prijava cene (čeka potvrdu). Administrator: potvrda i odbijanje cene, unos cene, preuzimanje cena iz izvora. Kada kupac pozove akciju administratora mimo aplikacije, server vraća `403 not-allowed`; tuđa lista daje `403 not-a-member`.

**Prijava.** Server izdaje JWT potpisan tajnom iz `.env` i proverava ga pri svakom pozivu; ko poziva, zna samo iz te prijave. Mobilna i desktop backoffice čuvaju token u bezbednom skladištu platforme (`flutter_secure_storage`), a backoffice u pregledaču dobija HttpOnly kolačić, jer JavaScript tada ne može da ga pročita. Lozinke su u bazi samo kao Argon2id heš.

**Kako klijent saznaje za tuđu promenu.** Osvežavanjem: dugme „Osveži“ u backoffice-u i „Osveži“ u meniju mobilne aplikacije, i automatski posle svakog odbijenog poziva. Odbačeno za KT2: WebSocket ili periodično osvežavanje.

**Spoljni servisi.** Izvor cena i pretragu adrese poziva samo server, iza portova `PriceFeed` i `Geocoder`. Ključ izvora cena je samo u `.env` servera; za KT2 izvor je lažna implementacija (`FakePriceFeed`). Cene iz izvora stižu kao „na čekanju“ i administrator ih potvrđuje.

**Stara verzija aplikacije.** Greška sa kodom koji klijent ne poznaje ne ruši aplikaciju: Bloc prikaže opštu poruku („Server nije dozvolio ovu akciju…“) i ponovo učita podatke.

## Plan po kontrolnim tačkama

### KT1 (4. 11.) — urađeno
Zahtevi: 1, 2, 3 (klijentski deo), 5. Podaci su lažni i čuvaju se u memoriji.

- **Domenski paket**: model liste i stavki, četiri stanja liste i dozvoljeni prelazi, pravila koja vraćaju tip greške, izračunavanja (cena korpe po prodavnicama, prodavnice u radijusu pešačenja).
- **Bloc-ovi**: lista za kupca i obrada cena u backoffice-u; podaci stižu kroz portove.
- **Mobilna aplikacija**: donja traka sa tri taba (Mapa, Moje liste, Moj profil); mapa sa pretragom prodavnica, zumom i radijusom pešačenja koji se uključuje i isključuje; trenutna lokacija ili izabrana adresa, koja se pamti na uređaju; kreiranje i izmena lista, promena stanja, označavanje kupljenog.
- **Backoffice**: tabela cena sa bočnim panelom, potvrda i odbijanje cena, unos nove cene, rad tastaturom, raspored koji prati širinu prozora.

### KT2 (novembar) — urađeno
Zahtevi: 1, 3 (serverski deo).

- Server (Relic 1.2.0) i PostgreSQL u Docker Compose-u, migracije i početni podaci.
- Korisnici i uloge (kupac, administrator), prijava sa JWT-om, bezbedno skladište tokena.
- Deljene liste: server ponovo proverava pravila i sabira količine i kada pozivi stignu istovremeno.
- Provera cena: kupac prijavljuje cenu, administrator je potvrđuje; cene iz spoljnog izvora iza porta.
- Zajednički ugovor, mapiranje i HTTP klijent za oba klijenta; lažni repozitorijumi i dalje rade.

### KT3 (16. 12.) — planirano
Zahtev: 4.

- Rad bez mreže: lokalno čuvanje, sinhronizacija, odbijanje nedozvoljenih izmena.
- Mogućnosti uređaja.

### KT4 (januar) — planirano
Zahtev: 6.

- Javni veb (Jaspr), testiranje i isporuka (Google Play, veb).