# Skykeep Calendar — Plasma 6

Widget QML nativo, indipendente dal sorgente di Skykeep. Stile dei widget usage installati e della cheatsheet Linux: pannello scuro traslucido, testo bianco, bordi bianchi sottili, angoli retti e accento KDE di sistema.

Mese navigabile e agenda del giorno selezionato, eventi giornalieri e su più giorni, luogo, calendario e ultima sincronizzazione. Legge gli eventi già espansi/sincronizzati da Skykeep: non espande autonomamente ricorrenze e non scarica altri dati iCloud. Le modifiche effettuate altrove arrivano quando Skykeep le sincronizza. Nessuna scrittura nel database.

Non usa WebEngine, server, account o daemon. Il piccolo lettore Python parte ogni due minuti (o con Aggiorna) e termina; l’interfaccia vive dentro plasmashell. La lettura misurata sul PC impiega circa 0,09 s e 25 MiB di picco transitorio; non è una misura della RAM aggiuntiva del pannello. Il carico persistente va verificato durante l’uso reale.

Installazione: `kpackagetool6 --type Plasma/Applet --install .`
Aggiornamento: `kpackagetool6 --type Plasma/Applet --upgrade .`
Poi aggiungere **Skykeep Calendar** dal catalogo widget KDE. Nessun riavvio di Plasma necessario.

Percorsi rilevati automaticamente: cache Flatpak `~/.var/app/io.github.yashwanthkamireddi.Skykeep/data/io.github.yashwanthkamireddi.Skykeep/library.db`, oppure cache nativa `~/.local/share/io.github.yashwanthkamireddi.Skykeep/library.db`.

Limiti prototipo: massimo 2.000 eventi per intervallo di 42 giorni, massimo 16 righe di agenda per giorno. Per creare/modificare eventi usare Skykeep. I dati del calendario vengono mostrati sul desktop: il widget non nasconde automaticamente titoli e luoghi.

Test: `python3 -m unittest discover -s tests -v`. `todo.md` contiene i tre obiettivi del progetto; la pull request RAM non include questo widget.
