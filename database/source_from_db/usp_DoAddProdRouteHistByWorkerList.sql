
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리 > [B530] 제품생산실적입력화면에서 실적완료처리 버튼 클릭시
-- Description: 실적별 작업자들을 등록합니다 /  [usp_DoProcessProdRouteHistForCalc_SmartApp_VNT] 프로시저 중에서 호출되는 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddProdRouteHistByWorkerList]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdRouteHistNo VARCHAR(20),
	@pWorkerCode VARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProdRouteHistNo VARCHAR(20) = @pProdRouteHistNo,
			    @WorkerCode VARCHAR(200) = @pWorkerCode

	DECLARE @WorkerList TABLE
	(
		IDX INT IDENTITY(1,1),
		WorkerCode VARCHAR(20)
	)

	-- INSERT문
	INSERT INTO @WorkerList
	SELECT
			Item
	FROM 
			dbo.fnSplitToTable(',',@WorkerCode)

	DECLARE @Count INT = (SELECT COUNT(*) FROM @WorkerList),
			    @Row INT = 1
	
	WHILE @Count >= @Row BEGIN
			SELECT
					@WorkerCode = WL.WorkerCode
			FROM
					@WorkerList WL
			WHERE
					WL.IDX = @Row
			
			EXEC usp_DoProcessProdRouteHistByWorker	@pProcessUserID = @pProcessUserID,
																	@pProcessLanguage = @pProcessLanguage,
																	@pProdRouteHistNo = @ProdRouteHistNo,
																	@pWorkerCode = @WorkerCode

			SET @Row = @Row + 1
	END
END
