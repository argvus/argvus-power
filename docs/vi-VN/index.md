---
title: Power
description: Quản lý các hành động năng lượng, hành vi nhàn rỗi và chế độ giữ máy hoạt động.
---

`argvus-power` tích hợp các hành động năng lượng, thời gian chờ nhàn rỗi, xử lý khóa/DPMS và trạng thái giữ máy hoạt động với phiên. Trung tâm điều khiển và Bảng điều khiển cung cấp các điều khiển dành cho người dùng.

Sử dụng các trình trợ giúp đã cài đặt và `--help` cho các tùy chọn chính xác của chúng. Danh sách dịch vụ phiên và các lệnh khởi động lại được ghi trong [Dịch vụ](/docs/reference/services/).

Sử dụng **Trung tâm Điều khiển → Nguồn** cho các trang chính sách nguồn/phiên có sẵn và **Bảng Điều khiển → Phiên/Nguồn** cho các hành động ngay lập tức như khóa, tạm dừng, đăng xuất hoặc tắt máy khi các hành động đó có sẵn. Hành động trên bảng không thay thế cho cấu hình chờ lâu dài hoặc DPMS.

## Giữ máy hoạt động

Keep Awake có sẵn trong **Trung tâm điều khiển → Nguồn**, **Bảng điều khiển → Phiên/Nguồn**, và thông qua `SUPER + ALT + W`. Các điều khiển chia sẻ cùng trạng thái phiên, vì vậy thay đổi nó trên một giao diện sẽ cập nhật hành vi của các giao diện khác. Mỗi lần kích hoạt hoặc hủy kích hoạt sẽ hiển thị thông báo.

Khi được bật, Keep Awake ngăn chính sách nhàn rỗi ARGVUS khởi động các bộ hẹn giờ khóa màn hình và nguồn hiển thị tự động. Keep Awake là một tùy chọn `/power/keep_awake` liên tục: `argvus-config` dự án đánh dấu `data/power/keep-awake`, và khi tập tin đó được bật, phiên làm việc sẽ không khởi động `argvus-hypridle.service`. Vô hiệu hóa Keep Awake để khôi phục hành vi nhàn rỗi và khóa màn hình bình thường.

:::caution
Nếu màn hình không tự động khóa, hãy kiểm tra xem tính năng Giữ Máy tỉnh táo có được bật hay không và tắt nó nếu cần.
:::
