-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021.05.28
-- Browsable : true
-- Group : 제품관리
-- Description: 포장잔량관리(출고)
-- ==================================================================================

CREATE PROCEDURE usp_DoRemovePackingRemainingQtyInfo
						@pProcessUserID   Varchar(20),
						@pProcessLanguage Varchar(20),
						@pRackLocationCode CHAR(6) = NULL,
						@pBarcode VARCHAR(20) = NULL,
						@pRemoveQty NUMERIC(20,5) = NULL
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
		   ,@RackLocationCode CHAR(6) = CASE WHEN ISNULL(@pRackLocationCode, '') = '' THEN '*' ELSE @pRackLocationCode END
		   ,@RemoveQty NUMERIC(20,5) = @pRemoveQty
		   ,@PackingRemainingQtyNo VARCHAR(20)

	Declare @PackingRemainingQty NUMERIC(20,5)
	       ,@BarcodeCnt INT

	SELECT @BarcodeCnt = COUNT(*)
	  FROM STB_PackingRemainingQtyInfo
	 WHERE Barcode = @Barcode
	   AND (@RackLocationCode = '*' OR RackLocationCode = @RackLocationCode)

	SELECT @PackingRemainingQty = PackingRemainingQty
	  FROM STB_PackingRemainingQtyInfo
	 WHERE Barcode = @Barcode
	   AND (@RackLocationCode = '*' OR RackLocationCode = @RackLocationCode)


	IF NOT EXISTS (SELECT 1 FROM STB_PackingRemainingQtyInfo WHERE Barcode = @Barcode) BEGIN
		RAISERROR('바코드가 존재하지 않습니다 = %s', 16, 1, @Barcode)
		RETURN
	END

	IF @BarcodeCnt > 1 BEGIN
		RAISERROR('다수의 바코드가 존재합니다. 랙위치코드를 넣어주십시오. = %s', 16, 1, @Barcode)
		RETURN
	END

	IF @PackingRemainingQty < @RemoveQty BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage,'출고수량은 잔량보다 작아야합니다.'
		RETURN
	END

	UPDATE STB_PackingRemainingQtyInfo
	   SET PackingRemainingQty = PackingRemainingQty - @RemoveQty
	 WHERE Barcode = @Barcode
	   AND (@RackLocationCode = '*' OR RackLocationCode = @RackLocationCode)

	SELECT @PackingRemainingQtyNo = PackingRemainingQtyNo
	  FROM STB_PackingRemainingQtyInfo
	 WHERE Barcode = @Barcode
	   AND (@RackLocationCode = '*' OR RackLocationCode = @RackLocationCode)

	SELECT PRQI.PackingRemainingQtyNo
          ,PRQI.RackLocationCode
          ,SI.MaterialCode
		  ,MM.MaterialName
		  ,PRQI.Barcode
          ,PRQI.PackingRemainingQty
		  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) AS PartNo
		  ,'(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')' AS Rating
		  ,MBI.MBIExtText04 AS Voltage
		  ,MBI.MBIExtText05 AS Farad
		  ,'Report' AS CommandType
          ,PRQI.CreateDateTime
	  FROM STB_PackingRemainingQtyInfo PRQI
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON SI.Barcode = PRQI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = PRQI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = PRQI.WorkCenterCode 
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI 
	    ON MBI.ModelCode = SI.MaterialCode
	 WHERE 1=1
	   AND PackingRemainingQtyNo = @PackingRemainingQtyNo

END