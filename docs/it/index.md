---
title: Potere
description: Gestisci le azioni di alimentazione, il comportamento a riposo e la modalità non in stand-by.
---
`argvus-power` integra azioni di alimentazione, timeout inattivo, gestione del blocco/DPMS e stato di keep-awake con la sessione. Il Centro di Controllo e il Pannello di Controllo espongono i controlli visibili all'utente.

Usa gli helper installati e `--help` per le loro opzioni esatte. L'elenco dei servizi della sessione e i comandi di riavvio sono documentati in [Services](/docs/reference/services/).

Usa **Centro di Controllo → Alimentazione** per le pagine delle politiche di alimentazione/sessione disponibili e **Pannello di Controllo → Sessione/Alimentazione** per azioni immediate come bloccare, sospendere, disconnettere o spegnere quando tali azioni sono disponibili. L'azione del pannello non sostituisce la configurazione persistente di inattività o DPMS.

## Mantieni Attivo

Keep Awake è disponibile in **Centro di Controllo → Alimentazione**, **Pannello di Controllo → Sessione/Alimentazione**, e tramite `SUPER + ALT + W`. I controlli condividono lo stesso stato della sessione, quindi modificarlo in una superficie aggiorna il comportamento delle altre. Ogni attivazione o disattivazione mostra una notifica.

Quando è abilitato, Keep Awake impedisce alla politica di inattività ARGVUS di avviare i timer automatici di blocco dello schermo e di spegnimento del display. Keep Awake è una preferenza persistente di `/power/keep_awake`: `argvus-config` proietta il marcatore `data/power/keep-awake`, e finché quel file è abilitato la sessione non avvia `argvus-hypridle.service`. Disattiva Keep Awake per ripristinare il normale comportamento di inattività e di blocco.

:::attenzione
Se lo schermo non si blocca automaticamente, verifica se Keep Awake è abilitato e disabilitalo se necessario.
:::
