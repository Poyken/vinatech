-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================

CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessProdPacking_531_VVT]
    @pProcessUserID VARCHAR(20) = NULL,
    @pProcessLanguage VARCHAR(20) = NULL,
    @pControlNo VARCHAR(50) = NULL,
    @pDayPlanNo VARCHAR(50) = NULL,
    @pPONo VARCHAR(50) = NULL,
    @pBarcode VARCHAR(50) = NULL,
    @pBoxQty INT = NULL,
	@pExpired Nvarchar(20)= NULL,
	@pWorkerCode VARCHAR(20) = NULL
AS
BEGIN

--raiserror('12312',16,1)
--return
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage;
    DECLARE @ControlNo VARCHAR(50) = @pControlNo;
    DECLARE @DayPlanNo VARCHAR(50) = @pDayPlanNo;
    DECLARE @PONo VARCHAR(50) = @pPONo;
    DECLARE @Barcode VARCHAR(50) = @pBarcode;
    DECLARE @BoxQty INT = @pBoxQty;
    DECLARE @Expired Nvarchar(20) = @pExpired;
    DECLARE @WorkerCode varchar(20) = @pWorkerCode;

    DECLARE @CreateDateTime DATETIME = GETDATE();
    DECLARE @ParentLotNo VARCHAR(50);
    DECLARE @MergeNumber VARCHAR(15);


	 --raiserror(@WorkerCode,16,1)
     -- Tạo bảng tạm để lưu trữ mã barcode và thông báo lỗi
		   CREATE TABLE #BarcodeErrors (
			Barcode VARCHAR(50),
			InputJobDate DATETIME,
			MergeNumber VARCHAR(20)
		);
    -- Bắt đầu giao dịch
	-- Thêm mã barcode vào bảng lỗi
				declare @InputJobDate DATETIME
				select @InputJobDate= InputJobDate from stb_setInfo where  Barcode = @Barcode
				
				SET @MergeNumber = FORMAT(@CreateDateTime, 'yyyyMMddHHmmss');

				--INSERT INTO #BarcodeErrors (Barcode,InputJobDate,MergeNumber) 
				--VALUES (@Barcode,@InputJobDate,@MergeNumber);
				INSERT INTO BarcodeErrors (Barcode,InputJobDate,MergeNumber) 
				VALUES (@Barcode,@InputJobDate,@MergeNumber);
				DECLARE @ErrorMessage NVARCHAR(100);

				DECLARE @MinDate DATE;
				DECLARE @MaxDate DATE;

				-- Lấy giá trị nhỏ nhất và lớn nhất của cột InputJobDate
				SELECT 
					@MinDate = MIN(InputJobDate),
					@MaxDate = MAX(InputJobDate)
				FROM 
					BarcodeErrors 
					where MergeNumber=@MergeNumber

-- Kiểm tra khoảng thời gian giữa giá trị nhỏ nhất và giá trị lớn nhất có vượt quá 3 tháng không
--IF DATEDIFF(MONTH, @MinDate, @MaxDate) > 3
--	BEGIN
--		-- Nếu khoảng thời gian vượt quá 3 tháng, trả về lỗi
--			RAISERROR('Tất cả các mã LotNo không được cách nhau quá 3 tháng', 16, 1);
--	END
			

    BEGIN TRANSACTION;
		
				
--raiserror(#BarcodeErrors,16,1)
IF @Expired = 1
	BEGIN
				-- Hủy giao dịch và thông báo lỗi
				ROLLBACK;
				--DECLARE @ErrorMessage NVARCHAR(100);
				SET @ErrorMessage = FORMATMESSAGE(N'Mã đã hết hạn: %s', @Barcode);
				RAISERROR(@ErrorMessage, 16, 1);
				RETURN;  -- Thoát khỏi stored procedure
	END
    -- Kiểm tra điều kiện @BoxQty
    IF @BoxQty > 0
    BEGIN
        -- Lấy ChildLotNo đầu tiên cho CreateDateTime
        SELECT TOP 1 @ParentLotNo = ChildLotNo
        FROM stb_MergeBoxRealityHist
        WHERE CreateDateTime = @CreateDateTime
        ORDER BY CreateDateTime;

        -- Nếu không có bản ghi nào, tạo ParentLotNo mới
        IF @ParentLotNo IS NULL
        BEGIN
            SET @ParentLotNo = @Barcode;
        END

        

        -- Chèn dữ liệu vào bảng chính
        INSERT INTO stb_MergeBoxRealityHist (ParentLotNo, ControlNo, DayPlanNo, PONo, ChildLotNo, BoxQty, CreateDateTime, MergeNumber,WorkerCode)
        VALUES (@ParentLotNo, @ControlNo, @DayPlanNo, @PONo, @Barcode, @BoxQty, @CreateDateTime, @MergeNumber,@WorkerCode);
		

		declare @ParentLotNos varchar(50)
		declare @ChildLotNos varchar(50)
		declare @BoxQtys int
		declare @count int
			
		 select @count =count(MergeNumber) from stb_MergeBoxReality  where MergeNumber =@MergeNumber

		 if(@count>0)
					begin 
							declare @ParentLotNoBef varchar(50)
							declare @ChildLotNoBef varchar(50)
							declare @BoxQtyBef int
							select @ParentLotNoBef=ParentLotNo,@ChildLotNoBef=ChildLotNo,@BoxQtyBef=BoxQty from stb_MergeBoxReality where  MergeNumber =@MergeNumber
							update stb_MergeBoxReality set ParentLotNo=@ParentLotNoBef , ChildLotNo =@ChildLotNoBef+'-'+@Barcode,BoxQty =@BoxQtyBef+@BoxQty where  MergeNumber =@MergeNumber
					end
		else
					begin
						INSERT INTO stb_MergeBoxReality (ParentLotNo, ControlNo, DayPlanNo, PONo, ChildLotNo, BoxQty, CreateDateTime, MergeNumber,WorkerCode)
						 VALUES (@ParentLotNo, @ControlNo, @DayPlanNo, @PONo, @Barcode, @BoxQty, @CreateDateTime, @MergeNumber,@WorkerCode);
					end
		
		

        -- Xác nhận giao dịch
        COMMIT;
		  --DROP TABLE BarcodeErrors;
    END
    ELSE
    BEGIN
         -- Nếu @BoxQty không hợp lệ, hủy giao dịch và in ra mã LotNo
        ROLLBACK;
        --DECLARE @ErrorMessage NVARCHAR(100);
        SET @ErrorMessage = FORMATMESSAGE(N'Số lượng box phải lớn hơn 0 LotNo: %s', @Barcode);
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN;  -- Thoát khỏi stored procedure
    END



END

    --select * from BarcodeErrors
    --select * from stb_MergeBoxReality
	 --select * from stb_MergeBoxRealityHist


	--delete from BarcodeErrors
	--delete from stb_MergeBoxReality
	--delete from stb_MergeBoxRealityHist

