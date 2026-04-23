CREATE PROC [dbo].[usp_MaterialInboundOutbound_interface] @pMaterialDocNo VARCHAR(20), @pMaterialDocType VARCHAR(20), @pMaterialDocTypeCode VARCHAR(20)
AS
BEGIN
	Declare @MaterialDocNo VARCHAR(20), @MaterialDocType VARCHAR(20), @MaterialDocTypeCode VARCHAR(20)

	SET @MaterialDocNo = @pMaterialDocNo
	SET @MaterialDocType = @pMaterialDocType
	SET @MaterialDocTypeCode = @pMaterialDocTypeCode


	DECLARE @Detail TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialTypeCode VARCHAR(20),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		VendorLotNo VARCHAR(100),		-- 2018-08-28 JGH VendorLotNo 추가
		IsUseBarcode BIT,
		IsQC BIT,
		ProcessFixQty NUMERIC(20,5),
		AllowQty NUMERIC(20,5)
	)
	INSERT INTO @Detail
		SELECT
				MDI.MaterialDocNo,
				MDD.MaterialDocDetailNo,
				MDD.MaterialCode,
				MM.MaterialTypeCode,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				MDD.VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
				CONVERT(BIT,ISNULL(MSAI.IsUseBarcode,0)) AS IsUseBarcode,
				CASE 
					WHEN ISNULL(MDD.InspectionType,'NONE') = 'NONE' THEN 0
					ELSE 1
				END  AS IsQC,
				MDD.ProcessFixQty,
				MDD.AllowQty
		FROM
				STB_MaterialDocDetail MDD			
				LEFT OUTER JOIN STB_MaterialDocInfo MDI
					ON	MDI.MaterialDocNo = MDD.MaterialDocNo
				LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI
					ON	MSAI.MaterialCode = MDD.MaterialCode
				LEFT OUTER JOIN STB_MaterialMaster MM
				    ON MDD.MaterialCode = MM.MaterialCode
		WHERE
				MDD.MaterialDocNo = @MaterialDocNo
		GROUP BY
				MDI.MaterialDocType,
				MDI.MaterialDocNo,
				MDD.MaterialDocDetailNo,
				MDD.MaterialCode,
				MM.MaterialTypeCode,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				MSAI.IsUseBarcode,
				MDD.InspectionType,
				MDD.MaterialIqcNo,
				MDD.VendorLotNo,
				MDD.ProcessFixQty,
				MDD.AllowQty -- ProcessFixQty 가 출고의 경우 두배로 잡히는 문제로 일단 허가수량으로 대체함. 이후 변경

	INSERT INTO STB_ERP_INTERFACE (InterfaceName, InterfaceDetailCode, IUD_FLAG, InterfaceFinYn, EIInfText01
	                             , EIInfText03, EIInfReal01, EIInfReal02, EIInfText02, EIInfReal03)
		SELECT @MaterialDocType, @MaterialDocTypeCode, 'INSERT', 'N', MaterialCode
		     , MaterialTypeCode, AllowQty, dbo.fnGetERPUnitPrice(MaterialCode), dbo.fnGetERPCurrencyType(MaterialCode), dbo.fnGetERPConvertPrice(MaterialCode)
		  FROM @Detail
END