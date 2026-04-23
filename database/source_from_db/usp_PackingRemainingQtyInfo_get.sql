-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.12.08
-- Browsable : true
-- Group : 제품관리
-- Description: 포장잔량관리
-- ==================================================================================

CREATE PROCEDURE usp_PackingRemainingQtyInfo_get
						@pProcessUserID   Varchar(20),
						@pProcessLanguage Varchar(20),
						@pRackLocationCode CHAR(6) = NULL,
						@pMaterialCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @RackLocationCode CHAR(6) = CASE WHEN RTRIM(ISNULL(@pRackLocationCode, '')) = '' THEN '*' ELSE @pRackLocationCode END
	       ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
	
	SELECT PRQI.PackingRemainingQtyNo
	      ,PRQI.CompanyCode
		  ,CI.CompanyName
		  ,PRQI.WorkCenterCode
		  ,WCI.WorkCenterName
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
          ,PRQI.CreateUserID
          ,PRQI.ChangeDateTime
          ,PRQI.ChangeUserID
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
	   AND (@RackLocationCode = '*' OR PRQI.RackLocationCode = @RackLocationCode)
	   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
	   AND (@Barcode = '*' OR PRQI.Barcode = @Barcode)
	   AND PRQI.PackingRemainingQty > 0
END
