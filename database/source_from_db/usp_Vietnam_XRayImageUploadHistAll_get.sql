
-- =============================================
-- Author : Mr.Tung
-- Group : QC
-- Browsable : true
-- Create date : 2022-12-12
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_XRayImageUploadHistAll_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL,
	@pSystemName Varchar(100) = 'STB_XRayImageUploadHist_pqc',
	@pfromDate Datetime=null,
	@ptodate Datetime=null
AS

BEGIN

	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN 'VVT' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN 'VVT_F1' ELSE @pWorkCenterCode END
	       ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END

		   
		   select @CompanyCode=CompanyCode,
		   @WorkCenterCode = WorkCenterCode
		   from STB_UserInfo with(nolock)
		   where UserID=@pProcessUserID


	SELECT  XIUH.XRayImageUploadHistNo
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
		  ,si.MaterialCode
		  ,mm.MaterialName
		  ,si.InputLineCode
		  ,li.LineName
	  FROM STB_XRayImageUploadHist XIUH with(nolock) 
	  left outer join STB_SetInfo si  with(nolock)  on upper(XIUH.Barcode)  = si.Barcode 
	  left outer join STB_LineInfo li with(nolock) on si.InputLineCode = li.LineCode
	  left outer join STB_MaterialMaster mm  with(nolock)  on mm.MaterialCode=si.MaterialCode 
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM  with(nolock) 
	    ON XIUH.XRayImageFileID = AFM.FileID 
	  LEFT OUTER JOIN STB_CompanyInfo CI  with(nolock)  ON CI.CompanyCode = XIUH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI  with(nolock)  ON WCI.WorkCenterCode = XIUH.WorkCenterCode
	 WHERE XIUH.CompanyCode = @CompanyCode
	   AND XIUH.WorkCenterCode = @WorkCenterCode
	   and XIUH.CreateDateTime between dateadd(hour,10,@pfromDate) and dateadd(hour,10,dateadd(day,1,@ptodate))
	   AND AFM.SystemName = @pSystemName
	 ORDER BY XIUH.XRayImageFileID
END
