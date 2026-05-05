-- Procedure: usp_GetCompatibleUnit

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 공통
-- Description:	단위유형정보를 가져옵니다(popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCompatibleUnit]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUnitCode VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @UnitCode VARCHAR(20) = @pUnitCode

	DECLARE @UnitType VARCHAR(20) 

	SELECT
			TOP 1
			@UnitType = UC.UnitType
	FROM
			STB_UnitConverter UC
	WHERE
			UC.BaseUnit = @UnitCode OR
			UC.TargetUnit = @UnitCode

	SELECT
			DISTINCT UC.UnitCode
	FROM
		(
			SELECT
					UC.TargetUnit AS UnitCode
			FROM
					STB_UnitConverter UC WITH (NOLOCK)
			WHERE
					UC.UnitType = @UnitType
			UNION ALL
			SELECT
					UC.BaseUnit AS UnitCode
			FROM
					STB_UnitConverter UC WITH (NOLOCK)
			WHERE
					UC.UnitType = @UnitType
		) UC
END

GO

