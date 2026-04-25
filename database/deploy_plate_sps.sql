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
        Dent AS [Mẻ (Dent)],
        Deform AS [Móp (Deform)],
        Scratch AS [Xước (Scratch)],
        NGPlating AS [Bong mạ (NG Plating)],
        RoughFace AS [Sần (Rough face)],
        Dirty AS [Bẩn (Dirty)],
        DentBottom AS [Lõm đáy (Dent Bottom)],
        Discolor AS [Biến sắc (Discolor)],
        OtherError AS [Lỗi khác (Other)],
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
        INSERT INTO STB_VVT_SortingErrorData_Plate (
            SortingDate, [Shift], PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK,
            Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, TotalNG, CreateUserID
        ) VALUES (
            @SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName, @MaterialCode, @LotNo, @QtyCheck, @QtyOK,
            @Burr, @Dent, @Deform, @Scratch, @NGPlating, @RoughFace, @Dirty, @DentBottom, @Discolor, @OtherError, @TotalNG, @CreateUserID
        );
    END
    ELSE IF @IUD_FLAG = 'U'
    BEGIN
        UPDATE STB_VVT_SortingErrorData_Plate SET
            SortingDate = @SortingDate,
            [Shift] = @Shift,
            PersonName = @PersonName,
            VendorCode = @VendorCode,
            FactoryName = @FactoryName,
            MaterialCode = @MaterialCode,
            LotNo = @LotNo,
            QtyCheck = @QtyCheck,
            QtyOK = @QtyOK,
            Burr = @Burr,
            Dent = @Dent,
            Deform = @Deform,
            Scratch = @Scratch,
            NGPlating = @NGPlating,
            RoughFace = @RoughFace,
            Dirty = @Dirty,
            DentBottom = @DentBottom,
            Discolor = @Discolor,
            OtherError = @OtherError,
            TotalNG = @TotalNG
        WHERE PlateErrorNo = @PlateErrorNo;
    END
    ELSE IF @IUD_FLAG = 'D'
    BEGIN
        DELETE FROM STB_VVT_SortingErrorData_Plate WHERE PlateErrorNo = @PlateErrorNo;
    END
END;
GO
