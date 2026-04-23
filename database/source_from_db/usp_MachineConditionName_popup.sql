

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 팝업
-- Description:	특정설비의 사출조건항목 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineConditionName_popup]
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MachineCode VARCHAR(20) = @pMachineCode
	
	SELECT
			CONVERT(VARCHAR(2),MCN.ConditionColumnIndex) AS ConditionColumnIndex,
			MCN.ConditionName
	FROM
			STB_MachineConditionName MCN WITH(NOLOCK)
	WHERE
			MCN.MachineCode = @MachineCode
	
END
