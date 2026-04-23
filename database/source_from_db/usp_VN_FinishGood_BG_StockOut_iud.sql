
CREATE PROCEDURE [dbo].[usp_VN_FinishGood_BG_StockOut_iud]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = NULL,
    @pXml NVARCHAR(MAX) = NULL,
    @pInvoiceNo NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, '');
    DECLARE @ERROR_MSG NVARCHAR(MAX);

    DECLARE @LotNo NVARCHAR(50), @PackQty INT, @Country NVARCHAR(50), @SoPhieuXuatKho NVARCHAR(50);
    DECLARE @SoInVoice NVARCHAR(50), @SoToKhaiHaiQuan NVARCHAR(50), @TYPEEXPORT NVARCHAR(50);
    DECLARE @LevelsOut NVARCHAR(50), @TRANSPORT NVARCHAR(50), @CUSTOMERNAME NVARCHAR(100);
    DECLARE @BoxQuantity INT, @PalletQuantity INT, @Note NVARCHAR(MAX), @IDCODE NVARCHAR(100);

    DECLARE @Total INT = 0;
    DECLARE @TotalPackQty INT;
    DECLARE @iDoc INT;

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY

       -- Lấy TotalPackQty từ view
        SELECT TOP 1 
            @TotalPackQty = TotalPackQty
        FROM OPENXML(@iDoc, @TableName, 2)
        WITH (
            TotalPackQty INT 'TotalPackQty'
        );

      -- Tính tổng số lượng cần xuất trên view
        ;WITH CTE_Sum AS (
            SELECT PackQty 
            FROM OPENXML(@iDoc, @TableName, 2) 
            WITH (PackQty INT 'PackQty')
        )
        SELECT @Total = SUM(ISNULL(PackQty, 0)) 
        FROM CTE_Sum;

        IF ISNULL(@Total, 0) <> ISNULL(@TotalPackQty, 0)
        BEGIN
            DECLARE @Msg NVARCHAR(500) = 
                N'Tổng số lượng trong danh sách (' 
                + CAST(ISNULL(@Total, 0) AS NVARCHAR(20)) 
                + N') không khớp với số lượng yêu cầu (' 
                + CAST(ISNULL(@TotalPackQty, 0) AS NVARCHAR(20)) 
                + N')!';
            RAISERROR(@Msg, 16, 1);
        END

        BEGIN TRANSACTION;

        DECLARE SourceData CURSOR LOCAL FAST_FORWARD FOR
            SELECT LotNo, PackQty, Country, SoPhieuXuatKho, SoInVoice, SoToKhaiHaiQuan, TYPEEXPORT,
                   LevelsOut, TRANSPORT, CUSTOMERNAME, BoxQuantity, PalletQuantity, Note, IDCODE
            FROM OPENXML(@iDoc, @TableName, 2) 
            WITH (
                LotNo NVARCHAR(50), 
                PackQty INT, 
                Country NVARCHAR(50), 
                SoPhieuXuatKho NVARCHAR(50), 
                SoInvoice NVARCHAR(50), 
                SoToKhaiHaiQuan NVARCHAR(50), 
                TYPEEXPORT NVARCHAR(50), 
                LevelsOut NVARCHAR(50), 
                TRANSPORT NVARCHAR(50),
                CUSTOMERNAME NVARCHAR(100), 
                BoxQuantity INT, 
                PalletQuantity INT, 
                Note NVARCHAR(MAX),
                IDCODE NVARCHAR(100)
            );

        OPEN SourceData;

        FETCH NEXT FROM SourceData INTO 
            @LotNo, @PackQty, @Country, @SoPhieuXuatKho, @SoInVoice, 
            @SoToKhaiHaiQuan, @TYPEEXPORT, @LevelsOut, @TRANSPORT, 
            @CUSTOMERNAME, @BoxQuantity, @PalletQuantity, @Note, @IDCODE;

        WHILE @@FETCH_STATUS = 0 
        BEGIN

            IF NOT EXISTS (
                SELECT 1 
                FROM STB_VN_FINISHGOODS_BG_Test_20251225 
                WHERE LotNo = @LotNo AND IDCODE = @IDCODE
            )
            BEGIN
                DECLARE @ErrLot NVARCHAR(200) = 
                    N'Lot ' + ISNULL(@LotNo, N'') + N' không tồn tại, vui lòng kiểm tra lại';
                RAISERROR(@ErrLot, 16, 1);
            END

            UPDATE STB_VN_FINISHGOODS_BG_Test_20251225
            SET
                PackQty = ISNULL(@PackQty, PackQty),
                Country = ISNULL(@Country, Country),
                SoPhieuXuatKho = ISNULL(@SoPhieuXuatKho, SoPhieuXuatKho),
                SoInVoice = ISNULL(@SoInVoice, SoInVoice),
                SoToKhaiHaiQuan = ISNULL(@SoToKhaiHaiQuan, SoToKhaiHaiQuan),
                TYPEEXPORT = ISNULL(@TYPEEXPORT, TYPEEXPORT),
                LevelsOut = ISNULL(@LevelsOut, LevelsOut),
                TRANSPORT = ISNULL(@TRANSPORT, TRANSPORT),
                CUSTOMERNAME = ISNULL(@CUSTOMERNAME, CUSTOMERNAME),
                PersonExport = @pProcessUserID,
                DateExport = GETDATE(),
                MethodActions1 = N'Xuất bằng file excel',
                BoxQuantity = ISNULL(@BoxQuantity, BoxQuantity),
                PalletQuantity = ISNULL(@PalletQuantity, PalletQuantity),
                Note = ISNULL(@Note, Note),
                Statusout = N'Xuất'
            WHERE LotNo = @LotNo
              AND IDCODE = @IDCODE;

            FETCH NEXT FROM SourceData INTO 
                @LotNo, @PackQty, @Country, @SoPhieuXuatKho, @SoInVoice, 
                @SoToKhaiHaiQuan, @TYPEEXPORT, @LevelsOut, @TRANSPORT, 
                @CUSTOMERNAME, @BoxQuantity, @PalletQuantity, @Note, @IDCODE;
        END

        CLOSE SourceData;
        DEALLOCATE SourceData;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        
        IF CURSOR_STATUS('local', 'SourceData') >= 0 
        BEGIN 
            CLOSE SourceData; 
            DEALLOCATE SourceData; 
        END

        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH

    IF @iDoc IS NOT NULL
EXEC sp_xml_removedocument @iDoc;
END
