-- ==============================================================================
-- HOTFIX SCRIPT: ADD_MACHINES_WINDING_CURLING_SLEEVING_35105
-- Mục đích: Bổ sung danh mục máy chọn trên POP Kiosk cho Model 35105 (ECVT30-357)
--   1. Chuẩn hóa tên máy VVMHY96 thành 'Sleeving C#6' (tránh đúp tên Sleeving C#7)
--   2. Công đoạn Winding (V-22_HY): 20 máy (Winding C#1-1 đến C#10-2)
--   3. Công đoạn Curling (V-24_HY): 10 máy (Curling C#1 đến C#10)
--   4. Công đoạn Bọc vỏ / Sleeving (V-25_HY): 10 máy (Sleeving C#1 đến C#10)
-- Phạm vi áp dụng: Các Line Cell Hưng Yên sản xuất Model 35105
--   (VVHYC-01, VVHYC-02, VVHYC-03, VVHYC-04, VVHYC-05, VVHYC-06, VVHYC-07, VVHYC-09, VVHYC-10)
-- Bảng tác động: STB_MachineMaster (sửa tên hiển thị), STB_ProductMachine (màn hình B270)
-- Người lập: Antigravity MES Pair Programmer
-- Ngày lập: 2026-09-20
-- ==============================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

-- 1. CHUẨN HÓA TÊN MÁY BỌC VỎ CELL #6
UPDATE STB_MachineMaster
SET MachineName = 'Sleeving C#6',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE MachineCode = 'VVMHY96' 
  AND MachineName = 'Sleeving C#7';

-- 2. BẢNG TẠM CHỨA DANH SÁCH LINE CELL HƯNG YÊN CẦN ÁP DỤNG
DECLARE @TargetLines TABLE (LineCode VARCHAR(20));
INSERT INTO @TargetLines (LineCode)
VALUES 
    ('VVHYC-01'),
    ('VVHYC-02'),
    ('VVHYC-03'),
    ('VVHYC-04'),
    ('VVHYC-05'),
    ('VVHYC-06'),
    ('VVHYC-07'),
    ('VVHYC-09'),
    ('VVHYC-10');

-- 3. BỔ SUNG 20 MÁY WINDING VÀO CÔNG ĐOẠN V-22_HY
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT m.MachineCode, l.LineCode, 'V-22_HY', GETDATE(), 'vanduc'
FROM @TargetLines l
CROSS JOIN (
    VALUES
        ('VVMHY21'), -- Winding C#1-01
        ('VVMHY22'), -- Winding C#1-02
        ('VVMHY39'), -- Winding C#2-01
        ('VVMHY40'), -- Winding C#2-02
        ('VVMHY52'), -- Winding C#3-01
        ('VVMHY53'), -- Winding C#3-02
        ('VVMHY65'), -- Winding C#4-01
        ('VVMHY66'), -- Winding C#4-02
        ('VVMHY78'), -- Winding C#5-01
        ('VVMHY79'), -- Winding C#5-02
        ('VVMHY91'), -- Winding C#6-01
        ('VVMHY92'), -- Winding C#6-02
        ('VVMHY104'), -- Winding C#7-01
        ('VVMHY105'), -- Winding C#7-02
        ('VVMHY117'), -- Winding C#8-01
        ('VVMHY118'), -- Winding C#8-02
        ('VVMHY130'), -- Winding C#9-01
        ('VVMHY131'), -- Winding C#9-02
        ('VVMHY143'), -- Winding C#10-01
        ('VVMHY144')  -- Winding C#10-02
) AS m(MachineCode)
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine 
    WHERE LineCode = l.LineCode 
      AND RouteCode = 'V-22_HY' 
      AND MachineCode = m.MachineCode
);

-- 4. BỔ SUNG 10 MÁY CURLING VÀO CÔNG ĐOẠN V-24_HY
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT m.MachineCode, l.LineCode, 'V-24_HY', GETDATE(), 'vanduc'
FROM @TargetLines l
CROSS JOIN (
    VALUES
        ('VVMHY25'), -- Curling C#1
        ('VVMHY43'), -- Curling C#2
        ('VVMHY56'), -- Curling C#3
        ('VVMHY69'), -- Curling C#4
        ('VVMHY82'), -- Curling C#5
        ('VVMHY95'), -- Curling C#6
        ('VVMHY108'), -- Curling C#7
        ('VVMHY121'), -- Curling C#8
        ('VVMHY134'), -- Curling C#9
        ('VVMHY147')  -- Curling C#10
) AS m(MachineCode)
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine 
    WHERE LineCode = l.LineCode 
      AND RouteCode = 'V-24_HY' 
      AND MachineCode = m.MachineCode
);

-- 5. BỔ SUNG 10 MÁY BỌC VỎ (SLEEVING) VÀO CÔNG ĐOẠN V-25_HY
INSERT INTO STB_ProductMachine (MachineCode, LineCode, RouteCode, CreateDateTime, CreateUserID)
SELECT m.MachineCode, l.LineCode, 'V-25_HY', GETDATE(), 'vanduc'
FROM @TargetLines l
CROSS JOIN (
    VALUES
        ('VVMHY26'), -- Sleeving C#1
        ('VVMHY44'), -- Sleeving C#2
        ('VVMHY57'), -- Sleeving C#3
        ('VVMHY70'), -- Sleeving C#4
        ('VVMHY83'), -- Sleeving C#5
        ('VVMHY96'), -- Sleeving C#6
        ('VVMHY109'), -- Sleeving C#7
        ('VVMHY122'), -- Sleeving C#8
        ('VVMHY135'), -- Sleeving C#9
        ('VVMHY148')  -- Sleeving C#10
) AS m(MachineCode)
WHERE NOT EXISTS (
    SELECT 1 FROM STB_ProductMachine 
    WHERE LineCode = l.LineCode 
      AND RouteCode = 'V-25_HY' 
      AND MachineCode = m.MachineCode
);

COMMIT TRANSACTION;
GO
