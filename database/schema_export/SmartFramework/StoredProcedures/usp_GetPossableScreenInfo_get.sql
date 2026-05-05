-- Procedure: usp_GetPossableScreenInfo_get






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10-20
-- Browsable : true
-- Group : 시스템
-- Description:	업체멸 메뉴에 추가 가능한 화면리스트정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetPossableScreenInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pSystemCode2 VARCHAR(20) 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage

	DECLARE @SystemCode VARCHAR(20) = @pSystemCode2

	--SELECT
	--		@SystemCode = UI.SystemCode
	--FROM
	--		STB_UserInfo UI WITH (NOLOCK)
	--WHERE
	--		UI.UserID = @pProcessUserID
    
	SELECT
	        SI.Name AS OldName,
	        SI.Name,
	        SI.TCode,
	        SI.IsFolder,
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
			SI.Icon
	FROM
	        STB_ScreenInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)				ON	DSR.Language = @ProcessLanguage AND					DSR.Type = 'AddOn' AND					DSR.Name = SI.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)				ON	SR.Language = @ProcessLanguage AND					SR.Type = 'AddOn' AND					SR.Name = SI.Caption
	WHERE
	        SI.Name NOT IN
				(
					SELECT
							VSI.Name
					FROM
							STB_VendorScreenInfo VSI WITH (NOLOCK)
					WHERE
							VSI.SystemCode = @SystemCode
				) AND
			SI.IsDelete = 0
	ORDER BY
			SI.IsFolder DESC,
			SI.TCode,
			SI.Caption

END







GO

