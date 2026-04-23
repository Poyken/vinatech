-- ==================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-20
-- Browsable : true
-- Group : MEA
-- Description: 샘플원자재 투입이력 조회
-- Modified:
-- ====================================================================================
CREATE PROCEDURE usp_MEARawMaterialInputHistForSample_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pRawMaterialBarcode VARCHAR(50) = NULL,
						@pFromDate DATE,
						@pToDate DATE,
						@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @RawMaterialBarcode VARCHAR(50) = CASE WHEN ISNULL(@pRawMaterialBarcode, '') = '' THEN '*' ELSE @pRawMaterialBarcode END
	       ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@FromDate DATE = @pFromDate
		   ,@ToDate DATE = @pToDate

	SELECT MIHFS.MEARawMaterialInputHistNo
          ,MIHFS.InputDate
          ,MIHFS.MaterialCode
		  ,MM.MaterialName
          ,MIHFS.RawMaterialBarcode
          ,MIHFS.InputQty
          ,MIHFS.Remark
          ,MIHFS.CreateDateTime
          ,MIHFS.CreateUserID
          ,MIHFS.ChangeDateTime
          ,MIHFS.ChangeUserID
	  FROM STB_MEARawMaterialInputHistForSample MIHFS
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = MIHFS.MaterialCode
	 WHERE 1=1
	   AND InputDate BETWEEN @FromDate AND @ToDate
	   AND (@RawMaterialBarcode = '*' OR MIHFS.RawMaterialBarcode = @RawMaterialBarcode)
	   AND (@MaterialCode = '*' OR MIHFS.MaterialCode = @MaterialCode)
END