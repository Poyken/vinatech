-- =============================================
-- FINAL DEPLOYMENT FOR SORTING DATA MIGRATION
-- Date: 2026-04-24
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
    [BurrAl] [int] DEFAULT 0,
    [BurrPlastic] [int] DEFAULT 0,
    [BurrRubber] [int] DEFAULT 0,
    [PlasticSheetPeeling] [int] DEFAULT 0,
    [Scratch] [int] DEFAULT 0,
    [Deform] [int] DEFAULT 0,
    [ExposedCopper] [int] DEFAULT 0,
    [RubberDeform] [int] DEFAULT 0,
    [CrackWood] [int] DEFAULT 0,
    [Discoloration] [int] DEFAULT 0,
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
        CONVERT(varchar(10), SortingDate, 23) AS [Date],
        [Shift],
        PersonName AS [Person],
        VendorCode AS [Vendor],
        FactoryName AS [Factory],
        MaterialCode AS [Code Marterial],
        LotNo AS [Lot no],
        QtyCheck AS [Q'Ty Check],
        QtyOK AS [Q'ty OK],
        BurrAl AS [Burr nhôm Burr Al],
        BurrPlastic AS [Burr Nhựa Burr Plastic],
        BurrRubber AS [Burr caosu],
        PlasticSheetPeeling AS [Bong tấm nhựa],
        Scratch AS [Xước Scratch],
        Deform AS [Biến dạng Deform],
        ExposedCopper AS [Hở đồng Exposed copper],
        RubberDeform AS [Biến dạng cao su Deform caosu],
        CrackWood AS [Nứt gỗ Crack Wood],
        Discoloration AS [Biến sắc Discoloration],
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
    @BurrAl int = 0,
    @BurrPlastic int = 0,
    @BurrRubber int = 0,
    @PlasticSheetPeeling int = 0,
    @Scratch int = 0,
    @Deform int = 0,
    @ExposedCopper int = 0,
    @RubberDeform int = 0,
    @CrackWood int = 0,
    @Discoloration int = 0,
    @OtherError int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @BurrAl + @BurrPlastic + @BurrRubber + @PlasticSheetPeeling + @Scratch + @Deform + @ExposedCopper + @RubberDeform + @CrackWood + @Discoloration + @OtherError;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_ALCase (SortingDate, [Shift], PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, BurrAl, BurrPlastic, BurrRubber, PlasticSheetPeeling, Scratch, Deform, ExposedCopper, RubberDeform, CrackWood, Discoloration, OtherError, TotalNG, CreateUserID)
        VALUES (@SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @BurrAl, @BurrPlastic, @BurrRubber, @PlasticSheetPeeling, @Scratch, @Deform, @ExposedCopper, @RubberDeform, @CrackWood, @Discoloration, @OtherError, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_ALCase SET SortingDate=@SortingDate, [Shift]=@Shift, PersonName=@PersonName, VendorCode=@VendorCode, FactoryName=@FactoryName, MaterialCode=@MaterialCode, LotNo=@LotNo, QtyCheck=@QtyCheck, QtyOK=@QtyOK, BurrAl=@BurrAl, BurrPlastic=@BurrPlastic, BurrRubber=@BurrRubber, PlasticSheetPeeling=@PlasticSheetPeeling, Scratch=@Scratch, Deform=@Deform, ExposedCopper=@ExposedCopper, RubberDeform=@RubberDeform, CrackWood=@CrackWood, Discoloration=@Discoloration, OtherError=@OtherError, TotalNG=@TotalNG
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
    [Dent] [int] DEFAULT 0,
    [Deform] [int] DEFAULT 0,
    [Scratch] [int] DEFAULT 0,
    [NGPlating] [int] DEFAULT 0,
    [RoughFace] [int] DEFAULT 0,
    [Dirty] [int] DEFAULT 0,
    [DentBottom] [int] DEFAULT 0,
    [Discolor] [int] DEFAULT 0,
    [OtherError] [int] DEFAULT 0,
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
        CONVERT(varchar(10), SortingDate, 23) AS [Date],
        [Shift],
        PersonName AS [Person],
        VendorCode AS [Vendor],
        FactoryName AS [Factory],
        MaterialCode AS [Marterial],
        LotNo AS [Lot no],
        QtyCheck AS [Q'Ty Check],
        QtyOK AS [Q'ty OK],
        Burr AS [Burr],
        Dent AS [Mẻ Dent],
        Deform AS [Móp Deform],
        Scratch AS [Xước Scratch],
        NGPlating AS [Bong mạ NG Plating],
        RoughFace AS [Sần Rough face],
        Dirty AS [Bẩn Dirty],
        DentBottom AS [Lõm đáy Dent Bottom],
        Discolor AS [Biến sắc Discolor],
        OtherError AS [Lỗi khác Other],
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
    @Dent int = 0,
    @Deform int = 0,
    @Scratch int = 0,
    @NGPlating int = 0,
    @RoughFace int = 0,
    @Dirty int = 0,
    @DentBottom int = 0,
    @Discolor int = 0,
    @OtherError int = 0,
    @CreateUserID nvarchar(50) = NULL
AS
BEGIN
    DECLARE @TotalNG int = @Burr + @Dent + @Deform + @Scratch + @NGPlating + @RoughFace + @Dirty + @DentBottom + @Discolor + @OtherError;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_Plate (SortingDate, [Shift], PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, TotalNG, CreateUserID)
        VALUES (@SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @Burr, @Dent, @Deform, @Scratch, @NGPlating, @RoughFace, @Dirty, @DentBottom, @Discolor, @OtherError, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_Plate SET SortingDate=@SortingDate, [Shift]=@Shift, PersonName=@PersonName, VendorCode=@VendorCode, FactoryName=@FactoryName, MaterialCode=@MaterialCode, LotNo=@LotNo, QtyCheck=@QtyCheck, QtyOK=@QtyOK, Burr=@Burr, Dent=@Dent, Deform=@Deform, Scratch=@Scratch, NGPlating=@NGPlating, RoughFace=@RoughFace, Dirty=@Dirty, DentBottom=@DentBottom, Discolor=@Discolor, OtherError=@OtherError, TotalNG=@TotalNG
        WHERE PlateErrorNo = @PlateErrorNo;
    END
    ELSE IF @IUD_FLAG = 'D'
    BEGIN
        DELETE FROM STB_VVT_SortingErrorData_Plate WHERE PlateErrorNo = @PlateErrorNo;
    END
END;
GO
