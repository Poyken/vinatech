-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-27
-- Group : 생산관리
-- Description:	생산시 사용원자재 Lot 이력을 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_MainAssemblePartWeight_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pControlNo VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ControlNo VARCHAR(20) = @pControlNo

	SELECT
			MAPW.ControlNo,
			MAPW.AsmPartCode,
			MM.MaterialName AS AsmPartName,
			MAPW.AsmMachineCode,
			MCM.MachineName AS AsmMachineName,
			MAPW.AsmWorkerCode,
			PWI.WorkerName AS AsmWorkerName,
			MAPW.AsmQty
	FROM
			STB_MainAssemblePartWeight MAPW WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MAPW.AsmPartCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)
				ON MCM.MachineCode = MAPW.AsmMachineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
				ON PWI.WorkerCode = MAPW.AsmWorkerCode
	WHERE
			MAPW.ControlNo = @ControlNo
END
