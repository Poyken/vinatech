-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductMoistureMeasureHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pFromDate DATE,
	@pToDate DATE,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END

	SELECT MMH.MoistureMeasureHistNo
		  ,dbo.fnGetLocalTime(MMH.MeasureDate, @pUtcOffset) AS MeasureDate
		  ,MMH.TimeShiftCode
		  ,BC1.Description AS TimeShiftName
		  ,MMH.InspWorkerCode
		  ,PWI.WorkerName AS InspWorkerName
		  ,MMH.CompanyCode
		  ,CI.CompanyName
		  ,MMH.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,MMH.LineCode
		  ,LI.LineDesc AS LineName
		  ,MMH.MachineCode
		  ,MM.MachineName
		  ,MMH.SpecificComment
		  ,PMMH.MaterialCode
		  ,MM2.MaterialName
          ,PMMH.Barcode
          ,PMMH.IsAging
          ,PMMH.AgingCount
          ,PMMH.ProductMoistureValue
          ,PMMH.ActionContents
          ,PMMH.CreateDateTime
          ,PMMH.CreateUserID
          ,PMMH.ChangeDateTime
          ,PMMH.ChangeUserID
		  ,PMMH.Remark
		  ,MMH.SampleWeight
		  ,MMH.KarlFischerImageFileID
		  ,MMH.KarlFischerImageFileID AS OldKarlFischerImageFileID
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,AFM.FileExt
		  ,AFM.FileContents AS FileData
	  FROM STB_MoistureMeasureHist MMH
	  INNER JOIN STB_ProductMoistureMeasureHist PMMH
		ON MMH.MoistureMeasureHistNo = PMMH.MoistureMeasureHistNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
		ON BC1.ItemCode = MMH.TimeShiftCode
	   AND BC1.CodeGroup = 'TimeShiftCode'
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
		ON PWI.WorkerCode = MMH.InspWorkerCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = MMH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON WCI.WorkCenterCode = MMH.WorkCenterCode
	  LEFT OUTER JOIN STB_LineInfo LI
		ON LI.LineCode = MMH.LineCode
	  LEFT OUTER JOIN STB_MachineMaster MM
		ON MM.MachineCode = MMH.MachineCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON MM2.MaterialCode = PMMH.MaterialCode
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	    ON AFM.FileID = MMH.KarlFischerImageFileID
	 WHERE MMH.MeasureDate BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR MMH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MMH.WorkCenterCode = @WorkCenterCode)
	 ORDER BY MMH.MoistureMeasureHistNo
END