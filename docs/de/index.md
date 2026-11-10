---
title: Kraft
description: Verwalten Sie Energieaktionen, Leerlaufverhalten und Wachhaltefunktion.
---
`argvus-power` integriert Stromaktionen, Inaktivitäts-Timeout, Sperr-/DPMS-Verwaltung und den Wachbleib-Zustand mit der Sitzung. Das Kontrollzentrum und die Systemsteuerung bieten die benutzerorientierten Steuerungen.

Verwenden Sie die installierten Helfer und `--help` für deren genaue Optionen. Die Liste der Sitzungsdienste und Neustartbefehle sind in [Services](/docs/reference/services/) dokumentiert.

Verwenden Sie **Kontrollzentrum → Energie** für die verfügbaren Seiten zur Energie-/Sitzungsrichtlinie und **Systemsteuerung → Sitzung/Energie** für sofortige Aktionen wie Sperren, Suspendieren, Abmelden oder Herunterfahren, wenn diese Aktionen verfügbar sind. Die Aktion im Panel ersetzt nicht die persistente Inaktivitäts- oder DPMS-Konfiguration.

## Wachbleiben

Keep Awake ist verfügbar in **Kontrollzentrum → Stromversorgung**, **Systemsteuerung → Sitzung/Stromversorgung** und über `SUPER + ALT + W`. Die Steuerungen teilen denselben Sitzungszustand, sodass eine Änderung auf einer Oberfläche das Verhalten der anderen aktualisiert. Jede Aktivierung oder Deaktivierung zeigt eine Benachrichtigung an.

Wenn aktiviert, verhindert Keep Awake, dass die ARGVUS-Leerlaufrichtlinie die automatischen Sperr- und Display-Stromzeitschaltuhren startet. Keep Awake ist eine persistente `/power/keep_awake`-Einstellung: `argvus-config` projiziert den Marker `data/power/keep-awake`, und solange diese Datei aktiviert ist, startet die Sitzung `argvus-hypridle.service` nicht. Deaktivieren Sie Keep Awake, um das normale Leerlauf- und Sperrverhalten wiederherzustellen.

:::caution
Wenn der Bildschirm nicht automatisch gesperrt wird, überprüfen Sie, ob Keep Awake aktiviert ist, und deaktivieren Sie es bei Bedarf.
:::
