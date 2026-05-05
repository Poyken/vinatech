-- Procedure: usp_MenuUsedHistory_get







-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 시스템
-- Description:	사용자 사용 이력을 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MenuUsedHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pFromUseDate DATE = NULL,
    @pToUseDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @FromUseDate DATE = @pFromUseDate
      DECLARE @ToUseDate DATE = @pToUseDate

	IF @FromUseDate IS NULL
		SET @FromUseDate = GETDATE()
	IF @ToUseDate IS NULL
		SET @ToUseDate = GETDATE()
    
	SELECT
	        CONVERT(VARCHAR(10), MUH.UseDate, 120) AS UseDate,
	        MUH.UserID,
	        UI.UserName,
	        MUH.Name,
	        ISNULL(SR.Value,SI.Caption) AS Caption,
	        MUH.UsedCount
	FROM
	        STB_MenuUsedHistory MUH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_UserInfo UI WITH (NOLOCK)
				ON ( UI.UserID = MUH.UserID)
			LEFT OUTER JOIN STB_ScreenInfo SI
				ON (SI.Name = MUH.Name)
			LEFT OUTER JOIN STB_StringResources SR
				ON (SR.Language = @pProcessLanguage AND SR.Name = SI.Caption)
	WHERE
	        (MUH.UseDate BETWEEN @FromUseDate AND @ToUseDate) 
	ORDER BY
			MUH.UseDate,
			UI.UserName,
			SI.Caption

END








GO

