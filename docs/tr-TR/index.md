---
title: Güç
description: Güç eylemlerini, boşta kalma davranışını ve sürekli uyandırma modunu yönetin.
---

`argvus-power` güç eylemlerini, boşta kalma zaman aşımını, kilit/DPMS yönetimini ve sürekli uyandırma durumunu oturum ile entegre eder. Kontrol Merkezi ve Kontrol Paneli kullanıcıya yönelik kontrolleri sunar.

Kurulu yardımcıları ve `--help`'yi tam seçenekleri için kullanın. Oturum hizmeti listeleme ve yeniden başlatma komutları [Hizmetler](/docs/reference/services/) bölümünde belgelenmiştir.

**Kontrol Merkezi → Güç** bölümünü mevcut güç/oturum politikası sayfaları için ve **Kontrol Paneli → Oturum/Güç** bölümünü, bu eylemler kullanılabilir olduğunda kilitleme, askıya alma, oturumu kapatma veya kapatma gibi hemen yapılacak işlemler için kullanın. Panel eylemi, kalıcı boşta kalma veya DPMS yapılandırmasının yerine geçmez.

## Uyanık Tut

Keep Awake, **Kontrol Merkezi → Güç**, **Kontrol Paneli → Oturum/Güç** ve `SUPER + ALT + W` üzerinden kullanılabilir. Kontroller aynı oturum durumunu paylaşır, bu yüzden bir yüzeyde bunu değiştirmek diğerlerinin davranışını günceller. Her etkinleştirme veya devre dışı bırakma bir bildirim gösterir.

Etkinleştirildiğinde, Keep Awake ARGVUS boşta kalma politikasının otomatik ekran kilidi ve ekran güç zamanlayıcılarını başlatmasını engeller. Keep Awake kalıcı bir `/power/keep_awake` tercihtir: `argvus-config` işaretleyici `data/power/keep-awake` projeler ve bu dosya etkin olduğu sürece oturum `argvus-hypridle.service` başlatmaz. Normal boşta kalma ve kilit davranışını geri yüklemek için Keep Awake'i devre dışı bırakın.

:::dikkat
Ekran otomatik olarak kilitlenmiyorsa, Keep Awake'in etkin olup olmadığını kontrol edin ve gerekirse devre dışı bırakın.
:::
