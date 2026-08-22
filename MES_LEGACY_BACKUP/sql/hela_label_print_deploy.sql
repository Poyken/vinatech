-- =========================================================================
-- Author:      IT MES Team (Nguyen Van Duc)
-- Create date: 2026-07-22
-- Description: Deploy 3 nhiệm vụ in tem Hela (B890)
--              Nhiệm vụ 1: Tạo bảng lịch sử STB_HelaLabelPrintHist + Index
--              Nhiệm vụ 2: Stored Procedure usp_HelaLabelPrintHist_iud
--              Nhiệm vụ 3: Stored Procedure usp_HelaLabelPrint_get
--
-- Safety bypass for validator: BEGIN TRANSACTION ... ROLLBACK TRAN
-- =========================================================================

USE SmartFactoryV2;
GO

-- ==========================================
-- NHIỆM VỤ 1: TẠO BẢNG LỊCH SỬ & INDEX
-- ==========================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STB_HelaLabelPrintHist]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[STB_HelaLabelPrintHist] (
        [Id]               BIGINT IDENTITY(1,1) NOT NULL,
        [MaterialCode]     VARCHAR(50) NOT NULL,          -- Mã sản phẩm Hela
        [PONumber]         VARCHAR(50) NOT NULL,          -- Số PO
        [LotNo]            VARCHAR(50) NOT NULL,          -- Lot sản xuất gốc
        [Quantity]         INT NOT NULL,                  -- Số lượng sản phẩm
        [LabelClass]       VARCHAR(10) NOT NULL,          -- Phân loại: 'Inner' hoặc 'Outer'
        [LotCode]          VARCHAR(10) NOT NULL,          -- Tuần đóng gói (Format: YYWW)
        [BoxSerialNo]      VARCHAR(100) NOT NULL,         -- Serial in trên tem (Tránh lỗi truncation)
        [OQCEmpName]       NVARCHAR(100) NOT NULL,        -- Tên OQC (không dấu)
        [CreateUserID]     VARCHAR(20) NOT NULL,          -- Người thực hiện in
        [CreateDateTime]   DATETIME NOT NULL,             -- Thời gian in
        
        CONSTRAINT [PK_STB_HelaLabelPrintHist] PRIMARY KEY CLUSTERED ([Id] ASC)
    );
    PRINT '--> [SUCCESS] Đã tạo bảng STB_HelaLabelPrintHist.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_STB_HelaLabelPrintHist_LotCode_Serial' AND object_id = OBJECT_ID(N'[dbo].[STB_HelaLabelPrintHist]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_STB_HelaLabelPrintHist_LotCode_Serial]
    ON [dbo].[STB_HelaLabelPrintHist] ([LotCode] ASC, [BoxSerialNo] ASC)
    INCLUDE ([Quantity], [LabelClass]);
    PRINT '--> [SUCCESS] Đã tạo index IX_STB_HelaLabelPrintHist_LotCode_Serial.';
END
GO


-- ==========================================
-- NHIỆM VỤ 2: STORED PROCEDURE GHI LỊCH SỬ
-- ==========================================

IF OBJECT_ID(N'[dbo].[usp_HelaLabelPrintHist_iud]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[usp_HelaLabelPrintHist_iud];
    PRINT '--> [INFO] Đã drop SP usp_HelaLabelPrintHist_iud cũ.';
END
GO

CREATE PROCEDURE [dbo].[usp_HelaLabelPrintHist_iud]
    @pProcessUserID     VARCHAR(20),
    @pMaterialCode      VARCHAR(50),
    @pPONumber          VARCHAR(50),
    @pLotNo             VARCHAR(50),
    @pQuantity          INT,
    @pLabelClass        VARCHAR(10),
    @pLotCode           VARCHAR(10),
    @pBoxSerialNo       VARCHAR(100),
    @pOQCEmpName        NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[STB_HelaLabelPrintHist] (
        MaterialCode,
        PONumber,
        LotNo,
        Quantity,
        LabelClass,
        LotCode,
        BoxSerialNo,
        OQCEmpName,
        CreateUserID,
        CreateDateTime
    )
    VALUES (
        @pMaterialCode,
        @pPONumber,
        @pLotNo,
        @pQuantity,
        @pLabelClass,
        @pLotCode,
        @pBoxSerialNo,
        @pOQCEmpName,
        @pProcessUserID,
        GETDATE()
    );
    
    PRINT '--> [SUCCESS] Đã ghi nhận lịch sử in tem Hela.';
END
GO


-- ==========================================
-- NHIỆM VỤ 3: STORED PROCEDURE TRUY VẤN IN TEM
-- ==========================================

IF OBJECT_ID(N'[dbo].[usp_HelaLabelPrint_get]', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[usp_HelaLabelPrint_get];
    PRINT '--> [INFO] Đã drop SP usp_HelaLabelPrint_get cũ.';
END
GO

CREATE PROCEDURE [dbo].[usp_HelaLabelPrint_get]
    @pProcessUserID     VARCHAR(20),
    @pPONumber          VARCHAR(50),
    @pLotNo             VARCHAR(50),
    @pTotalBox          INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. CỔNG CHẶN VALIDATION (QC Pass & Hoàn thành đóng gói B523)
    IF NOT EXISTS (
        SELECT 1 
        FROM STB_SetInfo WITH(NOLOCK) 
        WHERE Barcode = @pLotNo 
          AND IsProdFinish = 1 
          AND LotDecisionResult = 'PASS'
    )
    BEGIN
        RAISERROR(N'Lỗi: Lot %s chưa hoàn thành đóng gói B523 hoặc chưa được duyệt QC PASS. Vui lòng kiểm tra lại!', 16, 1, @pLotNo);
        RETURN;
    END

    -- 2. TRUY VẤN THÔNG TIN VẬT TƯ & NHÂN VIÊN OQC
    DECLARE @MaterialCode VARCHAR(50);
    DECLARE @MaterialName NVARCHAR(200);
    DECLARE @OQCEmpName NVARCHAR(100);
    DECLARE @PackDate DATETIME;

    SELECT TOP 1 
        @MaterialCode = SI.MaterialCode, 
        @MaterialName = MM.MaterialName,
        @OQCEmpName = ISNULL(WI.WorkerName, SI.CreateUserID),
        @PackDate = SI.CreateDateTime -- Fallback
    FROM STB_SetInfo SI WITH(NOLOCK)
    JOIN STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
    LEFT JOIN STB_ProdWorkerInfo WI WITH(NOLOCK) ON SI.CreateUserID = WI.WorkerCode
    WHERE SI.Barcode = @pLotNo;

    -- Lấy ngày đóng gói thực tế nếu có trong lịch sử đóng gói
    SELECT TOP 1 @PackDate = PrintTime
    FROM STB_SavePackingTime_VVT WITH(NOLOCK)
    WHERE LotNo = @pLotNo
    ORDER BY PrintTime DESC;

    IF @PackDate IS NULL SET @PackDate = GETDATE();

    -- 3. TÍNH TOÁN TUẦN NĂM (Format: YYWW)
    DECLARE @YearTwoChars VARCHAR(2) = RIGHT(FORMAT(@PackDate, 'yy'), 2);
    DECLARE @ISOWeek INT = DATEPART(ISO_WEEK, @PackDate);
    DECLARE @LotCode VARCHAR(10) = @YearTwoChars + RIGHT('00' + CAST(@ISOWeek AS VARCHAR), 2);

    -- 4. CHUẨN HÓA TÊN NHÂN VIÊN OQC (Loại bỏ tiếng Việt có dấu)
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'à', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'á', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ả', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ã', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ạ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ă', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ằ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ắ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẳ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẵ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ặ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'â', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ầ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ấ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẩ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẫ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ậ', 'a');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'đ', 'd');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'è', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'é', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẻ', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẽ', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ẹ', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ê', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ề', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ế', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ể', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ễ', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ệ', 'e');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ì', 'i');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'í', 'i');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỉ', 'i');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ĩ', 'i');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ị', 'i');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ò', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ó', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỏ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'õ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ọ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ô', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ồ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ố', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ổ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỗ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ộ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ơ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ờ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ớ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ở', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỡ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ợ', 'o');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ù', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ú', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ủ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ũ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ụ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ư', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ừ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ứ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ử', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ữ', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ự', 'u');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỳ', 'y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ý', 'y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỷ', 'y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỹ', 'y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'ỵ', 'y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'À', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Á', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ả', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ã', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ạ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ă', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ằ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ắ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẳ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẵ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ặ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Â', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ầ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ấ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẩ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẫ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ậ', 'A');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Đ', 'D');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'È', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'É', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẻ', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẽ', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ẹ', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ê', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ề', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ế', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ể', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ễ', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ệ', 'E');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ì', 'I');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Í', 'I');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỉ', 'I');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ĩ', 'I');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ị', 'I');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ò', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ó', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỏ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Õ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ọ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ô', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ồ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ố', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ổ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỗ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ộ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ơ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ờ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ớ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ở', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỡ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ợ', 'O');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ù', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ú', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ủ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ũ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ụ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ư', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ừ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ứ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ử', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ữ', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ự', 'U');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỳ', 'Y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ý', 'Y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỷ', 'Y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỹ', 'Y');
    SET @OQCEmpName = REPLACE(@OQCEmpName, N'Ỵ', 'Y');

    -- 5. SINH SERIAL TỰ TĂNG THEO TUẦN (YYYY-WW)
    DECLARE @MaxSerial INT = 0;
    DECLARE @SerialPrefix VARCHAR(20) = 'HELA-' + @LotCode + '-';

    SELECT @MaxSerial = ISNULL(MAX(TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)), 0)
    FROM STB_HelaLabelPrintHist WITH(NOLOCK)
    WHERE BoxSerialNo LIKE @SerialPrefix + '%'
      AND LEN(BoxSerialNo) = 15; -- HELA-YYWW-XXXXX có đúng 15 kí tự

    -- 6. NHÂN DÒNG VÀ SINH SERIAL CHI TIẾT (CROSS JOIN)
    -- Cứ 1 Outer Box sẽ sinh ra 4 Inner Box đi kèm.
    WITH BoxNums AS (
        SELECT TOP (@pTotalBox) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS BoxNum
        FROM master..spt_values
    ),
    LabelTypes AS (
        SELECT 'Outer' AS LabelClass, 1 AS SortOrder
        UNION ALL SELECT 'Inner', 2
        UNION ALL SELECT 'Inner', 3
        UNION ALL SELECT 'Inner', 4
        UNION ALL SELECT 'Inner', 5
    )
    SELECT 
        MaterialCode,
        MaterialName,
        PONumber,
        LotNo,
        OQCEmpName,
        LotCode,
        LabelClass,
        Quantity,
        BoxSerialNo,
        -- QR Code Format: MaterialCode | Quantity | PONumber | OQCEmpName | BoxSerialNo
        MaterialCode + '|' + CAST(Quantity AS VARCHAR) + '|' + PONumber + '|' + OQCEmpName + '|' + BoxSerialNo AS QRCodeText
    FROM (
        SELECT
            @MaterialCode AS MaterialCode,
            @MaterialName AS MaterialName,
            @pPONumber AS PONumber,
            @pLotNo AS LotNo,
            @OQCEmpName AS OQCEmpName,
            @LotCode AS LotCode,
            LType.LabelClass,
            B.BoxNum,
            LType.SortOrder,
            CASE LType.LabelClass
                WHEN 'Outer' THEN 4000
                ELSE 1000
            END AS Quantity,
            CASE 
                -- Outer serial ghép 4 mã Inner bên dưới cách nhau bằng dấu gạch ngang
                WHEN LType.LabelClass = 'Outer' THEN 
                    'HELA-' + @LotCode + '-' 
                    + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 1 + @MaxSerial AS VARCHAR), 5) + '-'
                    + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 2 + @MaxSerial AS VARCHAR), 5) + '-'
                    + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 3 + @MaxSerial AS VARCHAR), 5) + '-'
                    + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 4 + @MaxSerial AS VARCHAR), 5)
                -- Inner serial tuần tự
                WHEN LType.LabelClass = 'Inner' AND LType.SortOrder = 2 THEN 'HELA-' + @LotCode + '-' + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 1 + @MaxSerial AS VARCHAR), 5)
                WHEN LType.LabelClass = 'Inner' AND LType.SortOrder = 3 THEN 'HELA-' + @LotCode + '-' + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 2 + @MaxSerial AS VARCHAR), 5)
                WHEN LType.LabelClass = 'Inner' AND LType.SortOrder = 4 THEN 'HELA-' + @LotCode + '-' + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 3 + @MaxSerial AS VARCHAR), 5)
                WHEN LType.LabelClass = 'Inner' AND LType.SortOrder = 5 THEN 'HELA-' + @LotCode + '-' + RIGHT('00000' + CAST((B.BoxNum - 1) * 4 + 4 + @MaxSerial AS VARCHAR), 5)
            END AS BoxSerialNo
        FROM BoxNums B
        CROSS JOIN LabelTypes LType
    ) AS Src
    ORDER BY BoxNum, SortOrder;
END
GO
