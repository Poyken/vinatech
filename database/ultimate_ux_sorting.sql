-- =============================================
-- ULTIMATE UX DEPLOYMENT FOR SORTING (FULL UNICODE SYNC)
-- Date: 2026-04-24
-- Goal: Exact Unicode matching for Auto-Fill and Best User Experience
-- =============================================

-- 1. AL CASE SECTION
-------------------------------------------------
IF OBJECT_ID('STB_VVT_SortingErrorData_ALCase', 'U') IS NOT NULL DROP TABLE STB_VVT_SortingErrorData_ALCase;
GO
CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase] (
    [ALCaseErrorNo] [int] IDENTITY(1,1) NOT NULL,
    [Date] [date] NULL,
    [Shift] [nvarchar](50) NULL,
    [Person] [nvarchar](100) NULL,
    [Vendor] [nvarchar](100) NULL,
    [Factory] [nvarchar](100) NULL,
    [Code Marterial] [nvarchar](100) NULL,
    [Lot no] [nvarchar](100) NULL,
    [Q'Ty Check] [int] NULL,
    [Q'ty OK] [int] NULL,
    [Burr nhôm Burr Al] [int] DEFAULT 0,
    [Burr Nhựa Burr Plastic] [int] DEFAULT 0,
    [Burr caosu] [int] DEFAULT 0,
    [Bong tấm nhựa] [int] DEFAULT 0,
    [Xước Scratch] [int] DEFAULT 0,
    [Biến dạng Deform] [int] DEFAULT 0,
    [Hở đồng Exposed copper] [int] DEFAULT 0,
    [Biến dạng cao su Deform caosu] [int] DEFAULT 0,
    [Nứt gỗ Crack Wood] [int] DEFAULT 0,
    [Biến sắc Discoloration] [int] DEFAULT 0,
    [Other] [int] DEFAULT 0,
    [Total] [int] DEFAULT 0,
    [CreateUserID] [nvarchar](50) NULL,
    [CreateDateTime] [datetime] DEFAULT GETDATE(),
    PRIMARY KEY (ALCaseErrorNo)
);
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_ALCase_get', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_ALCase_get;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_ALCase_get]
    @FromDate nvarchar(10) = NULL,
    @ToDate nvarchar(10) = NULL,
    @MaterialCode nvarchar(50) = NULL
AS
BEGIN
    SELECT 
        ALCaseErrorNo,
        CONVERT(varchar(10), [Date], 23) AS [Date],
        [Shift], [Person], [Vendor], [Factory], [Code Marterial], [Lot no], [Q'Ty Check], [Q'ty OK],
        [Burr nhôm Burr Al], [Burr Nhựa Burr Plastic], [Burr caosu], [Bong tấm nhựa], [Xước Scratch], [Biến dạng Deform], [Hở đồng Exposed copper], [Biến dạng cao su Deform caosu], [Nứt gỗ Crack Wood], [Biến sắc Discoloration], [Other], [Total]
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@FromDate IS NULL OR [Date] >= @FromDate)
      AND (@ToDate IS NULL OR [Date] <= @ToDate)
      AND (@MaterialCode IS NULL OR [Code Marterial] LIKE '%' + @MaterialCode + '%')
    ORDER BY [Date] DESC, ALCaseErrorNo DESC;
END;
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_ALCase_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_ALCase_iud;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @IUD_FLAG nvarchar(10),
    @ALCaseErrorNo int = NULL,
    @Date date = NULL,
    @Shift nvarchar(50) = NULL,
    @Person nvarchar(100) = NULL,
    @Vendor nvarchar(100) = NULL,
    @Factory nvarchar(100) = NULL,
    @Code_Marterial nvarchar(100) = NULL,
    @Lot_no nvarchar(100) = NULL,
    @Qty_Check int = 0,
    @Qty_OK int = 0,
    @Burr_Al int = 0,
    @Burr_Plastic int = 0,
    @Burr_Caosu int = 0,
    @Bong_Tam_Nhua int = 0,
    @Xuoc_Scratch int = 0,
    @Deform int = 0,
    @Exposed_Copper int = 0,
    @Rubber_Deform int = 0,
    @Crack_Wood int = 0,
    @Discoloration int = 0,
    @Other int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @Burr_Al + @Burr_Plastic + @Burr_Caosu + @Bong_Tam_Nhua + @Xuoc_Scratch + @Deform + @Exposed_Copper + @Rubber_Deform + @Crack_Wood + @Discoloration + @Other;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_ALCase ([Date], [Shift], [Person], [Vendor], [Factory], [Code Marterial], [Lot no], [Q'Ty Check], [Q'ty OK], [Burr nhôm Burr Al], [Burr Nhựa Burr Plastic], [Burr caosu], [Bong tấm nhựa], [Xước Scratch], [Biến dạng Deform], [Hở đồng Exposed copper], [Biến dạng cao su Deform caosu], [Nứt gỗ Crack Wood], [Biến sắc Discoloration], [Other], [Total], [CreateUserID])
        VALUES (@Date, @Shift, @Person, @Vendor, @Factory, @Code_Marterial, @Lot_no, @Qty_Check, @Qty_OK, @Burr_Al, @Burr_Plastic, @Burr_Caosu, @Bong_Tam_Nhua, @Xuoc_Scratch, @Deform, @Exposed_Copper, @Rubber_Deform, @Crack_Wood, @Discoloration, @Other, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_ALCase SET [Date]=@Date, [Shift]=@Shift, [Person]=@Person, [Vendor]=@Vendor, [Factory]=@Factory, [Code Marterial]=@Code_Marterial, [Lot no]=@Lot_no, [Q'Ty Check]=@Qty_Check, [Q'ty OK]=@Qty_OK, [Burr nhôm Burr Al]=@Burr_Al, [Burr Nhựa Burr Plastic]=@Burr_Plastic, [Burr caosu]=@Burr_Caosu, [Bong tấm nhựa]=@Bong_Tam_Nhua, [Xước Scratch]=@Xuoc_Scratch, [Biến dạng Deform]=@Deform, [Hở đồng Exposed copper]=@Exposed_Copper, [Biến dạng cao su Deform caosu]=@Rubber_Deform, [Nứt gỗ Crack Wood]=@Crack_Wood, [Biến sắc Discoloration]=@Discoloration, [Other]=@Other, [Total]=@TotalNG
        WHERE ALCaseErrorNo = @ALCaseErrorNo;
    END
    ELSE IF @IUD_FLAG = 'D'
    BEGIN
        DELETE FROM STB_VVT_SortingErrorData_ALCase WHERE ALCaseErrorNo = @ALCaseErrorNo;
    END
END;
GO

-- 2. PLATE SECTION
-------------------------------------------------
IF OBJECT_ID('STB_VVT_SortingErrorData_Plate', 'U') IS NOT NULL DROP TABLE STB_VVT_SortingErrorData_Plate;
GO
CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate] (
    [PlateErrorNo] [int] IDENTITY(1,1) NOT NULL,
    [Date] [date] NULL,
    [Shift] [nvarchar](50) NULL,
    [Person] [nvarchar](100) NULL,
    [Vendor] [nvarchar](100) NULL,
    [Factory] [nvarchar](100) NULL,
    [Marterial] [nvarchar](100) NULL,
    [Lot no] [nvarchar](100) NULL,
    [Q'Ty Check] [int] NULL,
    [Q'ty OK] [int] NULL,
    [Burr] [int] DEFAULT 0,
    [Mẻ Dent] [int] DEFAULT 0,
    [Móp Deform] [int] DEFAULT 0,
    [Xước Scratch] [int] DEFAULT 0,
    [Bong mạ NG Plating] [int] DEFAULT 0,
    [Sần Rough face] [int] DEFAULT 0,
    [Bẩn Dirty] [int] DEFAULT 0,
    [Lõm đáy Dent Bottom] [int] DEFAULT 0,
    [Biến sắc Discolor] [int] DEFAULT 0,
    [Lỗi khác Other] [int] DEFAULT 0,
    [Total] [int] DEFAULT 0,
    [CreateUserID] [nvarchar](50) NULL,
    [CreateDateTime] [datetime] DEFAULT GETDATE(),
    PRIMARY KEY (PlateErrorNo)
);
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_get', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_get;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @FromDate nvarchar(10) = NULL,
    @ToDate nvarchar(10) = NULL,
    @MaterialCode nvarchar(50) = NULL
AS
BEGIN
    SELECT 
        PlateErrorNo,
        CONVERT(varchar(10), [Date], 23) AS [Date],
        [Shift], [Person], [Vendor], [Factory], [Marterial], [Lot no], [Q'Ty Check], [Q'ty OK],
        [Burr], [Mẻ Dent], [Móp Deform], [Xước Scratch], [Bong mạ NG Plating], [Sần Rough face], [Bẩn Dirty], [Lõm đáy Dent Bottom], [Biến sắc Discolor], [Lỗi khác Other], [Total]
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@FromDate IS NULL OR [Date] >= @FromDate)
      AND (@ToDate IS NULL OR [Date] <= @ToDate)
      AND (@MaterialCode IS NULL OR [Marterial] LIKE '%' + @MaterialCode + '%')
    ORDER BY [Date] DESC, PlateErrorNo DESC;
END;
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_iud;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @IUD_FLAG nvarchar(10),
    @PlateErrorNo int = NULL,
    @Date date = NULL,
    @Shift nvarchar(50) = NULL,
    @Person nvarchar(100) = NULL,
    @Vendor nvarchar(100) = NULL,
    @Factory nvarchar(100) = NULL,
    @Marterial nvarchar(100) = NULL,
    @Lot_no nvarchar(100) = NULL,
    @Qty_Check int = 0,
    @Qty_OK int = 0,
    @Burr int = 0,
    @Me_Dent int = 0,
    @Mop_Deform int = 0,
    @Xuoc_Scratch int = 0,
    @NG_Plating int = 0,
    @Rough_Face int = 0,
    @Dirty int = 0,
    @Dent_Bottom int = 0,
    @Discolor int = 0,
    @Other int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @Burr + @Me_Dent + @Mop_Deform + @Xuoc_Scratch + @NG_Plating + @Rough_Face + @Dirty + @Dent_Bottom + @Discolor + @Other;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_Plate ([Date], [Shift], [Person], [Vendor], [Factory], [Marterial], [Lot no], [Q'Ty Check], [Q'ty OK], [Burr], [Mẻ Dent], [Móp Deform], [Xước Scratch], [Bong mạ NG Plating], [Sần Rough face], [Bẩn Dirty], [Lõm đáy Dent Bottom], [Biến sắc Discolor], [Lỗi khác Other], [Total], [CreateUserID])
        VALUES (@Date, @Shift, @Person, @Vendor, @Factory, @Marterial, @Lot_no, @Qty_Check, @Qty_OK, @Burr, @Me_Dent, @Mop_Deform, @Xuoc_Scratch, @NG_Plating, @Rough_Face, @Dirty, @Dent_Bottom, @Discolor, @Other, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_Plate SET [Date]=@Date, [Shift]=@Shift, [Person]=@Person, [Vendor]=@Vendor, [Factory]=@Factory, [Marterial]=@Marterial, [Lot no]=@Lot_no, [Q'Ty Check]=@Qty_Check, [Q'ty OK]=@Qty_OK, [Burr]=@Burr, [Mẻ Dent]=@Me_Dent, [Móp Deform]=@Mop_Deform, [Xước Scratch]=@Xuoc_Scratch, [Bong mạ NG Plating]=@NG_Plating, [Sần Rough face]=@Rough_Face, [Bẩn Dirty]=@Dirty, [Lõm đáy Dent Bottom]=@Dent_Bottom, [Biến sắc Discolor]=@Discolor, [Lỗi khác Other]=@Other, [Total]=@TotalNG
        WHERE PlateErrorNo = @PlateErrorNo;
    END
    ELSE IF @IUD_FLAG = 'D'
    BEGIN
        DELETE FROM STB_VVT_SortingErrorData_Plate WHERE PlateErrorNo = @PlateErrorNo;
    END
END;
GO
