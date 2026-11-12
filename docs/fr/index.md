---
title: Puissance
description: Gérer les actions d'alimentation, le comportement en veille et le mode de maintien en activité.
---
`argvus-power` intègre les actions d'alimentation, le délai d'inactivité, la gestion du verrouillage/DPMS et l'état de maintien éveillé avec la session. Le Centre de Contrôle et le Panneau de Configuration exposent les commandes accessibles à l'utilisateur.

Utilisez les aides installées et `--help` pour leurs options exactes. La liste des services de session et les commandes de redémarrage sont documentées dans [Services](/docs/reference/services/).

Utilisez **Centre de Contrôle → Alimentation** pour les pages de politique d'alimentation/session disponibles et **Panneau de Configuration → Session/Alimentation** pour les actions immédiates telles que le verrouillage, la suspension, la déconnexion ou l’arrêt lorsque ces actions sont disponibles. L'action du panneau ne remplace pas la configuration persistante de l'inactivité ou du DPMS.

## Maintien Éveillé

Keep Awake est disponible dans **Centre de Contrôle → Alimentation**, **Panneau de Configuration → Session/Alimentation**, et via `SUPER + ALT + W`. Les contrôles partagent le même état de session, donc le modifier sur une interface met à jour le comportement des autres. Chaque activation ou désactivation affiche une notification.

Lorsqu'il est activé, Keep Awake empêche la politique d'inactivité ARGVUS de démarrer le verrouillage automatique de l'écran et les minuteries d'alimentation de l'affichage. Keep Awake est une préférence `/power/keep_awake` persistante : `argvus-config` projette le marqueur `data/power/keep-awake`, et tant que ce fichier est activé, la session ne démarre pas `argvus-hypridle.service`. Désactivez Keep Awake pour restaurer le comportement normal de veille et de verrouillage.

:::attention
Si l'écran ne se verrouille pas automatiquement, vérifiez si Keep Awake est activé et désactivez-le si nécessaire.
:::
