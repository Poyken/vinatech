-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-08
-- Browsable : true
-- Group : 지지체
-- Description:	지지체 원자재 소분 시뮬레이션 결과
-- Modified:
-- =============================================
CREATE PROCEDURE usp_SPTRawMaterialSplitHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotID VARCHAR(50)
AS
BEGIN
	Declare @LotID VARCHAR(50) = @pLotID

	SELECT SRSH.MergeLotID
          ,SRSH.SplitLotID
          ,SRSH.TotalCurrentQty
		  ,SRSH.SplitQty
          ,SRSH.IsFixed
          ,SRSH.CreateDateTime
          ,SRSH.CreateUserID
          ,SRSH.ChangeDateTime
          ,SRSH.ChangeUserID
	  FROM STB_SupportRawMaterialSplitHist SRSH
	 WHERE MergeLotID IN (SELECT MergeLotID 
	                        FROM STB_SupportRawMaterialMergeHist 
						   WHERE OriginalLotID = @LotID)
END
