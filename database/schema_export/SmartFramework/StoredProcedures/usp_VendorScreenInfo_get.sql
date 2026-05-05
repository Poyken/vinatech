-- Procedure: usp_VendorScreenInfo_get






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-29
-- Browsable : true
-- Group : 시스템
-- Description:	업체별화면리스트정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VendorScreenInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pSystemCode VARCHAR(20),
    @pName VARCHAR(50) = NULL,
    @pCaption NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @SystemCode VARCHAR(20) = CASE WHEN ISNULL(@pSystemCode, '') = '' THEN '*' ELSE @pSystemCode END
    DECLARE @Name VARCHAR(50) = CASE WHEN ISNULL(@pName,'') = '' THEN '*' ELSE @pName END
    DECLARE @Caption NVARCHAR(100) = CASE WHEN ISNULL(@pCaption,'') = '' THEN '*' ELSE @pCaption END

    
	SELECT
			VSI.SystemCode,
			VSI.SystemCode AS OldSystemCode,
	        VSI.Name AS OldName,
	        VSI.Name,
	        VSI.TCode,
	        VSI.IsFolder,
	        VSI.IsNeverClose,
	        VSI.ParentName,
	        VSI.Caption,
			ISNULL(ISNULL(SR.Value, DSR.Value), VSI.Caption) AS DisplayText,
	        VSI.ShowAfterStart,
	        VSI.ShowInMenu,
	        VSI.CurrentVersion,
	        VSI.CreateDateTime,
	        VSI.CreateUserID,
	        VSI.ChangeDateTime,
	        VSI.ChangeUserID,
	        VSI.IsDelete,
	        VSI.DeleteDateTime,
	        VSI.DeleteUserID,
			VSI.AccessType,
			VSI.Icon
	FROM
	        STB_VendorScreenInfo VSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)				ON	DSR.Language = @ProcessLanguage AND					DSR.Type = 'AddOn' AND					DSR.Name = VSI.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)				ON	SR.Language = @ProcessLanguage AND					SR.Type = 'AddOn' AND					SR.Name = VSI.Caption
	WHERE
			((@SystemCode = '*') OR (VSI.SystemCode = @SystemCode)) AND
	        ((@Name = '*') OR (VSI.Name = @Name)) AND
	        ((@Caption = '*') OR (VSI.Caption = @Caption)) 
	ORDER BY
			VSI.IsFolder DESC,
			VSI.TCode,
			VSI.Caption

END







GO

