
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description: 실적별 작업자를 저장/삭제합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteHistByWorker]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdRouteHistNo VARCHAR(20),
	@pWorkerCode VARCHAR(20),
	@pIsDelete BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProdRouteHistNo VARCHAR(20) = @pProdRouteHistNo,
			@WorkerCode VARCHAR(20) = @pWorkerCode,
			@IsDelete BIT = @pIsDelete

	IF @IsDelete = 1 BEGIN
			DELETE FROM	STB_ProdRouteWorkerHist
			WHERE
					ProdRouteHistNo = @ProdRouteHistNo AND
					WorkerCode = @WorkerCode
	END ELSE BEGIN
			IF NOT EXISTS (
							SELECT	1
							FROM
									STB_ProdRouteWorkerHist PRWH
							WHERE
									PRWH.ProdRouteHistNo = @ProdRouteHistNo AND
									PRWH.WorkerCode = @WorkerCode
							) BEGIN
					INSERT INTO STB_ProdRouteWorkerHist
					(
						ProdRouteHistNo,
						WorkerCode	
					)
					VALUES
					(
						@ProdRouteHistNo,
						@WorkerCode
					)
			END
	END	
END

