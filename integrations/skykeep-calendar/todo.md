# Skykeep — progetto

- [x] **Widget calendario Plasma**: bianco, accento di sistema, rettangoli e stile dei widget usage/cheatsheet; agenda dalla cache locale di Skykeep, senza WebEngine o daemon. Verificare nell’uso quotidiano sincronizzazione e impatto aggiuntivo su plasmashell.
- [ ] **RAM Skykeep ≤ 300 MiB complessivi**: prossimo obiettivo, possibilmente meno. Base osservata della 0.1.12 corretta: circa 400 MiB PSS. Misurare un carico ripetibile, ottimizzare e verificare senza regressioni. La realizzazione del widget non equivale al raggiungimento di questo obiettivo.
- [ ] **Pull request RAM**: dopo la prova d’uso e la validazione. Escludere completamente il widget; usare il ramo `codex/skykeep-memory-0.1.12`. Il fix Drive resta separato. Bozza locale in `PR-memoria-bozza.md`, nulla pubblicato.
- [ ] **cambiamento icone**: vanno cambiate le icone nel menu start, nella barra applicazione e nel system tray
