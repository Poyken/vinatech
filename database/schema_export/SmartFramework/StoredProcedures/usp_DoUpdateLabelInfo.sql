-- Procedure: usp_DoUpdateLabelInfo


-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr
-- Create date: 2016.05.17
-- Description:	라벨정보를 등록합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateLabelInfo]
	@pLabelType NVARCHAR(30),
	@pCommandType VARCHAR(20),
	@pDpi VARCHAR(20),
	@pFormatName NVARCHAR(30),
	@pFormatVersion INT,
	@pFormat NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE 
			STB_LabelInfo
	SET
			Format = @pFormat,
			ChangeDateTime = GETDATE()

	WHERE
			LabelType = @pLabelType AND
			CommandType = @pCommandType AND
			Dpi = @pDpi AND
			FormatName = @pFormatName AND
			FormatVersion = @pFormatVersion
END




GO

