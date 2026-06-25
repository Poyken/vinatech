-- =============================================
-- Hotfix ID: 01_FIX_DRY_OVEN_OPERATOR_PRIORITY
-- Target Object: usp_VN_DryOver
-- Author: vanduc
-- Date: 2026-06-10
-- Description: Sửa lỗi độ ưu tiên toán tử AND/OR làm bypass kiểm tra công đoạn V-22 bắt buộc.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: 01_FIX_DRY_OVEN_OPERATOR_PRIORITY...';

-- 1. Sao lưu định nghĩa cũ và sửa đổi SP
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_VN_DryOver')
BEGIN
    EXEC('
    ALTER proc [dbo].[usp_VN_DryOver]
    @pProcessLanguage VARCHAR(20),
    @pBarCode NVARCHAR(100) = NULL,
    @pDryMachines NVARCHAR(50) = NULL
    AS
    BEGIN
            DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
            DECLARE @BarCode VARCHAR(100) = CASE WHEN ISNULL(@pBarCode,'''') = '''' THEN ''%'' ELSE @pBarCode END
            DECLARE @MaterialCodes NVARCHAR(50)
            DECLARE @MaterialNames NVARCHAR(100)
            DECLARE @BarCodes NVARCHAR(100)
            DECLARE @Bar NVARCHAR(100)
            DECLARE @TotalMinutes INT
            DECLARE @QTY FLOAT
            DECLARE @OvenOutDate DATETIME
            DECLARE @OvenInDate DATETIME
            DECLARE @Dryovers NVARCHAR(50)
            DECLARE @StatusOut NVARCHAR(30)
            DECLARE @StatusIn NVARCHAR(30)
            DECLARE @Stg NVARCHAR(50)
            declare @ccount INT=0;
            declare @OvenInputDate datetime;
                   
            DECLARE @LotNonew1 VARCHAR(20) = ''''
            DECLARE @LotNonew2 VARCHAR(20) = ''''
            DECLARE @LotNonew3 VARCHAR(20) = ''''
            DECLARE @LotNonew4 VARCHAR(20) = ''''
            DECLARE @LotNonew5 VARCHAR(20) = ''''
            DECLARE @LotNonew6 VARCHAR(20) = ''''
            
            select @LotNonew1 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@BarCode 
    
            select @LotNonew2 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@LotNonew1 

            select @LotNonew3 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@LotNonew2 

            select @LotNonew4 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@LotNonew3 

            select @LotNonew5 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@LotNonew4 

            select @LotNonew6 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@LotNonew5 	

            select @BarCode = Barcode from stb_setinfo WITH(NOLOCK) where 
            Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
            
            /* ------------------Bắt đầu kiểm tra xem công đoạn V-22 đã được nhập chưa-----------------*/
            SELECT
                    @Stg = routecode
            FROM 
                    STB_ProdRouteHist WITH(NOLOCK)
            WHERE 1=1 
                    AND (routecode=''V-22'' OR routecode=''V-22_BG'') -- FIX: Thêm ngoặc đơn ở đây để sửa lỗi độ ưu tiên toán tử AND/OR
                    AND controlno= (select controlno 
                                    from stb_setinfo WITH(NOLOCK) 
                                    where barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)  
                                    )

            /* ------------------Kết thúc  kiểm tra xem công đoạn V-22 đã được nhập chưa-----------------*/

            IF @Stg IS NULL
                BEGIN
                         DECLARE @NotEnoughStockError NVARCHAR(MAX)
                            EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                N''Bạn vui lòng nhập công đoạn V-22 trước khi ^In tem vào^'',
                                                                @NotEnoughStockError OUTPUT

                            RAISERROR(@NotEnoughStockError,16,1)
                            RETURN		
                END
            ELSE
                    BEGIN		--1
                        SELECT
                            @MaterialCodes=T1.MaterialCode,
                            @MaterialNames=T2.MaterialName,
                            @BarCodes=T1.Barcode,
                            @QTY=T1.ProdQty
                        FROM
                                STB_SetInfo T1 WITH(NOLOCK)
                                 LEFT OUTER JOIN STB_MaterialMaster T2	 ON T1.MaterialCode = T2.MaterialCode
                        WHERE
                                T1.Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

                        SELECT 
                                @Dryovers=DryMachines,
                                @Bar=BarCode,
                                @StatusOut=StatusOut,
                                @OvenInputDate=OvenInputDate
                        FROM 
                                STB_VN_DRYOVER WITH(NOLOCK)
                        WHERE 
                                BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

                        IF @Bar IS NULL AND @StatusOut IS NULL
                            BEGIN	--2
                                    INSERT INTO STB_VN_DRYOVER
                                    (
                                        MaterialCode,
                                        MaterialName,
                                        BarCode,
                                        DryMachines,
                                        QTY,
                                        StatusIn,
                                        OvenInputDate,
                                        CreateDateTime
                                    )
                                    VALUES
                                    (
                                        @MaterialCodes,
                                        @MaterialNames,
                                        @BarCode,
                                        @pDryMachines,
                                        @QTY,
                                        N''Vào'',
                                        DATEADD(HH, -2, GETDATE()),
                                        DATEADD(HH, -2, GETDATE())
                                    )

                                    UPDATE STB_SetInfo
                                    SET 
                                                SIExtText06= @pDryMachines,
                                                SIExtText02= CONVERT(nvarchar,GETDATE(),120)
                                    WHERE 
                                            Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
                            END -- 2
                
                            DECLARE @Confighours INT = 0
                            SET @Confighours = CASE WHEN @MaterialCodes IN (
                                                                ''ECVT27-382'',
                                                                ''ECVT30-333'',
                                                                ''ECVT27-353'',
                                                                ''ECVT30-250'',
                                                                ''ECVT30-262'',
                                                                ''ECVT30-354'',
                                                                ''ECVT30-252'',
                                                                ''ECVT30-331'',
                                                                ''RE3000-131'',
                                                                ''ECVT30-255'',
                                                                ''ECVT30-379'',
                                                                ''LIVT38-010'',
                                                                ''LIVT38-013'',
                                                                ''LIVT38-007'',
                                                                ''LIVT38-012''
                                                                            ) THEN 3
                                                WHEN @MaterialCodes IN (
                                                                ''LIVT38-016'',
                                                                ''LIVT38-009'',
                                                                ''LIVT38-027''
                                                                        ) THEN 12
                                                WHEN @MaterialCodes IN (
                                                                ''ECVT27-358'',
                                                                ''ECVT27-369'',
                                                                ''ECVT30-271'',
                                                                ''ECVT27-356'',
                                                                ''ECVT30-258'',
                                                                ''ECVT30-261''
                                                                        ) THEN 15
                                                WHEN @MaterialCodes IN (
                                                                ''ECVT27-247'',
                                                                ''ECVT30-115'',
                                                                ''ECVT30-316'',
                                                                ''ECVT30-349'',
                                                                ''ECVT30-098'',
                                                                ''ECVT30-197'',
                                                                ''ECVT30-294'',
                                                                ''ECVT30-076'',
                                                                ''ECVT30-358'',
                                                                ''ECVT30-116'',
                                                                ''ECVT30-117''
                                                                        ) THEN 20
                                                WHEN @MaterialCodes IN (
                                                        ''ECVT30-357''
                                                                        ) THEN 30
                                                ELSE 9 END

                            if (getdate() > dateadd(hour, @Confighours, @OvenInputDate))
                            IF(@Bar IS NOT NULL AND @StatusOut IS NULL)
                                BEGIN  --3
                                        UPDATE STB_VN_DRYOVER
                                        SET
                                            OvenOutDate = DATEADD(HH, -2, GETDATE()),
                                            StatusOut = N''Ra'',
                                            ChangeDateTime = DATEADD(HH, -2, GETDATE())
                                        WHERE 
                                             BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

                                             SELECT
                                                     @TotalMinutes = DATEDIFF(MINUTE,OvenInputDate,OvenOutDate)
                                             FROM
                                                     STB_VN_DRYOVER
                                             WHERE
                                                     BarCode=@BarCode

                                        UPDATE STB_VN_DRYOVER
                                        SET
                                                    TotalMinutes=@TotalMinutes,
                                                    TotalHouse= @TotalMinutes / 60
                                        WHERE 
                                                     BarCode in  (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

                                        UPDATE STB_SetInfo
                                        SET 
                                                    SIExtText03=CONVERT(nvarchar,GETDATE(),120)
                                        WHERE 
                                                Barcode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
                                END		--3

                            IF(@BarCode IS NULL)
                                BEGIN
                                        PRINT ''Do not show anything''
                                END
                            ELSE
                                BEGIN	--4
                                SELECT
                                        MaterialCode,
                                        MaterialName,
                                        BarCode ,
                                        DryMachines,
                                        Qty,
                                        StatusIn,
                                        convert(varchar(10),OvenInputDate,120)  AS DateIn,
                                        RIGHT(convert(varchar(19),OvenInputDate,120) , 8) AS TimeIn,
                                        StatusOut,
                                        convert(varchar(10),OvenOutDate,120) AS DateOut,
                                        right(convert(varchar(19),OvenOutDate,120) , 8) AS TimeOuts,
                                        TotalMinutes,
                                        case 
                                            when isnull(StatusOut,'''' )='''' then ''Report''
                                            when StatusOut=N''Ra'' and ( isnull(Pressure,0)=0 or 
                                            isnull(DryTemperature,0)=0 or
                                            isnull(OutTemperature,0)=0) 
                                            then '''' 
                                            else ''Report'' 
                                        end
                                        AS CommandType,
                                        TotalHouse,
                                         Pressure, 
                                         Unit,
                                         DryTemperature, 
                                         OutTemperature,
                                            CASE 
                                                WHEN   TotalHouse = 12  THEN N''Đảm bảo tiêu chuẩn sấy''
                                                WHEN   TotalHouse > 12  THEN  N''Thời gian sấy vượt qua tiêu chuẩn''
                                                WHEN   TotalHouse < 12  THEN N''Thời gian nhỏ hơn tiêu chuẩn sấy'' -- Sửa chính tả tiếng Việt
                                                ELSE N''Chưa rõ tiêu chuẩn'' -- Sửa chính tả "chưa dõ"
                                        END AS Result 
                             FROM
                                        STB_VN_DRYOVER WITH(NOLOCK)
                             WHERE 
                                                (BarCode in (@BarCode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) )
                                END  --4
                    END -- 1
    END
    ');
    PRINT 'Procedure usp_VN_DryOver altered successfully.';
END
ELSE
BEGIN
    PRINT 'Error: Procedure usp_VN_DryOver not found!';
END

-- 2. Chạy thử nghiệm Simulation Test
-- Tạo Lot giả lập trong SetInfo
IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = 'TEST_DRY_OVEN_LOT')
BEGIN
    INSERT INTO STB_SetInfo (Barcode, ControlNo, MaterialCode, ProdQty, CreateDateTime, CreateUserID)
    VALUES ('TEST_DRY_OVEN_LOT', 'CTRL_TEST_DRY', 'ECVT30-333', 100, GETDATE(), 'vinaadmin');
END

-- Trường hợp 1: Thử quét sấy khi CHƯA có công đoạn V-22 -> Kỳ vọng ném lỗi 16
BEGIN TRY
    PRINT 'Test case 1: Expect error because of missing V-22...';
    EXEC usp_VN_DryOver 'vi-VN', 'TEST_DRY_OVEN_LOT', 'DryOven_01';
    PRINT 'Test case 1: FAILED! (Did not catch error)';
END TRY
BEGIN CATCH
    PRINT 'Test case 1: PASSED. Error caught: ' + ERROR_MESSAGE();
END CATCH;

-- Trường hợp 2: Thêm công đoạn V-22 vào STB_ProdRouteHist và chạy thử lại -> Kỳ vọng tạo thành công ca sấy
INSERT INTO STB_ProdRouteHist (ControlNo, RouteCode, ProdDateTime, CreateUserID, CreateDateTime)
VALUES ('CTRL_TEST_DRY', 'V-22_BG', GETDATE(), 'vinaadmin', GETDATE());

BEGIN TRY
    PRINT 'Test case 2: Expect success after adding V-22...';
    EXEC usp_VN_DryOver 'vi-VN', 'TEST_DRY_OVEN_LOT', 'DryOven_01';
    
    IF EXISTS (SELECT 1 FROM STB_VN_DRYOVER WHERE BarCode = 'TEST_DRY_OVEN_LOT')
    BEGIN
        PRINT 'Test case 2: PASSED. Dry oven record created successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Test case 2: FAILED. Record not found in STB_VN_DRYOVER!';
    END
END TRY
BEGIN CATCH
    PRINT 'Test case 2: FAILED. Error: ' + ERROR_MESSAGE();
END CATCH;

-- Clean up
DELETE FROM STB_ProdRouteHist WHERE ControlNo = 'CTRL_TEST_DRY';
DELETE FROM STB_SetInfo WHERE Barcode = 'TEST_DRY_OVEN_LOT';
DELETE FROM STB_VN_DRYOVER WHERE BarCode = 'TEST_DRY_OVEN_LOT';

-- 3. Hủy bỏ thay đổi để tránh ảnh hưởng DB Production (DBA sẽ commit bằng tay sau khi duyệt)
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
