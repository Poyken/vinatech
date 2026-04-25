-- =============================================
-- SMART MATCH DEPLOYMENT FOR SORTING (NO ACCENTS)
-- Date: 2026-04-24
-- Goal: Use friendly no-accent names for perfect matching and stability
-- =============================================

-- 1. AL CASE SECTION
-------------------------------------------------
IF OBJECT_ID('STB_VVT_SortingErrorData_ALCase', 'U') IS NOT NULL DROP TABLE STB_VVT_SortingErrorData_ALCase;
GO
CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase] (
    [ALCaseErrorNo] [int] IDENTITY(1,1) NOT NULL,
    [SortingDate] [date] NULL,
    [Shift] [nvarchar](50) NULL,
    [PersonName] [nvarchar](100) NULL,
    [VendorCode] [nvarchar](100) NULL,
    [FactoryName] [nvarchar](100) NULL,
    [MaterialCode] [nvarchar](100) NULL,
    [LotNo] [nvarchar](100) NULL,
    [QtyCheck] [int] NULL,
    [QtyOK] [int] NULL,
    [Burr_Nhom_Burr_Al] [int] DEFAULT 0,
    [Burr_Nhua_Burr_Plastic] [int] DEFAULT 0,
    [Burr_Caosu] [int] DEFAULT 0,
    [Bong_Tam_Nhua] [int] DEFAULT 0,
    [Xuoc_Scratch] [int] DEFAULT 0,
    [Bien_Dang_Deform] [int] DEFAULT 0,
    [Ho_Dong_Exposed_Copper] [int] DEFAULT 0,
    [Bien_Dang_Cao_Su_Deform_Caosu] [int] DEFAULT 0,
    [Nut_Go_Crack_Wood] [int] DEFAULT 0,
    [Bien_Sac_Discoloration] [int] DEFAULT 0,
    [OtherError] [int] DEFAULT 0,
    [TotalNG] [int] DEFAULT 0,
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
        CONVERT(varchar(10), SortingDate, 23) AS [Sorting Date],
        [Shift],
        PersonName AS [Person],
        VendorCode AS [Vendor],
        FactoryName AS [Factory],
        MaterialCode AS [Code Marterial],
        LotNo AS [Lot no],
        QtyCheck AS [Q'Ty Check],
        QtyOK AS [Q'ty OK],
        Burr_Nhom_Burr_Al AS [Burr nhôm Burr Al],
        Burr_Nhua_Burr_Plastic AS [Burr Nhựa Burr Plastic],
        Burr_Caosu AS [Burr caosu],
        Bong_Tam_Nhua AS [Bong tấm nhựa],
        Xuoc_Scratch AS [Xước Scratch],
        Bien_Dang_Deform AS [Biến dạng Deform],
        Ho_Dong_Exposed_Copper AS [Hở đồng Exposed copper],
        Bien_Dang_Cao_Su_Deform_Caosu AS [Biến dạng cao su Deform caosu],
        Nut_Go_Crack_Wood AS [Nứt gỗ Crack Wood],
        Bien_Sac_Discoloration AS [Biến sắc Discoloration],
        OtherError AS [Other],
        TotalNG AS [Total]
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@FromDate IS NULL OR SortingDate >= @FromDate)
      AND (@ToDate IS NULL OR SortingDate <= @ToDate)
      AND (@MaterialCode IS NULL OR MaterialCode LIKE '%' + @MaterialCode + '%')
    ORDER BY SortingDate DESC, ALCaseErrorNo DESC;
END;
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_ALCase_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_ALCase_iud;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @IUD_FLAG nvarchar(10),
    @ALCaseErrorNo int = NULL,
    @SortingDate date = NULL,
    @Shift nvarchar(50) = NULL,
    @PersonName nvarchar(100) = NULL,
    @VendorCode nvarchar(100) = NULL,
    @FactoryName nvarchar(100) = NULL,
    @MaterialCode nvarchar(100) = NULL,
    @LotNo nvarchar(100) = NULL,
    @QtyCheck int = 0,
    @QtyOK int = 0,
    @Burr_Nhom_Burr_Al int = 0,
    @Burr_Nhua_Burr_Plastic int = 0,
    @Burr_Caosu int = 0,
    @Bong_Tam_Nhua int = 0,
    @Xuoc_Scratch int = 0,
    @Bien_Dang_Deform int = 0,
    @Ho_Dong_Exposed_Copper int = 0,
    @Bien_Dang_Cao_Su_Deform_Caosu int = 0,
    @Nut_Go_Crack_Wood int = 0,
    @Bien_Sac_Discoloration int = 0,
    @OtherError int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @Burr_Nhom_Burr_Al + @Burr_Nhua_Burr_Plastic + @Burr_Caosu + @Bong_Tam_Nhua + @Xuoc_Scratch + @Bien_Dang_Deform + @Ho_Dong_Exposed_Copper + @Bien_Dang_Cao_Su_Deform_Caosu + @Nut_Go_Crack_Wood + @Bien_Sac_Discoloration + @OtherError;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_ALCase (SortingDate, [Shift], PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Burr_Nhom_Burr_Al, Burr_Nhua_Burr_Plastic, Burr_Caosu, Bong_Tam_Nhua, Xuoc_Scratch, Bien_Dang_Deform, Ho_Dong_Exposed_Copper, Bien_Dang_Cao_Su_Deform_Caosu, Nut_Go_Crack_Wood, Bien_Sac_Discoloration, OtherError, TotalNG, CreateUserID)
        VALUES (@SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @Burr_Nhom_Burr_Al, @Burr_Nhua_Burr_Plastic, @Burr_Caosu, @Bong_Tam_Nhua, @Xuoc_Scratch, @Bien_Dang_Deform, @Ho_Dong_Exposed_Copper, @Bien_Dang_Cao_Su_Deform_Caosu, @Nut_Go_Crack_Wood, @Bien_Sac_Discoloration, @OtherError, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_ALCase SET SortingDate=@SortingDate, [Shift]=@Shift, PersonName=@PersonName, VendorCode=@VendorCode, FactoryName=@FactoryName, MaterialCode=@MaterialCode, LotNo=@LotNo, QtyCheck=@QtyCheck, QtyOK=@QtyOK, Burr_Nhom_Burr_Al=@Burr_Nhom_Burr_Al, Burr_Nhua_Burr_Plastic=@Burr_Nhua_Burr_Plastic, Burr_Caosu=@Burr_Caosu, Bong_Tam_Nhua=@Bong_Tam_Nhua, Xuoc_Scratch=@Xuoc_Scratch, Bien_Dang_Deform=@Bien_Dang_Deform, Ho_Dong_Exposed_Copper=@Ho_Dong_Exposed_Copper, Bien_Dang_Cao_Su_Deform_Caosu=@Bien_Dang_Cao_Su_Deform_Caosu, Nut_Go_Crack_Wood=@Nut_Go_Crack_Wood, Bien_Sac_Discoloration=@Bien_Sac_Discoloration, OtherError=@OtherError, TotalNG=@TotalNG
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
    [SortingDate] [date] NULL,
    [Shift] [nvarchar](50) NULL,
    [PersonName] [nvarchar](100) NULL,
    [VendorCode] [nvarchar](100) NULL,
    [FactoryName] [nvarchar](100) NULL,
    [MaterialCode] [nvarchar](100) NULL,
    [LotNo] [nvarchar](100) NULL,
    [QtyCheck] [int] NULL,
    [QtyOK] [int] NULL,
    [Burr] [int] DEFAULT 0,
    [Me_Dent] [int] DEFAULT 0,
    [Mop_Deform] [int] DEFAULT 0,
    [Xuoc_Scratch] [int] DEFAULT 0,
    [Bong_Ma_NG_Plating] [int] DEFAULT 0,
    [San_Rough_Face] [int] DEFAULT 0,
    [Ban_Dirty] [int] DEFAULT 0,
    [Lom_Day_Dent_Bottom] [int] DEFAULT 0,
    [Bien_Sac_Discolor] [int] DEFAULT 0,
    [Loi_khac_Other] [int] DEFAULT 0,
    [TotalNG] [int] DEFAULT 0,
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
        CONVERT(varchar(10), SortingDate, 23) AS [Sorting Date],
        [Shift],
        PersonName AS [Person],
        VendorCode AS [Vendor],
        FactoryName AS [Factory],
        MaterialCode AS [Marterial],
        LotNo AS [Lot no],
        QtyCheck AS [Q'Ty Check],
        QtyOK AS [Q'ty OK],
        Burr AS [Burr],
        Me_Dent AS [Mẻ Dent],
        Mop_Deform AS [Móp Deform],
        Xuoc_Scratch AS [Xước Scratch],
        Bong_Ma_NG_Plating AS [Bong mạ NG Plating],
        San_Rough_Face AS [Sần Rough face],
        Ban_Dirty AS [Bẩn Dirty],
        Lom_Day_Dent_Bottom AS [Lõm đáy Dent Bottom],
        Bien_Sac_Discolor AS [Biến sắc Discolor],
        Loi_khac_Other AS [Lỗi khác Other],
        TotalNG AS [Total]
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@FromDate IS NULL OR SortingDate >= @FromDate)
      AND (@ToDate IS NULL OR SortingDate <= @ToDate)
      AND (@MaterialCode IS NULL OR MaterialCode LIKE '%' + @MaterialCode + '%')
    ORDER BY SortingDate DESC, PlateErrorNo DESC;
END;
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_iud;
GO
CREATE PROC [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @IUD_FLAG nvarchar(10),
    @PlateErrorNo int = NULL,
    @SortingDate date = NULL,
    @Shift nvarchar(50) = NULL,
    @PersonName nvarchar(100) = NULL,
    @VendorCode nvarchar(100) = NULL,
    @FactoryName nvarchar(100) = NULL,
    @MaterialCode nvarchar(100) = NULL,
    @LotNo nvarchar(100) = NULL,
    @QtyCheck int = 0,
    @QtyOK int = 0,
    @Burr int = 0,
    @Me_Dent int = 0,
    @Mop_Deform int = 0,
    @Xuoc_Scratch int = 0,
    @Bong_Ma_NG_Plating int = 0,
    @San_Rough_Face int = 0,
    @Ban_Dirty int = 0,
    @Lom_Day_Dent_Bottom int = 0,
    @Bien_Sac_Discolor int = 0,
    @Loi_khac_Other int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @Burr + @Me_Dent + @Mop_Deform + @Xuoc_Scratch + @Bong_Ma_NG_Plating + @San_Rough_Face + @Ban_Dirty + @Lom_Day_Dent_Bottom + @Bien_Sac_Discolor + @Loi_khac_Other;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_Plate (SortingDate, [Shift], PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Burr, Me_Dent, Mop_Deform, Xuoc_Scratch, Bong_Ma_NG_Plating, San_Rough_Face, Ban_Dirty, Lom_Day_Dent_Bottom, Bien_Sac_Discolor, Loi_khac_Other, TotalNG, CreateUserID)
        VALUES (@SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @Burr, @Me_Dent, @Mop_Deform, @Xuoc_Scratch, @Bong_Ma_NG_Plating, @San_Rough_Face, @Ban_Dirty, @Lom_Day_Dent_Bottom, @Bien_Sac_Discolor, @Loi_khac_Other, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_Plate SET SortingDate=@SortingDate, [Shift]=@Shift, PersonName=@PersonName, VendorCode=@VendorCode, FactoryName=@FactoryName, MaterialCode=@MaterialCode, LotNo=@LotNo, QtyCheck=@QtyCheck, QtyOK=@QtyOK, Burr=@Burr, Me_Dent=@Me_Dent, Mop_Deform=@Mop_Deform, Xuoc_Scratch=@Xuoc_Scratch, Bong_Ma_NG_Plating=@Bong_Ma_NG_Plating, San_Rough_Face=@San_Rough_Face, Ban_Dirty=@Ban_Dirty, Lom_Day_Dent_Bottom=@Lom_Day_Dent_Bottom, Bien_Sac_Discolor=@Bien_Sac_Discolor, Loi_khac_Other=@Loi_khac_Other, TotalNG=@TotalNG
        WHERE PlateErrorNo = @PlateErrorNo;
    END
    ELSE IF @IUD_FLAG = 'D'
    BEGIN
        DELETE FROM STB_VVT_SortingErrorData_Plate WHERE PlateErrorNo = @PlateErrorNo;
    END
END;
GO
