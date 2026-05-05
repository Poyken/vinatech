-- View: VW_SupportLanguage





-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10-18
-- Modified: 화면 지원용 언어 정보를 가져옵니다.
-- =============================================
CREATE VIEW [dbo].[VW_SupportLanguage]
AS
		SELECT 'Korean' AS Language
		UNION ALL
		SELECT 'English' AS Language
		UNION ALL
		SELECT 'SimplifiedChinese' AS Language
		UNION ALL
		SELECT 'Japanese' AS Language
		UNION ALL
		SELECT 'Spanish' AS Language
		UNION ALL
		SELECT 'Polish' AS Language
		UNION ALL
		SELECT 'Vietnamese' AS Language
		UNION ALL
		SELECT 'Malay' AS Language
		UNION ALL
		SELECT 'Hindi' AS Language
		UNION ALL
		SELECT 'Czech' AS Language
		UNION ALL
		SELECT 'Bengali' AS Language
		UNION ALL
		SELECT 'Persian' AS Language

GO

