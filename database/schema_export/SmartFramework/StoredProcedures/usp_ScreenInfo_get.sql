-- Procedure: usp_ScreenInfo_get






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-29
-- Browsable : true
-- Group : 시스템
-- Description:	화면리스트정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ScreenInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pName VARCHAR(50) = NULL,
    @pCaption NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
      DECLARE @Name VARCHAR(50) = CASE WHEN ISNULL(@pName,'') = '' THEN '*' ELSE @pName END
      DECLARE @Caption NVARCHAR(100) = CASE WHEN ISNULL(@pCaption,'') = '' THEN '*' ELSE @pCaption END

    
	SELECT
	        SI.Name AS OldName,
	        SI.Name,
	        SI.TCode,
	        SI.IsFolder,
			SI.IsDialog,
	        SI.IsNeverClose,
	        SI.ParentName,
	        SI.Caption,
			ISNULL(ISNULL(SR.Value, DSR.Value), SI.Caption) AS DisplayText,
	        SI.ShowAfterStart,
	        SI.ShowInMenu,
	        SI.CurrentVersion,
	        SI.CreateDateTime,
	        SI.CreateUserID,
	        SI.ChangeDateTime,
	        SI.ChangeUserID,
	        SI.IsDelete,
	        SI.DeleteDateTime,
	        SI.DeleteUserID,
			SI.AccessType,
			SI.Icon,
			SI.SystemCode
	FROM
	        STB_ScreenInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)
				ON	DSR.Language = @ProcessLanguage AND
					DSR.Type = 'AddOn' AND
					DSR.Name = SI.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @ProcessLanguage AND
					SR.Type = 'AddOn' AND
					SR.Name = SI.Caption
	WHERE
	        ((@Name = '*') OR (SI.Name = @Name)) AND
	        ((@Caption = '*') OR (SI.Caption = @Caption)) 
	ORDER BY
			SI.IsFolder DESC,
			SI.TCode,
			SI.Caption

END







GO

