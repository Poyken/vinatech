-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020-07-09
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_XRayImageFileContents_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXRayImageUploadHistNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @XRayImageUploadHistNo VARCHAR(20) = CASE WHEN ISNULL(@pXRayImageUploadHistNo, '') = '' THEN '*' ELSE @pXRayImageUploadHistNo END
	
	SELECT XIUH.XRayImageUploadHistNo
          ,XIUH.XRayImageFileID
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,AFM.[FileContents] AS FileData
	  FROM STB_XRayImageUploadHist XIUH
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
	    ON XIUH.XRayImageFileID = AFM.FileID
	 WHERE XIUH.XRayImageUploadHistNo = @XRayImageUploadHistNo
END
