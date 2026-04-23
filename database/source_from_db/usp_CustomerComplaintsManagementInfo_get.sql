-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Browsable : true
-- Create date: 2020.07.01
-- Description: 고객불만정보
-- usp_CustomerComplaintsManagementInfo_get '','','2025-01-01','2026-02-06', '', ''
-- ==============================================================
CREATE PROCEDURE [dbo].[usp_CustomerComplaintsManagementInfo_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN

	Declare @FromDate DATE = @pFromDate
	       ,@ToDate   DATE = @pToDate
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END

	SELECT 
			--CASE
			--	WHEN CCMI.CustomerComplaintsManagementNo like 'VJQA04SC22-313' THEN 'VJQA04SC22-011'
			--	WHEN CCMI.CustomerComplaintsManagementNo like 'VJQA04SC22-364' THEN 'VJQA04SC22-012'
			--	WHEN CCMI.CustomerComplaintsManagementNo like 'VJQA04SC22-374' THEN 'VJQA04SC22-013'
			--	WHEN CCMI.CustomerComplaintsManagementNo like 'VVQA04PS22-001' THEN  'VJQA04SC22-014'
				
			--	ELSE CCMI.CustomerComplaintsManagementNo
			--END CustomerComplaintsManagementNo
			CCMI.CustomerComplaintsManagementNo
		  ,CCMI.ReceiptDate
		  ,CCMI.CustomerCode
		  ,CI.CustomerName
		  ,CCMI.MaterialCode
		  ,MM.MaterialName
		  ,CCMI.ProductSize
		  ,CCMI.CustomerComplaintsDefectTypeCode
		  ,BC.Description AS CustomerComplaintsDefectTypeName
		  ,CCMI.ProductionCompanyCode
		  ,CI2.CompanyName AS ProductionCompanyName
		  ,CCMI.CustomerComplaintsContents
		  ,CCMI.Barcode
		  ,CCMI.MarkingLetter
		  ,CCMI.DefectQty
		  ,CCMI.ResponsibilityCompanyCode
		  ,BC2.Description AS ResponsibilityCompanyName
		  ,CCMI.CustomerComplaintsDefectCode
		  ,CCDT.CustomerComplaintsDefectName
		  ,CCMI.CauseContents
		  ,CCMI.ActionContents
		  ,CCMI.ActionDocSubmissionDate
		  ,CCMI.ActionDocFileID as ActionDocFileID            -- 기존 대책서 부분 
		 , CCMI.ActionDocFileID as OldActionDocFileID       -- 업데이트문을 위한 대책서 추가부분
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,AFM.FileContents AS FileData
		  --,CONVERT(VARBINARY(MAX),NULL) AS FileData
		  ,CCMI.CreateDateTime
		  ,CCMI.CreateUserID
		  ,CCMI.ChangeDateTime
		  ,CCMI.ChangeUserID
		  ,CCMI.IsPerformance
		  ,CCMI.DefectImage               -- 2021.03.16 추가 이미정
		  ,CI.CIExtText01 AS CustomerArea
		  ,CCMI.IsValidation1
		  ,CCMI.ValidationDocContent1
		  ,CCMI.IsValidation2
		  ,CCMI.ValidationDocContent2
		  ,CCMI.IsValidation3
		  ,CCMI.ValidationDocContent3
		  ,CCMI.CompanyCode
		  ,CI3.CompanyName
		  ,CCMI.WorkCenterCode
		  ,WI2.WorkCenterName
	  FROM STB_CustomerComplaintsManagementInfo CCMI
			  LEFT OUTER JOIN STB_CustomerInfo CI		ON CCMI.CustomerCode = CI.CustomerCode
			  LEFT OUTER JOIN STB_MaterialMaster MM 		ON CCMI.MaterialCode = MM.MaterialCode
			  LEFT OUTER JOIN STB_CustomerComplaintsDefectTypeInfo CCDT		ON CCMI.CustomerComplaintsDefectCode = CCDT.CustomerComplaintsDefectCode
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON BC.ItemCode = CCMI.CustomerComplaintsDefectTypeCode	   AND BC.CodeGroup = 'CustomerComplaintsDefectTypeCode'
			  LEFT OUTER JOIN STB_CompanyInfo CI2		ON CI2.CompanyCode = CCMI.ProductionCompanyCode
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2		ON BC2.ItemCode = CCMI.ResponsibilityCompanyCode	   AND BC2.CodeGroup = 'ResponsibilityCompanyCode'
			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM		ON AFM.FileID = CCMI.ActionDocFileID
			  LEFT OUTER JOIN STB_CompanyInfo CI3 ON CI3.CompanyCode = CCMI.CompanyCode
			  LEFT OUTER JOIN STB_WorkCenterInfo WI2 ON WI2.WorkCenterCode = CCMI.WorkCenterCode
	 WHERE CCMI.ReceiptDate BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR CCMI.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CCMI.WorkCenterCode = @WorkCenterCode)
	   --- phục vụ cho audit
	   AND CCMI.ShowData =1
	   -- AND CCMI.ShowData =1  or CCMI.ShowData is null
	 ORDER BY CustomerComplaintsManagementNo

END