CREATE PROC [dbo].[usp_VN_Update_ExportExcel] -- exec usp_VN_Update_ExportExcel '1433', 'MVVLN042R733510','Hongkong','nguyentha','0003809','KR220218-01','304545252450', N'Xuất bán','1'
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
@Khachhang NVARCHAR(50)
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
		SET @Text = 'VNVINA'
		SET @Year= YEAR(GETDATE())
		SET @Moth = MONTH(GETDATE())
		SET @Days = DAY(GETDATE())
		
		  --Mở/Tắt FIFO kho thành phẩm cho nhà máy Bắc Ninh 
		
	/*
	
	DECLARE @checkupdate INT
	exec usp_VVT_checkFIFO_FinishGood @pLotNo=@LotNo,@NewProductID = @checkupdate OUTPUT  
      if(@checkupdate=1)
	begin
	   RAISERROR (N'FIFO không hợp lệ, không thể xuất kho LotNo: %s', 16, 1, @LotNo);
           RETURN -1;
	end
	*/
	  

		SET @SPXK = @Text + @Year + @Moth + @Days + 'E'

		SELECT 
				@Barcode = Lotno,
				@Sts = Statusout,
				@Coun = Country
		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
				Statusout IS NULL AND LotNo = @LotNo 

				IF(@Sts IS NULL AND @Coun IS NULL)

						UPDATE 	TOP (1)  STB_VN_FINISHGOODS

									SET
											Country =  @Country ,
											Statusout = N'Xuất',
											PersonExport = @Uid,
											DateExport = DATEADD(HH, -2, GETDATE()),
											MethodActions1 = N'Xuất bằng file excel',
											SoPhieuXuatKho = @SoPhieuXuatKho,
											SoInVoice = @SoInVoice,
											SoToKhaiHaiQuan = @SoToKhaiHaiQuan,
											TYPEEXPORT = @TYPEEXPORT,
											LevelsOut = @Levleout,
											LoaiHinhToKhai = 'E62',
											TRANSPORT = @Vanchuyen,
											CUSTOMERNAME = @Khachhang
									WHERE
												LotNo = @Barcode and Statusout is null and PackQty=@Qty
END
-- select * from STB_VN_FINISHGOODS


