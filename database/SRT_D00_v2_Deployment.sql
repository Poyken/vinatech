-- ============================================================
-- VERSION 2: IDENTITY PK & MINIMAL PARAMETERS
-- ============================================================
USE SmartFactoryV2;
GO

-- 1. DROP OLD TABLE & CREATE NEW
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_VVT_SortingErrorData')
    DROP TABLE STB_VVT_SortingErrorData;
GO

CREATE TABLE [dbo].[STB_VVT_SortingErrorData] (
    [SortingID]         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SortingDate]       DATE            NOT NULL,
    [Shift]             VARCHAR(5)      NULL,
    [PersonName]        NVARCHAR(100)   NULL,
    [VendorCode]        VARCHAR(50)     NULL,
    [FactoryName]       NVARCHAR(100)   NULL,
    [MaterialCode]      VARCHAR(50)     NULL,
    [LotNo]             VARCHAR(100)    NULL,
    [MaterialType]      VARCHAR(20)     NOT NULL, -- 'ALCASE' hoặc 'PLATE'
    [QtyCheck]          INT             NULL DEFAULT 0,
    [QtyOK]             INT             NULL DEFAULT 0,
    [Remark]            NVARCHAR(200)   NULL,
    -- Group AL Case
    [ALBuiDust] INT, [ALMoDent] INT, [ALMepDeform] INT, [ALXuocScratch] INT, [ALBongNBPlating] INT,
    [ALSanRoughFace] INT, [ALBanDirty] INT, [ALBanBoDentGroup] INT, [ALBienSacDiscolor] INT, [ALLoiKhacOther] INT,
    -- Group Plate
    [PLBuuNhom] INT, [PLBuuNhua] INT, [PLBuuRandom] INT, [PLBongTamNhieu] INT, [PLXuocScratch] INT,
    [PLBienDangDeform] INT, [PLMoDongExposed] INT, [PLBienDangCamSu] INT, [PLNutGoCrackWood] INT, [PLBienSacDiscolor] INT, [PLOther] INT,
    -- Audit
    [CreateDateTime]    DATETIME        NOT NULL DEFAULT GETDATE(),
    [CreateUserID]      VARCHAR(20)     NULL,
    [ChangeDateTime]    DATETIME        NULL,
    [ChangeUserID]      VARCHAR(20)     NULL
);
GO

-- 2. SP SEARCH (Minimal parameters)
PRINT 'Creating usp_VVT_SortingErrorData_get...';
GO
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_get]
    @pProcessUserID     VARCHAR(20)    = NULL, 
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL, 
    @pDateFrom          DATE           = NULL,
    @pDateTo            DATE           = NULL,
    @pMaterialCode      VARCHAR(50)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Tự động nhận diện ALCASE hay PLATE từ ViewName
    DECLARE @vMaterialType VARCHAR(20) = CASE 
        WHEN @pProcessViewName LIKE '%ALCASE%' THEN 'ALCASE'
        WHEN @pProcessViewName LIKE '%PLATE%'  THEN 'PLATE'
        ELSE NULL END;

    SELECT
        SortingID,
        CONVERT(VARCHAR(10), SortingDate, 23) AS SortingDate, -- Force YYYY-MM-DD
        Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        -- Total calculation for UI (Single row total)
        CASE WHEN MaterialType = 'ALCASE' THEN
            ISNULL(ALBuiDust,0)+ISNULL(ALMoDent,0)+ISNULL(ALMepDeform,0)+ISNULL(ALXuocScratch,0)+ISNULL(ALBongNBPlating,0)+ISNULL(ALSanRoughFace,0)+ISNULL(ALBanDirty,0)+ISNULL(ALBanBoDentGroup,0)+ISNULL(ALBienSacDiscolor,0)+ISNULL(ALLoiKhacOther,0)
        ELSE
            ISNULL(PLBuuNhom,0)+ISNULL(PLBuuNhua,0)+ISNULL(PLBuuRandom,0)+ISNULL(PLBongTamNhieu,0)+ISNULL(PLXuocScratch,0)+ISNULL(PLBienDangDeform,0)+ISNULL(PLMoDongExposed,0)+ISNULL(PLBienDangCamSu,0)+ISNULL(PLNutGoCrackWood,0)+ISNULL(PLBienSacDiscolor,0)+ISNULL(PLOther,0)
        END AS TotalDefect
    FROM STB_VVT_SortingErrorData WITH(NOLOCK)
    WHERE (@pDateFrom IS NULL OR SortingDate >= @pDateFrom)
      AND (@pDateTo   IS NULL OR SortingDate <= @pDateTo)
      AND (@vMaterialType IS NULL OR MaterialType = @vMaterialType)
      AND (@pMaterialCode IS NULL OR MaterialCode LIKE '%' + @pMaterialCode + '%')
    ORDER BY SortingDate DESC, SortingID DESC;
