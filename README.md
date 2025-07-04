# CSPData_Helper.bat

Script hỗ trợ **sao lưu** và **khôi phục** dữ liệu người dùng của **Clip Studio Paint (CSP)** một cách nhanh chóng và đơn giản.

## Chức năng

- Tự động xác định thư mục dữ liệu người dùng của CSP.
- **Sao lưu** toàn bộ dữ liệu vào thư mục `backup` (nằm cùng vị trí với script).
- **Khôi phục** dữ liệu từ thư mục `backup` về lại vị trí gốc.
- Hiển thị thông báo rõ ràng trong quá trình thực thi.

## Cách sử dụng

1. Tải file `CSPData_Helper.bat` về máy.
2. Đặt script ở nơi bạn muốn lưu bản sao lưu.
3. Nhấp đúp để chạy script.
4. Khi được hỏi:
   - Nhấn `1` để **sao lưu** dữ liệu CSP vào thư mục `backup`.
   - Nhấn `2` để **khôi phục** dữ liệu từ thư mục `backup` về thư mục gốc.

> ⚠️ Lưu ý: Thư mục `backup` sẽ được tạo tự động nếu chưa tồn tại.

## Xử lý lỗi

- **Không tìm thấy thư mục dữ liệu CSP**:
  - Đảm bảo bạn đã từng mở Clip Studio Paint ít nhất một lần.
- **Không tìm thấy thư mục `backup` khi khôi phục**:
  - Hãy chắc chắn bạn đã thực hiện sao lưu trước đó.
- **Script không chạy**:
  - Nhấp chuột phải → Chọn “Run as Administrator”.
  - Kiểm tra phần mềm bảo mật có đang chặn script không.

---

==== ENGLISH VERSION ====

# CSPData_Helper.bat

A simple batch script to **back up** and **restore** user data from **Clip Studio Paint (CSP)**.

## Features

- Automatically detects the CSP user data directory.
- **Backs up** all data to a `backup` folder (located in the same directory as the script).
- **Restores** data from the `backup` folder back to the original location.
- Provides clear prompts during execution.

## How to Use

1. Download the `CSPData_Helper.bat` file.
2. Place it wherever you want the backup to be stored.
3. Double-click to run the script.
4. When prompted:
   - Press `1` to **back up** CSP data to the `backup` folder.
   - Press `2` to **restore** data from the `backup` folder to the original CSP location.

> ⚠️ Note: The `backup` folder will be created automatically if it doesn’t exist.

## Troubleshooting

- **CSP data folder not found**:
  - Make sure you have opened Clip Studio Paint at least once before running the script.
- **Missing `backup` folder when restoring**:
  - Ensure that you have created a backup beforehand.
- **Script won’t run**:
  - Right-click the script → Select “Run as Administrator”.
  - Check if antivirus or Windows Defender is blocking it.

---

© 2025 – Script by [KhaPham121](https://github.com/KhaPham121)



