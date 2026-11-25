---
title: القوة
description:                         .ﺎًﻈﻘﻴﺘﺴﻣ ءﺎﻘﺒﻟﺍ ﻊﺿﻭﻭ ﻝﻮﻤﺨﻟﺍ ﻙﻮﻠﺳ ،ﺔﻗﺎﻄﻟﺍ ﺕﺍءﺍﺮﺟﺇ ﺓﺭﺍﺩﺇ
---

`argvus-power` argvus-hypridle.service  data/power/.keep-awake  argvus-config  /power/keep_awake  SUPER + ALT + W  `--help`  integrates power actions, idle timeout, lock/DPMS handling and keep-awake state with the session. The Control Center and Control Panel expose the user-facing controls.



ﻭﺃ ﺮﻤﺘﺴﻤﻟﺍ ﻝﻮﻤﺨﻟﺍ

## ﺎًﻈﻘﻴﺘﺴﻣ ﺯﺎﻬﺠﻟﺍ ءﺎﻘﺑﺇ DPMS.





::: الحذر
.ﺮﻣﻷ﻿ﺍ ﻡﺰﻟ ﺍﺫﺇ ﻪﻠﻴﻄﻌﺘﺑ ﻢﻗﻭ ﺎًﻠﻌﻔﻣ ﺎًﻈﻘﻴﺘﺴﻣ ءﺎﻘﺒﻟﺍ ﺭﺎﻴﺧ ﻥﺎﻛ ﺍﺫﺇ ﺎﻤﻣ ﻖﻘﺤﺗ ،ﺎًﻴﺋﺎﻘﻠﺗ
:::

استخدم المساعدين المثبتين و`SUPER + ALT + W` `/power/keep_awake` `argvus-config` `data/power/.keep-awake` `argvus-hypridle.service` للتعرف على خياراتهم الدقيقة. تم توثيق قائمة خدمة الجلسة وأوامر إعادة التشغيل في [Services](/docs/reference/services/).

**ARGVUS Lifecycle** · `argvus-lifecycle` · `SUPER + Esc`

Hypridle → `argvus lock` → Hyprlock

**ARGVUS مهلة القفل** · `argvus idle-timeout` · `Super + Shift + L` · `↑` `↓` (التنقل) · `Enter` (اختيار) · `Esc` (إغلاق)

يُحفظ التفضيل قبل تطبيقه على Hypridle. قد يظل التطبيق معلقًا عند الفشل أو الانقطاع. افحص الحالة بالأمر `argvus keep-awake status-json` وأعد المحاولة باستخدام `on` أو `off`. يُحتفظ بملف `data/.keep-awake` للتوافق.
