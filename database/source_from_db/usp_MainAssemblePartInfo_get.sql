-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-14
-- Group : 생산관리
-- Description:	생산시 사용원자재 Lot 이력을 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_MainAssemblePartInfo_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pControlNo VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ControlNo VARCHAR(20) = @pControlNo

	SELECT
			MAPI.ControlNo,
			MAPI.AsmSeqNo,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MAPI.AsmPartCode,
			MM.MaterialName AS AsmPartName,
			MAPI.AsmPartBarcode,
			MAPI.AsmPartSerialNo,
			MAPI.AsmLotNo,
			MAPI.AsmJobDate,
			MAPI.AsmShiftCode,
			MAPI.AsmDateTime,
			MAPI.AsmMachineCode,
			MCM.MachineName AS AsmMachineName,
			MAPI.AsmQty,
			MAPI.AsmWorkerCode,
			PWI.WorkerName AS AsmWorkerName,
			MAPI.CreateDateTime,
			MAPI.CreateUserID
	FROM
			STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = MAPI.ControlNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MAPI.AsmPartCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)
				ON MCM.MachineCode = MAPI.AsmMachineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
				ON PWI.WorkerCode = MAPI.AsmWorkerCode
	WHERE
			MAPI.ControlNo = @ControlNo
END
