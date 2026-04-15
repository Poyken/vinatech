BEGIN TRAN; -- Bắt đầu giao dịch để đảm bảo an toàn

UPDATE STB_VN_ITEM_CHECK
SET 
    CODENAME = CASE 
        -- Yêu cầu 1: ĐIỆN CỰC_COATING SREMO83 => SREBO83 (Bao gồm cả lỗi type thường trong data thực tế)
        WHEN TYPEINPUT IN (N'ĐIỆN CỰC_COATING', N'Điện cực_Coating') AND CODENAME = 'SREMO83' THEN 'SREBO83'
        
        -- Yêu cầu 2, 4, 5: ĐIỆN CỰC_SLITING SRFMO83 => SRFBO83 (Đã bao quát cả cuộn âm BA21E-200)
        WHEN TYPEINPUT = N'ĐIỆN CỰC_SLITING' AND CODENAME = 'SRFMO83' THEN 'SRFBO83'
        
        -- Yêu cầu 3: ĐIỆN CỰC_SLITING SREMO83 => SREBO83
        WHEN TYPEINPUT = N'ĐIỆN CỰC_SLITING' AND CODENAME = 'SREMO83' THEN 'SREBO83'
        
        ELSE CODENAME 
    END,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE 
    (TYPEINPUT IN (N'ĐIỆN CỰC_COATING', N'Điện cực_Coating') AND CODENAME = 'SREMO83')
    OR (TYPEINPUT = N'ĐIỆN CỰC_SLITING' AND CODENAME IN ('SRFMO83', 'SREMO83'));

-- Bôi đen chạy lệnh COMMIT để lưu chính thức nếu số dòng báo thành công hợp lý
-- COMMIT TRAN;

-- Bôi đen chạy lệnh ROLLBACK nếu muốn hủy để làm lại
-- ROLLBACK TRAN;


--------------------------------------------------------------------------

INSERT INTO [dbo].[TYPESCRAP] ([TYPES], [TYPENAMES], [CODENAME], [NAMEPRODUCTION], [UNITS], [USERID], [CREATEDATE])
VALUES (
    N'BTP',                             -- Theo quy luật nhóm Bán thành phẩm
    N'BTP_SÔ CHA SAU WINDING',          -- Theo đúng ô anh đang chọn trên màn hình
    N'GW13253R8157',                    -- Theo quy luật mã GW của dòng VEL
    N'1325_VEL13253R8157G-XLC(1325)',   -- Theo định dạng chuẩn 2025 của bên anh
    N'PCS',                             -- Đơn vị chuẩn của nhóm BTP
    N'NguyenDuc', 
    GETDATE()
);