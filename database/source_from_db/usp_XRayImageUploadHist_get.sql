
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020-07-09
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_XRayImageUploadHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL,
	@pSystemName Varchar(100) = 'STB_XRayImageUploadHist'
AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	       ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END

	SELECT XIUH.XRayImageUploadHistNo
          ,XIUH.CompanyCode
		  ,CI.CompanyName
          ,XIUH.WorkCenterCode
		  ,WCI.WorkCenterName
          ,XIUH.Barcode
          ,XIUH.XRayImageFileID
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,CONVERT(VARBINARY(MAX),NULL) AS FileData
          ,XIUH.CreateDateTime
          ,XIUH.CreateUserID
          ,XIUH.ChangeDateTime
          ,XIUH.ChangeUserID
	  FROM STB_XRayImageUploadHist XIUH
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	    ON XIUH.XRayImageFileID = AFM.FileID
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = XIUH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = XIUH.WorkCenterCode
	 WHERE XIUH.CompanyCode = @CompanyCode
	   AND XIUH.WorkCenterCode = @WorkCenterCode
	   AND XIUH.Barcode = @Barcode
	   AND AFM.SystemName = @pSystemName
	 ORDER BY XIUH.XRayImageFileID
END
