# ⚙️ AI AGENT CONFIG — DATABASE WORKSPACE

Thư mục này chứa toàn bộ cấu hình tối ưu hiệu năng và quy chuẩn vận hành cho AI Agent khi thao tác với hệ sinh thái 15 CSDL tại Vinatech:

## 📁 Danh Mục Tệp Tin
1. **`DATABASE_MATRIX.json`**: L1 Cache cực nhanh (<0.001s, ~150 tokens) chứa định danh 15 CSDL, bảng chính, PK, quan hệ, mức độ rủi ro và profile kết nối.
2. **`RULES.md`**: 10 Quy tắc vàng bất biến khi truy cập CSDL máy chủ Production.
3. **`KNOWLEDGE.md`**: Cheat sheet nén gọn về kiến trúc 3 Trụ Cột, các bảng trung tâm và các câu truy vấn mẫu.
4. **`LESSONS_LEARNED.md`**: Tổng hợp các cạm bẫy truy vấn thực tế, kinh nghiệm chống nghẽn (anti-lock), và lưu ý Unicode/Collation.
