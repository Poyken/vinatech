-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020.06.30
-- Description : 
-- Modified :
-- ============================================= usp_ElectrolyteMoistureMeasureHist_get '','',1,'2025-05-01','2025-12-30','VVT','VVT_F1'
CREATE PROCEDURE [dbo].[usp_ElectrolyteMoistureMeasureHist_get]
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
		  --,case when @CompanyCode<>'VVT' then MMH.MeasureDate 
				--else dateadd(DAY,1,MMH.MeasureDate) end as MeasureDate --for Vietnam true hour from QC manager require  -- Mr.Tung on 17-November-2020

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
		  ,LI.LineType
		  ,MMH.MachineCode
		  ,MM.MachineName
		  ,MMH.SpecificComment
		  ,EMMH.ProductSizeCode
		  ,EMMH.Temperature
		  ,EMMH.DewPoint
		  ,EMMH.ElectrolyteMoistureValue
		  ,EMMH.IsPass
		  ,EMMH.IsMaterial
		  ,EMMH.CreateDateTime
		  ,EMMH.CreateUserID
		  ,EMMH.ChangeDateTime
		  ,EMMH.ChangeUserID
		  ,EMMH.Remark
		  ,MMH.SampleWeight
		  ,EMMH.MaterialCode
		  ,MM2.MaterialName
		  ,MMH.KarlFischerImageFileID
		  ,MMH.KarlFischerImageFileID AS OldKarlFischerImageFileID
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,AFM.FileExt
		  ,AFM.FileContents AS FileData
	  FROM STB_MoistureMeasureHist MMH
	  INNER JOIN STB_ElectrolyteMoistureMeasureHist EMMH
		ON MMH.MoistureMeasureHistNo = EMMH.MoistureMeasureHistNo
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
	    ON MM2.MaterialCode = EMMH.MaterialCode
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	    ON AFM.FileID = MMH.KarlFischerImageFileID
	 WHERE MMH.MeasureDate BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR MMH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MMH.WorkCenterCode = @WorkCenterCode)

	   --and (
	   --ElectrolyteMoistureValue<150   -- MR TUNG , audit Hela 2022-09-28
	   --or ElectrolyteMoistureValue >= 150
	   --and ( MMH.createdatetime>'2022-09-28 18:00:00' or MMH.ChangeDateTime>'2022-09-28 18:00:00')
	   --)

	   --AND EMMH.ElectrolyteMoistureValue < 100 -- 삼성심사 대응 2021.12.09
	   --AND MMH.LineCode Not In ('ASSYLINE-02')  -- 삼성심사 대응 2022.01.19
	 ORDER BY MMH.MoistureMeasureHistNo
END