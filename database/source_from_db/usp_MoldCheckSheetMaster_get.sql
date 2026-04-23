
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형체크시트마스터 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckSheetMaster_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldCheckSheetName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldCheckSheetName NVARCHAR(100) = CASE WHEN ISNULL(@pMoldCheckSheetName,'') = '' THEN '*' ELSE @pMoldCheckSheetName END

    
	SELECT
	        MCSM.MoldCheckSheetCode AS OldMoldCheckSheetCode,
	        MCSM.MoldCheckSheetCode,
	        MCSM.MoldCheckSheetName,
	        MCSM.MoldCheckTypeCode,
	        MCT.MoldCheckTypeName,
	        MCT.MoldCheckTypeDesc,
	        
	        MCSM.MoldImage,
	        AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
	        
	        MCSM.CheckDesc,
	        MCSM.CreateDateTime,
	        MCSM.CreateUserID,
	        MCSM.ChangeDateTime,
	        MCSM.ChangeUserID
	FROM
	        STB_MoldCheckSheetMaster MCSM WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldCheckType MCT WITH(NOLOCK)
				ON MCSM.MoldCheckTypeCode = MCT.MoldCheckTypeCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = MCSM.MoldImage
	WHERE
	        ((@MoldCheckSheetName = '*') OR (MCSM.MoldCheckSheetName = @MoldCheckSheetName)) 

END



