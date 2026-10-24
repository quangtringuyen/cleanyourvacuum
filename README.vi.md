# Hướng Dẫn Root, Cài Valetudo & Nạp Giọng Nói Tiếng Việt Cho Xiaomi Vacuum-Mop P (STYTJ02YM / STYJ02YM)

[English Version](README.md) | [Bản Tiếng Việt](README.vi.md)

Bộ công cụ tự động hóa hoàn chỉnh và đã kiểm nghiệm thực tế để **Root robot hút bụi lau nhà Xiaomi Mi Robot Vacuum-Mop P / Pro** (mã `STYTJ02YM` / `STYJ02YM`, phần cứng Viomi V7/V8), cài đặt **Valetudo** (giao diện web điều khiển cục bộ 100% không phụ thuộc đám mây) và **thay thế toàn bộ giọng nói sang Tiếng Việt chuẩn tự nhiên**.

---

## 🌟 Tính Năng Nổi Bật
1. **Điều Khiển Cục Bộ 100% (Valetudo)**: Truy cập robot trực tiếp qua trình duyệt web tại `http://<IP_ROBOT>` (trên iPhone, Android, Mac, máy tính Windows).
   - Bản đồ quét laser LiDAR trực tiếp theo thời gian thực.
   - Khoanh vùng dọn dẹp, tạo tường ảo, khu vực cấm vào trực tiếp trên trình duyệt với độ trễ bằng 0.
   - Thoát khỏi hoàn toàn đám mây Xiaomi (không lo khóa vùng, không bắt buộc dùng máy chủ Trung Quốc hay lỗi máy chủ quốc tế).
   - Tích hợp chuẩn MQTT / Home Assistant / Apple HomeKit dễ dàng.
2. **Gói Giọng Nói Tiếng Việt Tự Nhiên**: Đầy đủ 139 câu thông báo cho mọi hành động, trạng thái và cảnh báo lỗi.
3. **Xóa Bỏ Tiếng Trung Vĩnh Viễn**: Tiết kiệm bộ nhớ trong và không bao giờ bị phát tiếng Trung khó hiểu.
4. **Quyền Quản Trị SSH Vĩnh Viễn**: Điều khiển và tùy chỉnh robot không dây qua mạng Wi-Fi bất kỳ lúc nào (`ssh vacuum`).
5. **Tối Ưu Hóa Hiệu Năng & Lực Hút/Chổi Cuộn**: Tăng cường lực chổi cuộn lên 80% và tắt toàn bộ nhật ký rác thừa giúp máy mát và chạy mượt hơn.

---

## 🛠️ Dụng Cụ Cần Chuẩn Bị
- **Robot:** Xiaomi Mi Robot Vacuum-Mop P / Pro (`STYTJ02YM` hoặc `STYJ02YM`).
- **Cáp kết nối:** 1 sợi cáp **Micro-USB truyền dữ liệu tốt** (kết nối máy tính và robot).
- **Tua vít:** 1 tua vít 4 cạnh (bake) nhỏ (`#0` hoặc `#1`).
- **Máy tính:** Mac hoặc Linux kết nối chung mạng Wi-Fi với robot.
- **Cài đặt công cụ ban đầu trên Mac (qua Terminal):**
  ```bash
  brew install android-platform-tools coreutils wget
  python3 -m pip install gTTS
  ```

---

## 🚀 Hướng Dẫn Nhanh (Sử Dụng Script Tự Động)

Tải kho lưu trữ này về máy tính:
```bash
git clone git@github.com:quangtringuyen/cleanyourvacuum.git
cd cleanyourvacuum
```

---

### Bước 1: Tháo Nắp & Cắm Cáp Micro-USB
1. **Tắt nguồn** robot hoàn toàn (nhấn giữ nút Nguồn cho tới khi đèn tắt hẳn).
2. Tháo hộp bụi / khay nước 2 trong 1 ra ngoài.
3. Lật ngửa robot lên một tấm khăn mềm (tránh làm trầy xước mắt laser LiDAR trên đỉnh).
4. Tháo chổi cuộn chính màu cam và khung bảo vệ chổi.
5. Vặn **4 ốc vít nhỏ** xung quanh khoang chứa pin bên dưới chổi cuộn.
6. **Rút giắc cắm pin** ra khỏi bo mạch chủ (bước này cực kỳ quan trọng để kích hoạt chế độ bootloader).
7. Tìm **cổng Micro-USB** nằm ẩn sát mép bo mạch bên trong khoang này.
8. Cắm đầu cáp Micro-USB vào robot (đầu kia tạm thời chưa cắm vào máy tính).

---

### Bước 2: Kích Hoạt Quyền Root (Exploit Bootloader)
Khởi chạy script lắng nghe kết nối trên máy tính:
```bash
./scripts/1_root_exploit.sh
```

