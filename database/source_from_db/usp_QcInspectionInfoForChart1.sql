-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-25
-- Browsable : true
-- Group : 생산관리
-- Description:	품질공정검사 결과 조회(A)
-- =============================================
CREATE PROC [dbo].[usp_QcInspectionInfoForChart1] 
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pFromDt DateTime,
	@pToDt DateTime,
	@pMaterialCode VARCHAR(20) = NULL,
	@pChart1 VARCHAR(10) = NULL,
	@pChart2 VARCHAR(10) = NULL,
	@pChart3 VARCHAR(10) = NULL,
	@pChart4 VARCHAR(10) = NULL,
	@pDiv VARCHAR(10) = 'QC'
AS
BEGIN 
	Declare @FromDt VARCHAR(10) = CONVERT(VARCHAR(10), @pFromDt, 121)
	       ,@ToDt VARCHAR(10) = CONVERT(VARCHAR(10), @pToDt, 121)
		   ,@MaterialCode VARCHAR(20) = CASE WHEN @pMaterialCode IS NULL THEN '%' ELSE @pMaterialCode END
		   ,@Chart1 VARCHAR(20) = CASE WHEN @pChart1 IS NULL THEN '%' ELSE @pChart1 END
		   ,@Chart2 VARCHAR(20) = CASE WHEN @pChart2 IS NULL THEN '%' ELSE @pChart2 END
		   ,@Chart3 VARCHAR(20) = CASE WHEN @pChart3 IS NULL THEN '%' ELSE @pChart3 END
		   ,@Chart4 VARCHAR(20) = CASE WHEN @pChart4 IS NULL THEN '%' ELSE @pChart4 END
		   ,@Div VARCHAR(10) = @pDiv

	 IF @Div = 'QC' BEGIN
		exec ERPSVR.VINATech.dbo.usp_QcInspectionInfoForChart @FromDt, @ToDt, @MaterialCode, @Chart1
	END ELSE BEGIN
		exec ERPSVR.VINATech.dbo.usp_SelfInspectionInfoForChart2 @FromDt, @ToDt, @MaterialCode, @Chart1
	END
END