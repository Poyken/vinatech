CREATE PROC [dbo].[usp_VN_UpdateIDCode_Bg] -- exec [usp_VN_UpdateIDCode] 'VVKR113R036725','120','VN','NHA','FGVN20200921648'
@IDCODE NVARCHAR(50) ,
@Country  NVARCHAR(50),
@Uid NVARCHAR(50),
@KIEUXUAT NVARCHAR(50),
@SOTOKHAIHAIQUAN NVARCHAR(100),
@SOPHIEUXUATKHO NVARCHAR(100),
@SOINVOICE NVARCHAR(100),
@LEVELOUT NVARCHAR(100),
@TRANSPORT  NVARCHAR(100),
@CUSTOMERNAME NVARCHAR(100)
AS
BEGIN
	
		--declare @lotno varchar(20)=(select LotNo from STB_VN_FINISHGOODS WITH(NOLOCK) where IDCODE=@IDCODE)
		--exec usp_VVT_checkFIFO_FinishGood @pLotNo= @lotno

		DECLARE @Sts NVARCHAR(50)
		
		SELECT 
	
				@Sts = Statusout
		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
				IDCODE = @IDCODE
				AND 
				Statusout IS NULL 
				

		IF @Sts IS NULL

			BEGIN
			
									UPDATE 	STB_VN_FINISHGOODS_BG
										SET
											Country =  @Country,
											Statusout = N'Xuất',
											PersonExport = @Uid,
											DateExport = DATEADD(HH, -2, GETDATE()),
											MethodActions1 = N'Xuất bằng file excel',
											TYPEEXPORT =@KIEUXUAT,
											SoPhieuXuatKho=@SOPHIEUXUATKHO,
											SoInVoice = @SOINVOICE,
											SoToKhaiHaiQuan = @SOTOKHAIHAIQUAN,
											LevelsOut= @LEVELOUT,
											CUSTOMERNAME = @CUSTOMERNAME,
											TRANSPORT = @TRANSPORT
						
									WHERE
												IDCODE = @IDCODE 	
			END
END