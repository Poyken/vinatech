
CREATE PROCEDURE [dbo].[usp_VN_FinishGood_BG_ImportExcel_uid]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50) = null,
    @pXml NVARCHAR(MAX) = null
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT';
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE';
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE';
    
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @IUD_FLAG VARCHAR(10);
    DECLARE @iDoc INT;

    DECLARE @IDCODE NVARCHAR(100);
    DECLARE @PackingID NVARCHAR(50);
    DECLARE @LotNo NVARCHAR(50);
    DECLARE @MaterialCode NVARCHAR(50);
    DECLARE @MaterialName NVARCHAR(100);
    DECLARE @PackQty INT;
    DECLARE @EmpNo NVARCHAR(50);
    DECLARE @CreatDatePacked NVARCHAR(50);
    DECLARE @PartNo NVARCHAR(50);
    DECLARE @PublicCode NVARCHAR(50);
    DECLARE @ProductionSize NVARCHAR(50);
    DECLARE @TypeProduction NVARCHAR(50);
    DECLARE @StatusSystem NVARCHAR(50);
    DECLARE @CreateDate DATETIME;
    DECLARE @USERID NVARCHAR(50);
    DECLARE @CreateDateChange DATETIME;
    DECLARE @USERIDChange NVARCHAR(50);
    DECLARE @INPUTFROM NVARCHAR(100);
    DECLARE @CODELOCATION NVARCHAR(10);
    DECLARE @Levels NVARCHAR(50);
    DECLARE @SoPhieuNhapKho NVARCHAR(50);

    DECLARE @ListError NVARCHAR(MAX) = '';
    DECLARE @CountSuccess INT = 0;

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        DECLARE SourceData CURSOR FOR
            -- Lấy dữ liệu INSERT
            SELECT 'INSERT' AS IUD_FLAG,
                   IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo,
                   CreatDatePacked, PartNo, PublicCode, ProductionSize, TypeProduction,
                   StatusSystem, CreateDate, USERID, CreateDateChange, USERIDChange, INPUTFROM, CODELOCATION,Levels,SoPhieuNhapKho
            FROM OPENXML(@idoc , @InsertTableName , 2)
            WITH (
                IDCODE NVARCHAR(100), PackingID NVARCHAR(50), LotNo NVARCHAR(50), MaterialCode NVARCHAR(50), 
                MaterialName NVARCHAR(100), PackQty INT, EmpNo NVARCHAR(50), CreatDatePacked NVARCHAR(50), 
                PartNo NVARCHAR(50), PublicCode NVARCHAR(50), ProductionSize NVARCHAR(50), TypeProduction NVARCHAR(50), 
                StatusSystem NVARCHAR(50), CreateDate DATETIME, USERID NVARCHAR(50), CreateDateChange DATETIME, 
                USERIDChange NVARCHAR(50), INPUTFROM NVARCHAR(100), CODELOCATION NVARCHAR(10), Levels NVARCHAR(50),
                SoPhieuNhapKho NVARCHAR(50)
            )
            UNION ALL
            -- Lấy dữ liệu UPDATE
            SELECT 'UPDATE' AS IUD_FLAG,
                   IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo,
                   CreatDatePacked, PartNo, PublicCode, ProductionSize, TypeProduction,
                   StatusSystem, CreateDate, USERID, CreateDateChange, USERIDChange, INPUTFROM, CODELOCATION,Levels,
                   SoPhieuNhapKho
            FROM OPENXML(@idoc , @UpdateTableName , 2)
            WITH (
                IDCODE NVARCHAR(100), PackingID NVARCHAR(50), LotNo NVARCHAR(50), MaterialCode NVARCHAR(50), 
                MaterialName NVARCHAR(100), PackQty INT, EmpNo NVARCHAR(50), CreatDatePacked NVARCHAR(50), 
                PartNo NVARCHAR(50), PublicCode NVARCHAR(50), ProductionSize NVARCHAR(50), TypeProduction NVARCHAR(50), 
                StatusSystem NVARCHAR(50), CreateDate DATETIME, USERID NVARCHAR(50), CreateDateChange DATETIME, 
                USERIDChange NVARCHAR(50), INPUTFROM NVARCHAR(100), CODELOCATION NVARCHAR(10),Levels NVARCHAR(50),
                SoPhieuNhapKho NVARCHAR(50)
            )
            UNION ALL
            -- Lấy dữ liệu DELETE
            SELECT 'DELETE' AS IUD_FLAG,
                   IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo,
                   CreatDatePacked, PartNo, PublicCode, ProductionSize, TypeProduction,
                   StatusSystem, CreateDate, USERID, CreateDateChange, USERIDChange, INPUTFROM, CODELOCATION,Levels,
                   SoPhieuNhapKho
            FROM OPENXML(@idoc , @DeleteTableName , 2)
            WITH (
                IDCODE NVARCHAR(100), PackingID NVARCHAR(50), LotNo NVARCHAR(50), MaterialCode NVARCHAR(50), 
                MaterialName NVARCHAR(100), PackQty INT, EmpNo NVARCHAR(50), CreatDatePacked NVARCHAR(50), 
                PartNo NVARCHAR(50), PublicCode NVARCHAR(50), ProductionSize NVARCHAR(50), TypeProduction NVARCHAR(50), 
                StatusSystem NVARCHAR(50), CreateDate DATETIME, USERID NVARCHAR(50), CreateDateChange DATETIME, 
                USERIDChange NVARCHAR(50), INPUTFROM NVARCHAR(100), CODELOCATION NVARCHAR(10),Levels NVARCHAR(50),
                SoPhieuNhapKho NVARCHAR(50)
            );

        OPEN SourceData;
        
        WHILE 1 = 1 
        BEGIN
            FETCH NEXT FROM SourceData INTO
                @IUD_FLAG, @IDCODE, @PackingID, @LotNo, @MaterialCode, @MaterialName, @PackQty, @EmpNo,
                @CreatDatePacked, @PartNo, @PublicCode, @ProductionSize, @TypeProduction,
                @StatusSystem, @CreateDate, @USERID, @CreateDateChange, @USERIDChange, @INPUTFROM, @CODELOCATION, @Levels,@SoPhieuNhapKho;
               
            IF @@FETCH_STATUS <> 0 BREAK;

            -- Reset biến
            SET @PackingID = NULL;
            SET @MaterialName = NULL;
            SET @MaterialCode = NULL;
            SET @ProductionSize = NULL;
            SET @TypeProduction = NULL;

            -- Logic xác định Type
            IF LEFT(@LotNo, 1) = 'M' SET @TypeProduction = N'Hàng Module' ELSE SET @TypeProduction = N'Hàng Cell';

            -- Lấy PackingID
            SELECT TOP 1 @PackingID = PackingID 
            FROM STB_SavePackingTime_VVT 
            WHERE LotNo = @LotNo AND isPrinted = 1;

            -- Lấy Material Info
            SELECT TOP 1 
                @MaterialName = MM.MaterialName, 
                @MaterialCode = MM.MaterialCode, 
                @ProductionSize = CASE 
                    WHEN CHARINDEX('(', MM.MaterialName) > 0 AND CHARINDEX(')', MM.MaterialName) > CHARINDEX('(', MM.MaterialName)
                    THEN SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName) + 1, CHARINDEX(')', MM.MaterialName) - CHARINDEX('(', MM.MaterialName) - 1)
                    ELSE NULL
                END
            FROM STB_MaterialMaster MM
            INNER JOIN Stb_SetInfo SI ON MM.MaterialCode = SI.MaterialCode
            WHERE SI.Barcode = @LotNo;

            ------------------- INSERT -------------------
            IF @IUD_FLAG = 'INSERT' 


            BEGIN
                --IF EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @LotNo)
                --BEGIN
                --    UPDATE STB_VN_FINISHGOODS_BG_Test_20251225
                --SET
                --    PackingID       = ISNULL(@PackingID, PackingID),
                --    MaterialCode    = ISNULL(@MaterialCode, MaterialCode),
                --    MaterialName    = ISNULL(@MaterialName, MaterialName),
                --    PackQty         = ISNULL(@PackQty, PackQty),
                --    PartNo          = ISNULL(@PartNo, PartNo),
                --    PublicCode      = ISNULL(@PublicCode, PublicCode),
                --    ProductionSize  = ISNULL(@ProductionSize, ProductionSize),
                --    TypeProduction  = ISNULL(@TypeProduction, TypeProduction),
                --    SoPhieuNhapKho  = ISNULL(@SoPhieuNhapKho, SoPhieuNhapKho),
                --    Levels = ISNULL(@Levels,Levels),
                --    CreateDateChange = GETDATE(),
                --    USERIDChange    = @pProcessUserID
                --WHERE LotNo = @LotNo;
                --SET @ListError = @ListError + N'Lot đã được nhập kho';
                --    CONTINUE;
                --END

                DECLARE @CheckPartNo NVARCHAR(50) = NULL;
                SELECT @CheckPartNo =  REPLACE(LEFT(MaterialName, CHARINDEX('(', MaterialName + '(') - 1), ' ', '') from Stb_MaterialMaster where MaterialCode = (select MaterialCode FROM STB_SetInfo WHERE Barcode = @LotNo);
                
                IF (REPLACE(LEFT(@PartNo, CHARINDEX('(', @PartNo + '(') - 1), ' ', '') <> ISNULL(@CheckPartNo, ''))
                BEGIN
                    SET @ListError = @ListError + N'[' + @LotNo + N']: PartNo không khớp (' + @PartNo + N' vs ' + ISNULL(@CheckPartNo, 'NULL') + '); ';
                    CONTINUE;
                END

                EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_BG_Test_20251225', @IDCODE OUTPUT;
                SET @IDCODE = 'FGVN_BG' + @IDCODE;

                INSERT INTO STB_VN_FINISHGOODS_BG_Test_20251225 (
                    IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo,
                    CreatDatePacked, PartNo, PublicCode, ProductionSize, TypeProduction,
                    StatusSystem, CreateDate, USERID, CreateDateChange, USERIDChange, 
                    INPUTFROM, CODELOCATION, Flag, MethodActions, Levels, SoPhieuNhapKho
                )
                VALUES (
                    @IDCODE, @PackingID, @LotNo, @MaterialCode, @MaterialName, @PackQty, @pProcessUserID,
                    GETDATE(), @PartNo, @PublicCode, @ProductionSize, @TypeProduction,
                    N'Nhập', GETDATE(), @pProcessUserID, NULL, NULL, 
                    'NSX', 'VVT_F2', 1, N'Nhập từ file excel',@Levels,@SoPhieuNhapKho
                );

                SET @CountSuccess = @CountSuccess + 1;
            END

            ------------------- UPDATE -------------------
            ELSE IF @IUD_FLAG = 'UPDATE' 
            BEGIN
                UPDATE STB_VN_FINISHGOODS_BG_Test_20251225
                SET
                    PackingID       = ISNULL(@PackingID, PackingID),
                    MaterialCode    = ISNULL(@MaterialCode, MaterialCode),
                    MaterialName    = ISNULL(@MaterialName, MaterialName),
                    PackQty         = ISNULL(@PackQty, PackQty),
                    PartNo          = ISNULL(@PartNo, PartNo),
                    PublicCode      = ISNULL(@PublicCode, PublicCode),
                    ProductionSize  = ISNULL(@ProductionSize, ProductionSize),
                    TypeProduction  = ISNULL(@TypeProduction, TypeProduction),
                    CreateDateChange = GETDATE(),
                    SoPhieuNhapKho = ISNULL(@SoPhieuNhapKho,SoPhieuNhapKho),
                    USERIDChange    = @pProcessUserID,
                    Levels = ISNULL(@Levels, Levels)
                WHERE LotNo = @LotNo;
            END


            ------------------- DELETE -------------------
            ELSE IF @IUD_FLAG = 'DELETE' 
            BEGIN
                DELETE FROM STB_VN_FINISHGOODS_BG_Test_20251225
                WHERE LotNo = @LotNo;
            END

        END

        CLOSE SourceData;
        DEALLOCATE SourceData;

     IF LEN(@ListError) > 0
        BEGIN
            DECLARE @FinalMsg NVARCHAR(MAX)
            SET @FinalMsg = N'Đã nhập thành công: ' + CAST(@CountSuccess AS NVARCHAR) + N' dòng.' + CHAR(13) + CHAR(10) +
                            N'Các dòng lỗi sau KHÔNG được nhập (Vui lòng kiểm tra lại): ' + CHAR(13) + CHAR(10) + 
                            @ListError;
            IF @CountSuccess > 0 
            BEGIN
                SELECT 'WARNING' as ResultType, @FinalMsg as Message;
                RAISERROR(@FinalMsg, 10, 1) WITH NOWAIT; 
            END
            ELSE
            BEGIN
                RAISERROR(@FinalMsg, 16, 1);
            END
        END
        ELSE
        BEGIN
             SELECT 'SUCCESS' as ResultType, N'Nhập kho thành công' + CAST(@CountSuccess AS NVARCHAR) + N' dòng.' as Message;
        END

    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global','SourceData') >= -1
        BEGIN
            CLOSE SourceData;
            DEALLOCATE SourceData;
        END
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH
    
    EXEC sp_xml_removedocument @idoc;
END