-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PACBoxLabalInfo_get_Vietnam_inner]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @LotNo VARCHAR(100) = @pLotNo
				,@IsProdFinish BIT
				,@CheckMPN VARCHAR(30)
				,@SN VARCHAR(20)
				,@RowCnt INT

		
	SELECT @IsProdFinish = IsProdFinish,
			@CheckMPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END 
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo

	IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	IF @IsProdFinish IS NULL BEGIN 
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Mã Lotno này không tồn tại trên hệ thống.!'
		RETURN
	END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Kiểm tra màn hình B523 xem đóng gói hay chưa. Gọi sản xuất'
		RETURN
	END

	IF @CheckMPN <> 'VEC3R0606QG' BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Mã PN khác với >VEC3R0606QG<'
		RETURN
	END


	EXEC usp_DoCreateSerial 'STB_PACBoxLabalPrintHist_inner',@SN OUTPUT

	DECLARE @ProdDate VARCHAR(8) = CONVERT(VARCHAR, dbo.fnPharseLotNo(@LotNo, 'D'), 112)

	Declare @ReelID VARCHAR(20) = NULL
	DECLARE @rDC VARCHAR(4) = NULL
	SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112))

	DECLARE @rYY VARCHAR(2),
			@rM VARCHAR(1),
			@rD VARCHAR(1),
			@VN VARCHAR(100)

	-- Add the T-SQL statements to compute the return value here
	SET @rYY = SUBSTRING(@ProdDate, 3, 2)

	SET @rM = CASE SUBSTRING(@ProdDate, 5, 2)	WHEN '10' THEN 'A' 
												WHEN '11' THEN 'B'
												WHEN '12' THEN 'C'
												ELSE SUBSTRING(@ProdDate, 6, 1)
											END
	
	SET @rD = CASE RIGHT(@ProdDate, 2)	WHEN '10' THEN 'A' 
										WHEN '11' THEN 'B'
										WHEN '12' THEN 'C'
										WHEN '13' THEN 'D'
										WHEN '14' THEN 'E'
										WHEN '15' THEN 'F'
										WHEN '16' THEN 'G'
										WHEN '17' THEN 'H'
										WHEN '18' THEN 'I'
										WHEN '19' THEN 'J'
										WHEN '20' THEN 'K'
										WHEN '21' THEN 'L'
										WHEN '22' THEN 'M'
										WHEN '23' THEN 'N'
										WHEN '24' THEN 'O'
										WHEN '25' THEN 'P'
										WHEN '26' THEN 'Q'
										WHEN '27' THEN 'R'
										WHEN '28' THEN 'S'
										WHEN '29' THEN 'T'
										WHEN '30' THEN 'U'
										WHEN '31' THEN 'V'
										ELSE RIGHT(@ProdDate, 1)
									END



		SET	@ReelID = 'VV5' + @rYY + @rM + @rD + RIGHT(@SN, 5)

			-- IAC;6010A0981401;2525;VVPO213R060608;00250;VV5256L00002;
	SET @VN = 'IAC;6010A0981401;' + @rDC+ ';' + @LotNo + ';00250;' + @ReelID +';'


	

	SELECT
				MLI.MaterialCode,
				MM.MaterialName,
				MLI.PackingID,
				N'THÙNG TRONG' AS TypeBox,
				'6010A09801401' AS PN,
				@rDC AS DC,
				@LotNo AS Lot,
				250 AS Qty,
				@ReelID AS Reel,
				'VEC3R0606QG' AS MPN,
				'6010A09801401' AS ScanPN,
				@rDC AS ScanDC,
				@LotNo AS ScanLot,
				250 AS ScanQty,
				@ReelID AS ScanReel,
				'VEC3R0606QG' AS ScanMPN,
				@VN AS VNBarcode,
				RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END AS CheckMPN,
				ISNULL(PACH.PrintCnt, 0) AS PrintCnt,
				1 AS LabelQty,
				'Report' AS CommandType
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				--LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
				LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
								   FROM STB_PACBoxLabalPrintHist
								  GROUP BY LotNo
								) PACH ON PACH.LotNo = SI.Barcode
		WHERE
				SI.Barcode = @LotNo

END

-- exec usp_PACBoxLabalInfo_get_Vietnam_inner '' ,'' ,'VVPO213R060608'

-- exec usp_PACBoxLabalInfo_get_Vietnam_inner '' ,'' ,'VVPP013R050771'