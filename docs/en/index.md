---
title: Power
description: Manage power actions, idle behavior and keep-awake mode.
---

`argvus-power` integrates power actions, idle timeout, lock/DPMS handling and keep-awake state with the session. The Control Center and Control Panel expose the user-facing controls.

Use the installed helpers and `--help` for their exact options. The session service list and restart commands are documented in [Services](/docs/reference/services/).

Use **Control Center → Power** for the available power/session policy pages and **Control Panel → Session/Power** for immediate actions such as locking, suspending, logging out or shutting down when those actions are available. The panel action is not a replacement for persistent idle or DPMS configuration.

## Keep Awake

Keep Awake is available in **Control Center → Power**, **Control Panel → Session/Power**, and through `SUPER + ALT + W`. The controls share the same session state, so changing it in one surface updates the behavior of the others. Each activation or deactivation displays a notification.

When enabled, Keep Awake prevents the ARGVUS idle policy from starting the automatic screen-lock and display-power timers. Keep Awake is a persistent `/power/keep_awake` preference: `argvus-config` projects the marker `data/power/keep-awake`, and while that file is enabled the session does not start `argvus-hypridle.service`. Disable Keep Awake to restore the normal idle and lock behavior.

:::caution
If the screen does not lock automatically, check whether Keep Awake is enabled and disable it if necessary.
:::
