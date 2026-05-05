-- Procedure: usp_CheckMachineLabelInfo_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-13
-- Browsable : true
-- Group : 생산관리
-- Description:	일상점검 QR코드 일괄출력
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_CheckMachineLabelInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLineCode VARCHAR(20)
AS
BEGIN
	Declare @LineCode VARCHAR(20) = @pLineCode

	SELECT CSI.LineCode
	      ,CSI.MachineCode
		  ,ISNULL(MM.MachineName, '기타') AS MachineName
		  ,'http://nais.hycap.co.kr:8088/CheckSheetForWorkerQR.do?lineCode=' + REPLACE(CSI.LineCode, ' ', '%20') + '&machineCode=' + CSI.MachineCode AS CheckUrl
		  ,'Report' AS CommandType
	  FROM STB_CheckStandardInfo CSI
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON CSI.MachineCode = MM.MachineCode
	 WHERE CSI.LineCode = @LineCode
	   AND CSI.IsUsed = CONVERT(BIT, 1)
	 GROUP BY CSI.LineCode, CSI.MachineCode, MM.MachineName
	 ORDER BY CASE WHEN ISNULL(CSI.MachineCode, '') = '' THEN 'ZZZ' ELSE CSI.MachineCode END ASC
END
GO

