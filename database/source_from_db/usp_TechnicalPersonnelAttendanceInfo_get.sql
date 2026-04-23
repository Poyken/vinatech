-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 시스템관리
-- Browsable : true
-- Create date : 2019-12-31
-- Description : 출결정보조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_TechnicalPersonnelAttendanceInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pTWorkerCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@TWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pTWorkerCode,'') = '' THEN '*' ELSE @pTWorkerCode END

	SELECT A.AttendanceDate
          ,A.WorkerCode
		  ,PWI.WorkerName
          ,A.AttendanceDateTime
          ,A.LeavingDateTime
		  ,ISNULL(A.IsConfirm, CONVERT(BIT, 0)) AS IsConfirm
          ,A.CreateDateTime
          ,A.ChangeDateTime
	  FROM STB_TechnicalPersonnelAttendanceInfo A
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON A.WorkerCode = PWI.WorkerCode
	 WHERE AttendanceDate BETWEEN @FromDate AND @ToDate
	   AND (@TWorkerCode = '*' OR A.WorkerCode = @TWorkerCode)
END