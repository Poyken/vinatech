-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PACBoxLabelInfo_get_Vietnam]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @LotNo VARCHAR(50) = @pLotNo
			,@IsProdFinish BIT
			,@CheckMPN VARCHAR(30)
			,@SN VARCHAR(20)
			,@RowCnt INT
	DECLARE @ProdDate VARCHAR(8) = CONVERT(VARCHAR, dbo.fnPharseLotNo(@LotNo, 'D'), 112)

	DECLARE @rDC VARCHAR(4) = NULL
	SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112))
		
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

	--IF @IsProdFinish IS NULL BEGIN 
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Mã Lotno này không tồn tại trên hệ thống.!'
	--	RETURN
	--END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Kiểm tra màn hình B523 xem đóng gói hay chưa. Gọi sản xuất'
		RETURN
	END

	BEGIN
			--EXEC usp_DoCreateSerial 'STB_PACLabelPrintHistV1',@SN OUTPUT
			SELECT
						MLI.MaterialCode,
						MM.MaterialName,
						--MLI.PackingID,
						--'6010A09801401' AS PN,
					    'APO230800061' AS PO,
						@LotNo AS Lot,
						'1ECCDH0L62500006' AS Customer_PN,
						840 AS UnitQty,
						'VEL13353R8257G' AS SupplierPN,
						@rDC as DC,
						--@VN AS VNBarcode,
						--RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END AS CheckMPN,
						--ISNULL(PACH.PrintCnt, 0) AS PrintCnt,
						1 AS LabelQty,
						'Report' AS CommandType
				FROM
						STB_MaterialLotInfo MLI WITH(NOLOCK)
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						--LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						--LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
						--					FROM STB_PACBoxLabalPrintHist
						--				   WHERE LabelType = N'THÙNG NGOÀI'
						--				  GROUP BY LotNo
						--				) PACH ON PACH.LotNo = SI.Barcode 
				WHERE
						SI.Barcode = @LotNo
		END
		END