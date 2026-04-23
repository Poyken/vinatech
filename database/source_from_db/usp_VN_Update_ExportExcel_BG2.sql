-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-04-06
-- Description:	Xuất kho Excel kho thành phẩm BG2
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_Update_ExportExcel_BG2] 
	-- Add the parameters for the stored procedure here
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
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	    DECLARE @Barcode NVARCHAR(50)
		DECLARE @Sts NVARCHAR(50)
		DECLARE @Coun NVARCHAR(50) 
		DECLARE @Year NVARCHAR(10)
		DECLARE @Moth  NVARCHAR(10)
		DECLARE @Days NVARCHAR(10)
		DECLARE @Text NVARCHAR(10)
		DECLARE @SPXK NVARCHAR(20)
		SET @Text = 'VNVINABG2'
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
		SELECT 
				@Barcode = Lotno,
				@Sts = Statusout,
				@Coun = Country
		FROM
				STB_VN_FINISHGOODS_BG2 WITH(NOLOCK)
		WHERE
				Statusout IS NULL AND LotNo = @LotNo

				IF(@Sts IS NULL AND @Coun IS NULL)

						UPDATE 	TOP (1)  STB_VN_FINISHGOODS_BG2

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



