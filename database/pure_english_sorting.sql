-- =============================================
-- PURE ENGLISH DEPLOYMENT (NO VIETNAMESE, NO EXTRA COLUMNS)
-- Date: 2026-04-24
-- Goal: Clean English schema, zero extra columns, zero Vietnamese aliases.
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
    [MaterialCode] [nvarchar](100) NULL,
    [LotNo] [nvarchar](100) NULL,
    [QtyCheck] [int] NULL,
    [QtyOK] [int] NULL,
    [BurrAl] [int] DEFAULT 0,
    [BurrPlastic] [int] DEFAULT 0,
    [BurrRubber] [int] DEFAULT 0,
    [PlasticPeeling] [int] DEFAULT 0,
    [Scratch] [int] DEFAULT 0,
    [Deform] [int] DEFAULT 0,
    [ExposedCopper] [int] DEFAULT 0,
    [RubberDeform] [int] DEFAULT 0,
    [CrackWood] [int] DEFAULT 0,
    [Discoloration] [int] DEFAULT 0,
    [OtherError] [int] DEFAULT 0,
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
        ALCaseErrorNo, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, LotNo, QtyCheck, QtyOK,
        BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, RubberDeform, CrackWood, Discoloration, OtherError, [Total]
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@FromDate IS NULL OR [Date] >= @FromDate)
      AND (@ToDate IS NULL OR [Date] <= @ToDate)
      AND (@MaterialCode IS NULL OR MaterialCode LIKE '%' + @MaterialCode + '%')
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
    @MaterialCode nvarchar(100) = NULL,
    @LotNo nvarchar(100) = NULL,
    @QtyCheck int = 0,
    @QtyOK int = 0,
    @BurrAl int = 0,
    @BurrPlastic int = 0,
    @BurrRubber int = 0,
    @PlasticPeeling int = 0,
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
    DECLARE @TotalNG int = @BurrAl + @BurrPlastic + @BurrRubber + @PlasticPeeling + @Scratch + @Deform + @ExposedCopper + @RubberDeform + @CrackWood + @Discoloration + @OtherError;
    IF @IUD_FLAG = 'I'
    BEGIN
        INSERT INTO STB_VVT_SortingErrorData_ALCase ([Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, [QtyCheck], [QtyOK], BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, RubberDeform, CrackWood, Discoloration, OtherError, Total, CreateUserID)
        VALUES (@Date, @Shift, @Person, @Vendor, @Factory, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @BurrAl, @BurrPlastic, @BurrRubber, @PlasticPeeling, @Scratch, @Deform, @ExposedCopper, @RubberDeform, @CrackWood, @Discoloration, @OtherError, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_ALCase SET [Date]=@Date, [Shift]=@Shift, Person=@Person, Vendor=@Vendor, Factory=@Factory, MaterialCode=@MaterialCode, LotNo=@LotNo, [QtyCheck]=@QtyCheck, [QtyOK]=@QtyOK, BurrAl=@BurrAl, BurrPlastic=@BurrPlastic, BurrRubber=@BurrRubber, PlasticPeeling=@PlasticPeeling, Scratch=@Scratch, Deform=@Deform, ExposedCopper=@ExposedCopper, RubberDeform=@RubberDeform, CrackWood=@CrackWood, Discoloration=@Discoloration, OtherError=@OtherError, Total=@TotalNG
        WHERE ALCaseErrorNo = @ALCaseErrorNo;
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
        PlateErrorNo, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, LotNo, QtyCheck, QtyOK,
        Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, [Total]
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@FromDate IS NULL OR [Date] >= @FromDate)
      AND (@ToDate IS NULL OR [Date] <= @ToDate)
      AND (@MaterialCode IS NULL OR MaterialCode LIKE '%' + @MaterialCode + '%')
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
        INSERT INTO STB_VVT_SortingErrorData_Plate ([Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, QtyCheck, QtyOK, Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total, CreateUserID)
        VALUES (@Date, @Shift, @Person, @Vendor, @Factory, @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @Burr, @Dent, @Deform, @Scratch, @NGPlating, @RoughFace, @Dirty, @DentBottom, @Discolor, @OtherError, @TotalNG, @CreateUserID);
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_Plate SET [Date]=@Date, [Shift]=@Shift, Person=@Person, Vendor=@Vendor, Factory=@Factory, MaterialCode=@MaterialCode, LotNo=@LotNo, QtyCheck=@QtyCheck, QtyOK=@QtyOK, Burr=@Burr, Dent=@Dent, Deform=@Deform, Scratch=@Scratch, NGPlating=@NGPlating, RoughFace=@RoughFace, Dirty=@Dirty, DentBottom=@DentBottom, Discolor=@Discolor, OtherError=@OtherError, Total=@TotalNG
        WHERE PlateErrorNo = @PlateErrorNo;
    END
END;
GO