END
GO

-- 3. SP IUD (Minimal parameters & handle IDENTITY)
PRINT 'Creating usp_VVT_SortingErrorData_iud...';
GO
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_iud', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_iud;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_iud]
    @pProcessUserID     VARCHAR(20)    = NULL,
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL,
    @pXml               NVARCHAR(MAX)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @iDoc INT;
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    -- Xử lý DELETE
    DELETE T FROM STB_VVT_SortingErrorData T
    JOIN OPENXML(@iDoc, '/DataSet/SortingData_DELETE', 2) WITH (SortingID INT) X 
    ON T.SortingID = X.SortingID;

    -- Xử lý INSERT (Không cần sinh Serial thủ công nữa)
    INSERT INTO STB_VVT_SortingErrorData (
        SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, MaterialType, QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        CreateUserID, CreateDateTime
    )
    SELECT 
        SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, 
        CASE WHEN @pProcessViewName LIKE '%ALCASE%' THEN 'ALCASE' ELSE 'PLATE' END,
        QtyCheck, QtyOK, Remark,
        ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
        PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch, PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood, PLBienSacDiscolor, PLOther,
        @pProcessUserID, GETDATE()
    FROM OPENXML(@iDoc, '/DataSet/SortingData_INSERT', 2) 
    WITH (
        SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
        FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
        ALBuiDust INT, ALMoDent INT, ALBongNBPlating INT, ALMepDeform INT, ALXuocScratch INT, ALSanRoughFace INT, ALBanDirty INT, ALBanBoDentGroup INT, ALBienSacDiscolor INT, ALLoiKhacOther INT,
        PLBuuNhom INT, PLBuuNhua INT, PLBuuRandom INT, PLBongTamNhieu INT, PLXuocScratch INT, PLBienDangDeform INT, PLMoDongExposed INT, PLBienDangCamSu INT, PLNutGoCrackWood INT, PLBienSacDiscolor INT, PLOther INT
    );

    -- Xử lý UPDATE
    UPDATE T SET
        SortingDate = X.SortingDate, Shift = X.Shift, PersonName = X.PersonName, MaterialCode = X.MaterialCode, QtyCheck = X.QtyCheck, QtyOK = X.QtyOK,
        ALBuiDust = X.ALBuiDust, ALMoDent = X.ALMoDent, ALBongNBPlating = X.ALBongNBPlating, 
        PLBuuNhom = X.PLBuuNhom, PLBuuNhua = X.PLBuuNhua, 
        ChangeUserID = @pProcessUserID, ChangeDateTime = GETDATE()
    FROM STB_VVT_SortingErrorData T
    JOIN OPENXML(@iDoc, '/DataSet/SortingData_UPDATE', 2) WITH (
        SortingID INT, SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), MaterialCode VARCHAR(50), QtyCheck INT, QtyOK INT,
        ALBuiDust INT, ALMoDent INT, ALBongNBPlating INT, PLBuuNhom INT, PLBuuNhua INT
    ) X ON T.SortingID = X.SortingID;

    EXEC sp_xml_removedocument @iDoc;
END
GO
