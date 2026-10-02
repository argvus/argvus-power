---
title: Energia
description: Gerencie energia, idle e keep-awake.
slug: pt/0.4.0/docs/user-guide/hardware/power
---

`argvus-power` integra ações de energia, timeout de idle, lock/DPMS e keep-awake à sessão. O Control Center e o Control Panel fornecem os controles. Use `--help` nos helpers instalados.

Use **Control Center → Power** para as páginas de política de energia e sessão disponíveis e **Control Panel → Sessão/Energia** para ações imediatas como bloquear, suspender, sair ou desligar quando estiverem disponíveis. A ação do painel não substitui a configuração persistente de ociosidade ou DPMS.

## Manter acordado

Manter acordado está disponível em **Control Center → Power**, **Control Panel → Sessão/Energia** e pelo atalho `SUPER + ALT + W`. Os controles compartilham o mesmo estado da sessão; portanto, alterar a opção em uma superfície atualiza o comportamento das outras. Cada ativação ou desativação exibe uma notificação.

Quando ativado, Manter acordado impede que a política de ociosidade do ARGVUS inicie os temporizadores automáticos de bloqueio da tela e desligamento do display. Manter acordado é uma preferência persistente em `/power/keep_awake`: o `argvus-config` projeta o marcador `data/power/keep-awake` e, enquanto esse arquivo estiver ativado, a sessão não inicia o `argvus-hypridle.service`. Desative Manter acordado para restaurar o comportamento normal de ociosidade e bloqueio.

:::caution
Se a tela não estiver bloqueando automaticamente, verifique se Manter acordado está ativado e desative-o se necessário.
:::
