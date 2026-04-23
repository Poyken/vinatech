-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-10-26
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ModuleSemiProductionInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pGrade VARCHAR(10) = NULL
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@Grade VARCHAR(10) = CASE WHEN ISNULL(@pGrade, '') = '' THEN '*' ELSE @pGrade END

	SELECT MSPI.ModuleSemiProductionNo
          ,MSPI.ProdDate
          ,MSPI.Grade
          ,MSPI.PCBLotNo
          ,MSPI.SemiProdLotNo
          ,MSPI.SingleCellLotNo1
          ,MSPI.SingleCellLotNo2
          ,MSPI.SingleCellLotNo3
          ,MSPI.Remark
          ,MSPI.CreateDateTime
          ,MSPI.CreateUserID
          ,MSPI.ChangeDateTime
          ,MSPI.ChangeUserID
	  FROM STB_ModuleSemiProductionInfo MSPI
	 WHERE MSPI.ProdDate BETWEEN @FromDate AND @ToDate
	   AND (@Grade = '*' OR MSPI.Grade = @Grade)
	 ORDER BY MSPI.ProdDate
END