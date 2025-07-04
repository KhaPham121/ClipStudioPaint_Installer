=== Tiếng Việt ===
# 🎨 Trợ Lý Sao Lưu Clip Studio Paint

Công cụ đơn giản giúp bạn **sao lưu** và **khôi phục** dữ liệu người dùng trong **Clip Studio Paint** – bao gồm brush, layout, cài đặt tùy chỉnh và nhiều hơn nữa. Hoàn hảo để đảm bảo dữ liệu của bạn luôn an toàn hoặc để chuyển đổi sang máy khác nhanh chóng.

---

## 📁 Các tập tin trong dự án

| Tên tập tin            | Mô tả chức năng                                                               |
|------------------------|--------------------------------------------------------------------------------|
| `CSPData_Helper.bat`   | Script chính để sao lưu hoặc khôi phục dữ liệu người dùng Clip Studio Paint   |
| `Setup.bat`            | Tạo shortcut và cấu hình thư mục làm việc đúng cách cho script chính          |

---

## 🧰 Chi tiết

### 1. `CSPData_Helper.bat`

✅ **Chức năng:**
- **Sao lưu:** Lưu dữ liệu người dùng từ thư mục `%APPDATA%\CELSYSUserData`
- **Khôi phục:** Ghi đè dữ liệu người dùng hiện tại từ bản sao lưu trước đó

📍 **Vị trí sao lưu:**
- Thư mục `Backup` nằm **trong cùng thư mục** chứa script

📂 **Dữ liệu bao gồm:**
- Brush tùy chỉnh, layout, màu sắc, shortcut key, cài đặt công cụ cá nhân

🖥️ **Giao diện dòng lệnh đơn giản:**
- Nhấn `1` để sao lưu
- Nhấn `2` để khôi phục

---

### 2. `Setup.bat`

✅ **Chức năng:**
- Tự động tạo shortcut `CSPData_Helper.lnk` để bạn dễ dàng chạy
- Đảm bảo script hoạt động trong đúng thư mục để các đường dẫn tương đối (`BackupData`) luôn chính xác

---

## 🚀 Hướng dẫn sử dụng

1. **Tải về** hoặc **clone** repository này về máy tính
2. Chạy `Setup.bat` (chỉ một lần đầu) để tạo shortcut
3. Chạy shortcut `CSPData_Helper.lnk` hoặc mở `CSPData_Helper.bat` trực tiếp
4. Chọn:
   - `1` để **sao lưu**
   - `2` để **khôi phục**
5. Làm theo hướng dẫn hiển thị

---

## ⚠️ Xử lý lỗi

| Vấn đề                                     | Cách xử lý                                                                 |
|--------------------------------------------|----------------------------------------------------------------------------|
| Không tạo được shortcut                    | Chạy `Setup.bat` với quyền **Quản trị (Administrator)**                   |
| Không tìm thấy `%APPDATA%\CELSYSUserData` | Mở Clip Studio Paint ít nhất một lần để tạo dữ liệu người dùng             |
| Script thoát ngay sau khi mở              | Chạy từ shortcut hoặc dùng Command Prompt để xem thông báo lỗi             |
| Sao lưu hoặc khôi phục không có tác dụng   | Đảm bảo thư mục chứa script không có ký tự đặc biệt hoặc dấu cách phức tạp |

---

## 💡 Mẹo nhỏ

- Hãy sao lưu thường xuyên, đặc biệt trước khi cập nhật phần mềm hoặc cài lại máy
- Bạn có thể tùy chỉnh script để đổi tên thư mục backup, thêm tùy chọn nén, v.v.

---

## 🙋 Liên hệ

Tác giả: [KhaPham121](https://github.com/KhaPham121)  
Mọi góp ý, chỉnh sửa hoặc báo lỗi, hãy gửi issue hoặc pull request nhé!

---

🖌️ *Lưu trữ sự sáng tạo của bạn – vì mỗi tác phẩm nghệ thuật đều xứng đáng được bảo vệ.*



=== English ===
# 🎨 Clip Studio Paint Script Helper

This helper tool is designed to **back up** and **restore** user data from **Clip Studio Paint**, including workspace layouts, tools, brushes, and more—making it easy to save or transfer your settings.

## 📁 Files Included

| Filename              | Description                                                                   |
|-----------------------|-------------------------------------------------------------------------------|
| `CSPData_Helper.bat`  | Main script for backing up or restoring Clip Studio Paint user data           |
| `Setup.bat`           | Creates shortcut to CSPData_Helper and sets working directory correctly       |

---

## 🧰 Details

### 1. `CSPData_Helper.bat`

✅ **Functionality:**
- **Back Up:** Saves user data from `%APPDATA%\CELSYSUserData`
- **Restore:** Replaces current data with previously backed-up data

📍 **Backup Location:**
- `Backup` folder located in the **same directory** as the script

📂 **Data Involved:**
- Custom brushes, layouts, palettes, shortcut keys, and other user preferences

🖥️ **Interface:**
- Simple command-line menu:
   - Press `1` to **Back Up**
   - Press `2` to **Restore**

---

### 2. `Setup.bat`

✅ **Functionality:**
- Automatically creates a shortcut to `CSPData_Helper.bat`
- Ensures correct working directory so relative paths (like `BackupData`) are valid

---

## 🚀 How to Use

1. **Download** or **clone** this repository to a local folder
2. Run `Setup.bat` (once) to generate the shortcut
3. Double-click `CSPData_Helper.lnk` or run the batch file directly
4. Choose:
   - `1` to back up your current settings
   - `2` to restore from your previous backup
5. Follow the on-screen instructions

---

## ⚠️ Troubleshooting

| Problem                                     | Solution                                                                |
|--------------------------------------------|-------------------------------------------------------------------------|
| Shortcut not created                        | Try running `Setup.bat` as **Administrator**                           |
| No data found in `%APPDATA%\CELSYSUserData` | Make sure Clip Studio Paint has been opened at least once              |
| Script exits immediately                    | Run from shortcut or use command line to view any error messages       |
| Backup or restore does nothing              | Ensure script folder path doesn’t contain special characters or spaces |

---

## 💡 Tips

- Back up before reinstalling or updating Clip Studio Paint
- You can customize the script to point to other folders or add compression

---

## 🙋 Contact

Author: [KhaPham121](https://github.com/KhaPham121)  
Issues, suggestions, or improvements? Feel free to submit a pull request!

---

🖌️ *Back up your creativity—because your art deserves to be safe.*
