

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-06
-- Browsable : true
-- Group : 시스템
-- Description:	시스템 처리 룰을 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GlobalProcessRule_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRuleCode VARCHAR(50) = NULL,
	@pGroupName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RuleCode VARCHAR(50) = CASE WHEN ISNULL(@pRuleCode,'') = '' THEN '*' ELSE @pRuleCode END
	DECLARE @GroupName NVARCHAR(50) = CASE WHEN ISNULL(@pGroupName,'') = '' THEN '*' ELSE @pGroupName END

    
	SELECT
			GPR.RuleCode AS OldRuleCode,
			GPR.RuleCode,
			GPR.GroupName,
			GPR.RuleName,
			GPR.OptionDesc,
			GPR.SettingValue,
			GPR.CreateDateTime,
			GPR.CreateUserID,
			GPR.ChangeDateTime,
			GPR.ChangeUserID
	FROM
			STB_GlobalProcessRule GPR WITH(NOLOCK)
	WHERE
			((@RuleCode = '*') OR (GPR.RuleCode = @RuleCode)) AND
			((@GroupName = '*') OR (GPR.GroupName = @GroupName)) 

END



