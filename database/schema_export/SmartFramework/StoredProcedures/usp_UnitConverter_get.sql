-- Procedure: usp_UnitConverter_get


-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-24
-- Browsable : true
-- Group : 공통
-- Description:	단위변환정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UnitConverter_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			UC.TargetUnit AS OldTargetUnit,
			UC.TargetUnit,
			UC.BaseUnit,
			UC.ConvertRate,
			UC.UnitType,
			BC.Description AS UnitTypeName
	FROM
			STB_UnitConverter UC WITH(NOLOCK)
			LEFT OUTER JOIN STB_BaseCode BC WITH (NOLOCK)
				ON (BC.CodeGroup = 'UnitType' AND BC.ItemCode = UC.UnitType)

	ORDER BY
			UC.UnitType
END


GO

