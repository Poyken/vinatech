-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-10-18
-- Browsable : true
-- Group : 생산관리
-- Description:	작업자 인수인계 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkerTakeoverInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE,
	@pTimeShiftCode VARCHAR(10) = NULL,
	@pTakeoverLineCode VARCHAR(20) = NULL

AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@FromDate DATE = @pFromDate
		   ,@ToDate DATE = @pToDate
		   ,@TimeShiftCode VARCHAR(10) = CASE WHEN ISNULL(@pTimeShiftCode, '') = '' THEN '*' ELSE @pTimeShiftCode END
		   ,@TakeoverLineCode VARCHAR(20) = CASE WHEN ISNULL(@pTakeoverLineCode, '') = '' THEN '*' ELSE @pTakeoverLineCode END


	SELECT WTI.WorkerTakeoverNo
          ,WTI.CompanyCode
		  ,CI.CompanyName
          ,WTI.WorkCenterCode
		  ,WCI.WorkCenterName
          ,WTI.JobDate
          ,WTI.TimeShiftCode
		  ,BC.Description AS TimeShiftName
		  ,WTI.TakeoverLineCode
		  ,BC2.Description AS TakeoverLineName
          ,WTI.TakeoverContent
          ,WTI.WriteWorkerCode
		  ,PWI.WorkerName AS WriteWorkerName
          ,WTI.WriteDateTime
          ,WTI.IsConfirm
          ,WTI.ConfirmWorkerCode
		  ,PWI2.WorkerName AS ConfirmWorkerName
          ,WTI.ConfirmDateTime
          ,WTI.CreateDateTime
          ,WTI.CreateUserID
          ,WTI.ChangeDateTime
          ,WTI.ChangeUserID
	  FROM STB_WorkerTakeoverInfo WTI
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = WTI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = WTI.WorkCenterCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'TimeShiftCode'
	   AND BC.ItemCode = WTI.TimeShiftCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON PWI.WorkerCode = WTI.WriteWorkerCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI2
	    ON PWI2.WorkerCode = WTI.ConfirmWorkerCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'TakeoverLineCode'
	   AND BC2.ItemCode = WTI.TakeoverLineCode
	 WHERE (@CompanyCode = '*' OR WTI.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR WTI.WorkCenterCode = @WorkCenterCode)
	   AND JobDate BETWEEN @FromDate AND @ToDate
	   AND (@TimeShiftCode = '*' OR WTI.TimeShiftCode = @TimeShiftCode)
	   AND (@TakeoverLineCode = '*' OR WTI.TakeoverLineCode = @TakeoverLineCode)
END