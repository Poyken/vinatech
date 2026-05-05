-- Procedure: usp_BloomBoxLabalInfo_get_Vietname

CREATE PROCEDURE [dbo].[usp_BloomBoxLabalInfo_get_Vietname] -- exec  usp_BloomBoxLabalInfo_get_Vietname '','','VVMU293R050726'
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LotNo VARCHAR(100) = @pLotNo
	       ,@IsProdFinish BIT
		   ,@SN VARCHAR(20)
		   ,@RowCnt INT

	SELECT @IsProdFinish = IsProdFinish
	  FROM STB_SetInfo
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

	--일련번호 채번
	EXEC usp_DoCreateSerial 'STB_BloomBoxLabalPrintHist',@SN OUTPUT

	-- Mr.Manh update 2025-08-06 fix LotQty and PN 

	SELECT  @RowCnt = COUNT(*)
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
								FROM STB_BloomBoxLabalPrintHist
								GROUP BY LotNo
							) BBLPH ON BBLPH.LotNo = SI.Barcode
	WHERE
			SI.Barcode = @LotNo

	IF @RowCnt = 0 BEGIN
		SELECT
				MLI.MaterialCode,
				MM.MaterialName,
				MLI.LotID,
				MLI.PackingID,
				0 AS LabelQty,
				CASE
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0507QG%' THEN '120'
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0727QG%' THEN '102'
					END AS LotQty,
				MLI.CurrentQty,
				CASE WHEN LEFT(ISNULL(PLS.LotNo, MLI.LotNo), 2) = 'VV' THEN 'VV' + RIGHT(ISNULL(PLS.LotNo, MLI.LotNo), 12)
					 ELSE ISNULL(PLS.LotNo, MLI.LotNo) END AS LotNo,
				ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
				ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
				ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
				CASE
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0507QG%' THEN '133975'
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0727QG%' THEN '164855'
					END AS PN,
				ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo,
				MLI.StockAttrib1,
				dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)) AS DC,
				SI.SIExtText07 AS MarkingLetter,
				'Report' AS CommandType,
				ISNULL(BBLPH.PrintCnt, 0) AS PrintCnt,
				RIGHT(@SN, 3) AS SN,
				'' AS SalesPONo
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
				LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
				LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
								   FROM STB_BloomBoxLabalPrintHist
								  GROUP BY LotNo
								) BBLPH ON BBLPH.LotNo = SI.Barcode
		WHERE
				SI.Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END ELSE BEGIN
		SELECT
				MLI.MaterialCode,
				MM.MaterialName,
				MLI.LotID,
				MLI.PackingID,
				1 AS LabelQty,
				CASE
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0507QG%' THEN '120'
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0727QG%' THEN '102'
					END AS LotQty,
				MLI.CurrentQty,
				CASE WHEN LEFT(ISNULL(PLS.LotNo, MLI.LotNo), 2) = 'VV' THEN 'VV' + RIGHT(ISNULL(PLS.LotNo, MLI.LotNo), 12)
					 ELSE ISNULL(PLS.LotNo, MLI.LotNo) END AS LotNo,
				ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
				ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
				ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
				CASE
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0507QG%' THEN '133975'
					WHEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) LIKE '%VEC3R0727QG%' THEN '164855'
					END AS PN,
				ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo,
				MLI.StockAttrib1,
				dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)) AS DC,
				SI.SIExtText07 AS MarkingLetter,
				'Report' AS CommandType,
				ISNULL(BBLPH.PrintCnt, 0) AS PrintCnt,
				RIGHT(@SN, 3) AS SN,
				'' AS SalesPONo
		FROM
				STB_MaterialLotInfo MLI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
				LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
				LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
								   FROM STB_BloomBoxLabalPrintHist
								  GROUP BY LotNo
								) BBLPH ON BBLPH.LotNo = SI.Barcode
		WHERE
				SI.Barcode = @LotNo
	END
END
GO

