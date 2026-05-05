CREATE PROC [dbo].[usp_VN_Update_ExportExcel_BG] 
-- exec usp_VN_Update_ExportExcel_BG '1200', 'VVNU083R038733','Hongkong','nguyennha','0003809','KR220218-01','304545252450', N'Xuất bán','1'

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
		SET @Text = 'VNVINABG'
		SET @Year= YEAR(GETDATE())
		SET @Moth = MONTH(GETDATE())
		SET @Days = DAY(GETDATE())


		/*
	  
		DECLARE @checkupdate INT
		exec usp_VVT_checkFIFO_FinishGood_BG @pLotNo=@LotNo,@NewProductID = @checkupdate OUTPUT  
	   if(@checkupdate=1)
			 return
       */
		SET @SPXK = @Text + @Year + @Moth + @Days + 'E'
		--return
		SELECT 
				@Barcode = Lotno,
				@Sts = Statusout,
				@Coun = Country
		FROM
				STB_VN_FINISHGOODS_BG WITH(NOLOCK)
		WHERE
				Statusout IS NULL AND LotNo = @LotNo

				IF(@Sts IS NULL AND @Coun IS NULL)

						UPDATE 	TOP (1)  STB_VN_FINISHGOODS_BG

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
-- select * from STB_VN_FINISHGOODS_BG where LotNo ='VVOT082R734606'

--update  STB_VN_FINISHGOODS_BG SET Statusout = null, Country = null, PersonExport = null, DateExport = null, MethodActions1 = null, SoPhieuNhapKho = null, INPUTFROM = null, TYPEEXPORT = null, LOCATIONS = null,LoaiHinhToKhai = null where ID ='45'


