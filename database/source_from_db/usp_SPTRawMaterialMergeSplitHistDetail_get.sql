-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-16
-- Browsable : true
-- Group : 지지체
-- Description: 원재재소분이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_SPTRawMaterialMergeSplitHistDetail_get
	@pProcessLanguage VARCHAR(20) 
   ,@pProcessUserID VARCHAR(20)
   ,@pMergeLotID VARCHAR(50) = NULL
AS
BEGIN
	Declare @MergeLotID VARCHAR(50) = @pMergeLotID

	SELECT MergeLotID
	      ,OriginalLotID
	  FROM STB_SupportRawMaterialMergeHist
	 WHERE MergeLotID = @MergeLotID
	 ORDER BY MergeLotID, OriginalLotID
END