Khi màn hình thông báo bắt đầu lắng nghe, thực hiện chuỗi phím bấm trên robot:
1. **Bấm và GIỮ NGUYÊN nút Home (hình ngôi nhà / dock sạc)** — không thả tay.
2. Trong khi vẫn giữ nút Home: **Cắm đầu cáp USB còn lại vào máy tính**.
3. Trong khi vẫn giữ nút Home: **Bấm liên tục nút Nguồn 10 đến 11 lần**.
4. **Thả cả hai nút ra.**

Script trên máy tính sẽ lập tức bắt được cửa sổ kết nối ADB (1-2 giây), nạp file thực thi `/bin/adb_shell` và vô hiệu hóa dịch vụ watchdog bảo vệ.

---

### Bước 3: Cài Đặt SSH Không Dây & Cắm Lại Pin
1. **Cắm lại giắc pin** vào bo mạch chủ robot.
2. Bật nguồn robot (hoặc đặt robot vào dock sạc nếu pin yếu).
3. Vẫn giữ cáp USB kết nối và chạy:
```bash
./scripts/2_setup_ssh.sh
```
Script này sẽ tự động:
- Cài đặt máy chủ Dropbear SSH lên robot.
- Nạp khóa bảo mật SSH (`id_rsa.pub`) từ máy tính vào robot.
- Tạo khóa máy chủ RSA chuẩn (sửa lỗi Dropbear rỗng trên OpenWrt).
- Phục hồi lại các dịch vụ vận hành của robot.
- Lưu cấu hình alias `ssh vacuum` vào file `~/.ssh/config` trên máy tính.

*Lúc này bạn đã có thể rút cáp USB, vặn lại 4 ốc vít và lắp ráp robot hoàn chỉnh!*

---

### Bước 4: Nạp Gói Giọng Nói Tiếng Việt
Tạo toàn bộ 139 file âm thanh Tiếng Việt tự nhiên bằng trí tuệ nhân tạo:
```bash
python3 generate_vietnamese_voicepack.py
```

Đẩy gói giọng nói qua Wi-Fi vào robot:
```bash
./scripts/5_deploy_voicepack.sh
```
*(Script sẽ tự động đồng bộ file vào `/mnt/UDISK/audio/vietnamese`, trỏ thư mục âm thanh mặc định sang Tiếng Việt, xóa sạch vĩnh viễn file tiếng Trung cũ và phát thử âm thanh kiểm tra qua loa robot).*

---

### Bước 5: Cài Đặt Valetudo (Giao Diện Điều Khiển Cục Bộ)
Cài đặt Valetudo bằng 1 câu lệnh qua mạng Wi-Fi:
```bash
./scripts/3_install_valetudo.sh
```
Script sẽ tự động:
- Tải bản nhị phân Valetudo ARMv7 chuẩn.
- Cấu hình dịch vụ khởi động cùng hệ thống `/etc/init.d/valetudo`.
- Mở quyền truy cập từ mạng LAN (`blockExternalAccess: false`).
- Điều hướng các máy chủ đám mây của Xiaomi trong `/etc/hosts` về `127.0.0.1` để ngăn chặn khóa máy.
- Khởi động lại robot.

---

### Bước 6: Tối Ưu Hóa Lực Cuộn & Hiệu Năng
Chạy script tinh chỉnh hiệu năng:
```bash
./scripts/4_tweak_performance.sh
```
Tác dụng của bước tối ưu này:
- **Tăng công suất chổi cuộn chính từ 65% lên 80%**: Tăng lực ma sát và đánh bay bụi mịn, tóc rụng trên thảm và khe gạch tốt hơn ~23%.
- **Tắt toàn bộ nhật ký gỡ lỗi (debug logging)**: Phần mềm gốc của nhà máy để bật tính năng ghi log liên tục gây nóng máy, hao pin và mòn chip nhớ; tắt đi giúp CPU chạy mát và nhanh hơn.
- **Tắt dựng hình 3D SLAM không cần thiết**: Giảm tải RAM và CPU cho bo mạch.
- **Dọn dẹp tệp tin rác cũ** trong bộ nhớ trong.

---

## 📱 Truy Cập Giao Diện Điều Khiển

Đợi khoảng 45 giây sau khi robot khởi động xong, mở trình duyệt trên điện thoại hoặc máy tính:
👉 **`http://<IP_ROBOT>`** (Ví dụ: `http://192.168.1.166`)

Chúc mừng bạn đã sở hữu một chú robot hút bụi hoàn toàn tự chủ, bảo mật, nói Tiếng Việt và không phụ thuộc vào bất kỳ máy chủ nào!
