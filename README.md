# tim-26
# CartMap

Multiplatformska aplikacija za poređenje cena proizvoda i planiranje kupovine na osnovu lokacije. Korisnici sastavljaju liste za kupovinu, porede cenu cele korpe u obližnjim supermarketima i na mapi pronalaze prodavnice koje im najviše odgovaraju. Cene i podaci o prodavnicama preuzimaju se iz dostupnih izvora i API-ja, a administratori kroz backoffice prate i uređuju katalog i podatke koji se prikazuju u sistemu.

## Tim

| Ime i prezime | Broj indeksa | GitHub nalog |
| --- | --- | --- |
| Anja Aprcović | 70/24 SI | [@github-nalog](https://github.com/anjaaprcovic7024) |
| Luka Stoiljković | 116/24 SI | [@github-nalog](https://github.com/lukastoiljkovic) |

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
| Backoffice | administratori | Flutter | Windows, veb |
| Javni veb | svi posetioci | Jaspr | pregledač |
| Server | mobilna aplikacija, backoffice i javni veb | Relic, PostgreSQL | Linux |
| Domenski paket | svi delovi sistema | Dart | sve |

Svi delovi sistema koriste isti domenski paket napisan u Dartu, u kome se nalaze zajednički modeli i domenska pravila. Server čuva podatke, obrađuje izmene, proverava pravila i usklađuje izmene koje dolaze od više korisnika. Podaci o cenama i prodavnicama mogu da se preuzimaju iz dostupnih API-ja; server ih obrađuje i čuva podatke potrebne za poređenje cena i prikaz vremena poslednjeg ažuriranja.

## Osnovni tok korišćenja

1. Korisnik pretražuje proizvode i dodaje ih na listu za kupovinu.
2. Aplikacija poredi cenu proizvoda i ukupnu cenu korpe u prodavnicama u izabranom radijusu od lokacije ili adrese korisnika.
3. Korisnik pregleda prodavnice na mapi i može da uporedi kupovinu cele korpe u jednoj prodavnici sa raspodelom kupovine na više prodavnica.
4. Tokom kupovine označava kupljene proizvode; lista se zatim označava kao završena.
5. Ako nema internet, korisnik može da nastavi rad sa prethodno sačuvanom listom, a izmene se sinhronizuju kada se veza vrati.

## Stanje projekta

Projekat je u fazi definisanja teme. Detaljan opis domena, konkretni izvori podataka i API integracije, implementacija i testovi dodaće se tokom semestra.
