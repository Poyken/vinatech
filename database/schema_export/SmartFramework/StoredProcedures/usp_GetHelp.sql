-- Procedure: usp_GetHelp







-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-22
-- Description:	도움말 컨텐츠를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetHelp]
	@pId VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id BIGINT = @pId

    SELECT
			H.Id,
			H.ParentId,
			ISNULL(HL.Title, H.Title) AS Title,			
			ISNULL(HL.Contents,H.Contents) AS Contents,
			H.CreateDateTime,
			H.CreateUserID,
			ISNULL(HL.ChangeDateTime,H.ChangeDateTime) AS ChangeDateTime,
			ISNULL(HL.ChangeUserID,H.ChangeUserID) AS ChangeUserID
	FROM
			STB_Help H WITH(NOLOCK)
			LEFT OUTER JOIN STB_HelpLanguage HL WITH(NOLOCK)
				ON	HL.Id = H.Id
	WHERE
			H.Id = @Id
END








GO

