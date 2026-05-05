SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pPONumber VARCHAR(50) = null,
	@pLotNo VARCHAR(50) = null,
	@pQuantity VARCHAR(100) = null,
	@pTotalBox INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMPN VARCHAR(30)
		,@SN VARCHAR(20)
		,@RowCnt INT
		,@CheckMaterial NVARCHAR(100)

	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo

	SELECT @IsProdFinish = SI.IsProdFinish,
			@CheckMaterial = MM.MaterialName
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode

	DECLARE @TotalBoxString VARCHAR(5) = NULL
	IF	@pTotalBox < 10 
		SET @TotalBoxString = '0' +  CONVERT(VARCHAR(3), ISNULL(@pTotalBox, 1)) 
	ELSE 
		SET @TotalBoxString = CONVERT(VARCHAR(3), ISNULL(@pTotalBox, 1)) 

	-- LOGIC MỚI: YYWW (Năm + Tuần)
	DECLARE @rDC VARCHAR(20) = NULL
	DECLARE @dt DATE = CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)
	SET @rDC = CONVERT(VARCHAR(2), @dt, 12) + RIGHT('0' + CAST(DATEPART(WEEK, @dt) AS VARCHAR(2)), 2)

	DECLARE		@packingDate_tmp DATETIME = NULL,
				@packingDate VARCHAR(20) = NULL,
				@InspEmpID VARCHAR(20) = NULL,
				@InspEmpName NVARCHAR(200) = NULL
	SELECT TOP 1  @packingDate_tmp = PrintTime 
		FROM STB_SavePackingTime_VVT 
		where (LotNo = @LotNo or LotNo = @NewBarcode )
		ORDER BY (
			CASE 
					WHEN LotNo = @LotNo and IsPrinted = 0 THEN 1 
					WHEN LotNo = @LotNo and IsPrinted = 1 THEN 1 
					ELSE 2
				END)

	SET @packingDate = CONVERT(VARCHAR(6), CAST(@packingDate_tmp AS DATE), 12);
	
	SELECT TOP 1  @InspEmpID = MIIExtText01,
					@InspEmpName = PWI.WorkerName
		FROM STB_MaterialQcInfo  MQI
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
		where	MQI.InspectionDocType = 'OQC' AND
				(MQI.MaterialQcNo LIKE '%' +SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%')

	CREATE TABLE #tmp (Num INT)
	DECLARE @Number INT = 1;
	WHILE @Number <= ISNULL(@pTotalBox, 1)
	BEGIN
		INSERT INTO #tmp (Num) VALUES (@Number)
		SET @Number = @Number + 1;
	END

	SELECT 
		N'Vinatech Vina' AS SupplierName,
		N'LFIBLM164855' AS SanminaPartNumber,
		N'CAP,TH EDLC 720F 3V D35MMXL105MM' AS PartDesc,
		N'VINA TECHNOLOGY' AS MFR,
		N'VEC3R0727QG' AS MPN,
		@pQuantity AS Quantity,
		@pPONumber AS PONumber,
		@pLotNo AS LotNo,
		@rDC AS LotCode,
		@packingDate AS PackingDate,
		@InspEmpID AS InspEmpID,
		@InspEmpName AS InspEmpName,
		CASE	WHEN T.Num < 10 THEN '0' + CONVERT(VARCHAR(3), T.Num) + '/' + @TotalBoxString
				ELSE CONVERT(VARCHAR(3), T.Num) + '/' + @TotalBoxString
			END as CartonBoxNo,
		N'Report' AS CommandType
	FROM #tmp T

	DROP TABLE #tmp
END
GO
