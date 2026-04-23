

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 팝업
-- Description:	 생산실적에서 일계획일련번호 변경시에 팝업에서 작업일자,교대조,설비에 해당하는 일계획일련번호 목록 가져오기
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProdPlanNo_popup]
	@pJobDate DATE = NULL,
	@pShiftCode VARCHAR(1) = NULL,
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @JobDate DATE = @pJobDate
	DECLARE @ShiftCode VARCHAR(1) = @pShiftCode
	DECLARE @MachineCode VARCHAR(20) = @pMachineCode

    SELECT
			DPP.DayPlanNo,
			DPP.MoldNumber,
			MBI.MoldTypeCode,
			MTI.MoldTypeName,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.RawMaterial
	FROM
			STB_DayProdPlan DPP WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = DPP.MoldNumber
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MBI.MoldTypeCode = MTI.MoldTypeCode
				
	WHERE
			DPP.PlanDate = @JobDate
			AND DPP.PlanShiftCode = @ShiftCode
			AND DPP.MachineCode = @MachineCode
END



