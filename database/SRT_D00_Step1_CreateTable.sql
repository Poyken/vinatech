-- ============================================================
-- BƯỚC 1: TẠO BẢNG STB_VVT_SortingErrorData
-- Database: SmartFactoryV2
-- Người tạo: EA Team
-- Ngày tạo: 2026-04-21
-- Màn hình: SRT_D00 - Sorting Error Data
-- ============================================================

USE SmartFactoryV2;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_VVT_SortingErrorData')
BEGIN

    CREATE TABLE [dbo].[STB_VVT_SortingErrorData] (
        -- === KEY ===
        [SortingErrorNo]    VARCHAR(20)     NOT NULL CONSTRAINT PK_STB_VVT_SortingErrorData PRIMARY KEY,

        -- === THÔNG TIN CHUNG ===
        [SortingDate]       DATE            NOT NULL,
        [Shift]             VARCHAR(5)      NULL,           -- A / B / C
        [PersonName]        NVARCHAR(100)   NULL,           -- Tên người sorting
        [VendorCode]        VARCHAR(50)     NULL,           -- Nhà cung cấp
        [FactoryName]       NVARCHAR(100)   NULL,           -- Bắc Ninh / Bắc Giang
        [MaterialCode]      VARCHAR(50)     NULL,           -- Mã vật liệu (VD: 3505, 685)
        [LotNo]             VARCHAR(100)    NULL,           -- Số lô
        [MaterialType]      VARCHAR(20)     NOT NULL,       -- 'ALCASE' hoặc 'PLATE'
        [QtyCheck]          INT             NULL DEFAULT 0, -- Tổng SL kiểm tra
        [QtyOK]             INT             NULL DEFAULT 0, -- SL đạt
        [Remark]            NVARCHAR(200)   NULL,           -- Ghi chú

        -- ============================================================
        -- LỖI DÀNH CHO AL CASE (MaterialType = 'ALCASE')
        -- ============================================================
        [ALBuiDust]         INT             NULL DEFAULT 0, -- Bụi
        [ALMoDent]          INT             NULL DEFAULT 0, -- Mố Dent
        [ALMepDeform]       INT             NULL DEFAULT 0, -- Mép Deform
        [ALXuocScratch]     INT             NULL DEFAULT 0, -- Xước Scratch
        [ALBongNBPlating]   INT             NULL DEFAULT 0, -- Bóng bu NB Plating
        [ALSanRoughFace]    INT             NULL DEFAULT 0, -- Sần Rough Face
        [ALBanDirty]        INT             NULL DEFAULT 0, -- Bẩn Dirty
        [ALBanBoDentGroup]  INT             NULL DEFAULT 0, -- Bẩn/Bọ Dent Group
        [ALBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc Discolor
        [ALLoiKhacOther]    INT             NULL DEFAULT 0, -- Lỗi khác Other

        -- ============================================================
        -- LỖI DÀNH CHO PLATE (MaterialType = 'PLATE')
        -- ============================================================
        [PLBuuNhom]         INT             NULL DEFAULT 0, -- Bựu nhôm
        [PLBuuNhua]         INT             NULL DEFAULT 0, -- Bựu Nhựa
        [PLBuuRandom]       INT             NULL DEFAULT 0, -- Bựu random
        [PLBongTamNhieu]    INT             NULL DEFAULT 0, -- Bóng tâm nhều
        [PLXuocScratch]     INT             NULL DEFAULT 0, -- Xước/Scratch
        [PLBienDangDeform]  INT             NULL DEFAULT 0, -- Biến dạng/Deform
        [PLMoDongExposed]   INT             NULL DEFAULT 0, -- Mở dòng/Exposed
        [PLBienDangCamSu]   INT             NULL DEFAULT 0, -- Biến dạng cạm su
        [PLNutGoCrackWood]  INT             NULL DEFAULT 0, -- Nứt gỗ/Crack Wood
        [PLBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc/Discoloration
        [PLOther]           INT             NULL DEFAULT 0, -- Other

        -- === AUDIT ===
        [CreateDateTime]    DATETIME        NOT NULL DEFAULT GETDATE(),
        [CreateUserID]      VARCHAR(20)     NULL,
        [ChangeDateTime]    DATETIME        NULL,
        [ChangeUserID]      VARCHAR(20)     NULL
    );

    -- Index để search nhanh theo ngày và loại vật liệu
    CREATE INDEX IX_VVT_SortingErrorData_Date 
        ON STB_VVT_SortingErrorData (SortingDate, MaterialType);

    PRINT 'Tạo bảng STB_VVT_SortingErrorData thành công!';
END
ELSE
BEGIN
    PRINT 'Bảng STB_VVT_SortingErrorData đã tồn tại, bỏ qua.';
END
GO
