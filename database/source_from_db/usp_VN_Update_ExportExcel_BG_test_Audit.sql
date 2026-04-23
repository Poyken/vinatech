CREATE PROCEDURE [dbo].[usp_VN_Update_ExportExcel_BG_test_Audit](
-- exec usp_VN_Update_ExportExcel_BG '1433', 'VVNU083R038733','Hongkong','nguyennha','0003809','KR220218-01','304545252450', N'Xuất bán','1'

--exec usp_VN_Update_ExportExcel_BG '695', 'VVOT082R734606','Hongkong','nguyennha','0003809','KR220218-01','304545252450', N'Xuất bán','','',''

@Qty INT,
@LotNo NVARCHAR(50),
@Country  NVARCHAR(50),
@Uid NVARCHAR(50),
@SoPhieuXuatKho NVARCHAR(50),
@SoInVoice NVARCHAR(50),
@SoToKhaiHaiQuan NVARCHAR(50),
@TYPEEXPORT NVARCHAR(50),
@Levleout NVARCHAR(50),
@Vanchuyen NVARCHAR(50),
@Khachhang NVARCHAR(50))
AS
BEGIN
		DECLARE @Barcode NVARCHAR(50)
		DECLARE @Sts NVARCHAR(50)
		DECLARE @Coun NVARCHAR(50) 
		DECLARE @Year NVARCHAR(10)
		DECLARE @Moth  NVARCHAR(10)
		DECLARE @Days NVARCHAR(10)
		DECLARE @Text NVARCHAR(10)
		DECLARE @SPXK NVARCHAR(20)
		SET @Text = 'VNVINABG'
		SET @Year= YEAR(GETDATE())
		SET @Moth = MONTH(GETDATE())
		SET @Days = DAY(GETDATE())

	
		DECLARE @checkupdate INT
		--exec usp_VVT_checkFIFO_FinishGood_BG @pLotNo=@LotNo,@NewProductID = @checkupdate OUTPUT  
	    if(@checkupdate=1)
			return

       -- Prevent users from exporting when there is StatusCheck='Reject'
	   -- Author:Nguyen Hai Trieu (28/04/2025) AND (29/04/2025)
	   -- Check type QC Audit or Basic
	   -- Case 1: QC Audit and FGLocation=N'Bắc Giang'
	   
	   DECLARE @ErrorMessage NVARCHAR(200)
	   DECLARE @StatusCheck NVARCHAR(50)
       DECLARE @FGLocation NVARCHAR(100)
       DECLARE @Statusout NVARCHAR(50)
	   
	 IF NOT EXISTS (
        SELECT 1 FROM STB_VN_FINISHGOODS_forQCAudit
        WHERE LotNo = @LotNo AND PackQty = @Qty AND FGLocation=N'Bắc Giang'
      )
    BEGIN
        SET @ErrorMessage = N'Lỗi: Không tìm thấy lô hàng "' + @LotNo + N'" với số lượng "' + CAST(@Qty AS NVARCHAR) + '".'
        RAISERROR(@ErrorMessage, 16, 1)
        RETURN -1
    END


	SELECT TOP 1 @Statusout = Statusout
    FROM STB_VN_FINISHGOODS_forQCAudit WITH (ROWLOCK, UPDLOCK, READPAST)
    WHERE LotNo = @LotNo AND PackQty = @Qty AND Statusout is not null AND FGLocation=N'Bắc Giang' AND StatusCheck=N'Pass'

    IF @Statusout IS NOT NULL AND @Statusout <> ''
    BEGIN
        SET @ErrorMessage = N'Lỗi: Lô hàng "' + @LotNo + N'" đã được xuất (Statusout = ' + @Statusout + ').'
        RAISERROR(@ErrorMessage, 16, 1)
        RETURN -1
    END
    --  Lấy thông tin để kiểm lỗi chi tiết
    SELECT TOP 1
        @StatusCheck = StatusCheck,
        @FGLocation = FGLocation,
        @Statusout = Statusout
    FROM STB_VN_FINISHGOODS_forQCAudit WITH (ROWLOCK, UPDLOCK, READPAST)
    WHERE LotNo = @LotNo AND PackQty = @Qty AND @Statusout IS NULL

    --  Check lỗi cụ thể bằng CASE
    SELECT @ErrorMessage =
        CASE 
            WHEN @StatusCheck IS NULL THEN N'Lỗi: Lô hàng "' + @LotNo + N'" chưa kiểm tra QC (StatusCheck IS NULL).'
            WHEN @StatusCheck = N'' THEN N'Lỗi: Lô hàng "' + @LotNo + N'" chưa kiểm tra QC (StatusCheck rỗng).'
            WHEN @StatusCheck = N'Reject' THEN N'Lỗi: Lô hàng "' + @LotNo + N'" bị lỗi QC (StatusCheck = Reject).'
            WHEN @FGLocation <> N'Bắc Giang' THEN N'Lỗi: Lô hàng "' + @LotNo + N'" không nằm tại kho Bắc Giang (FGLocation = ' + ISNULL(@FGLocation, 'NULL') + ').'
            ELSE NULL
        END

    IF @ErrorMessage IS NOT NULL
    BEGIN
        RAISERROR(@ErrorMessage, 16, 1)
        RETURN -1
    END
	SET @SPXK = @Text + @Year + @Moth + @Days + 'E'

		SELECT 
				@Barcode = Lotno,
				@Sts = Statusout,
				@Coun = Country
		FROM
				STB_VN_FINISHGOODS_forQCAudit WITH(NOLOCK)
		WHERE
				Statusout IS NULL AND LotNo = @LotNo AND PackQty=@Qty

	           IF(@Sts IS NULL AND @Coun IS NULL)
    --  Nếu không có lỗi, tiến hành cập nhật
    UPDATE TOP (1) STB_VN_FINISHGOODS_forQCAudit
    SET 
        Country = @Country,
        Statusout = N'Xuất',
        PersonExport = @Uid,
        DateExport = DATEADD(HOUR, -2, GETDATE()),
        MethodActions1 = N'Xuất bằng file excel',
        SoPhieuXuatKho = @SoPhieuXuatKho,
        SoInVoice = @SoInVoice,
        SoToKhaiHaiQuan = @SoToKhaiHaiQuan,
        TYPEEXPORT = @TYPEEXPORT,
        LevelsOut = @Levleout,
        LoaiHinhToKhai = 'E62',
        TRANSPORT = @Vanchuyen,
        CUSTOMERNAME = @Khachhang,
        FGLocation = N'Bắc Giang',
        StatusCheck = N'Pass'
    WHERE LotNo = @LotNo AND PackQty = @Qty AND Statusout IS NULL

END