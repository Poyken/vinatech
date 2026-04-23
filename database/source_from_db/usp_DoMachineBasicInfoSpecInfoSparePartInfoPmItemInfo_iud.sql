-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description: 설비 기초, 제원, 스페어파트, 정기점검항목 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMachineBasicInfoSpecInfoSparePartInfoPmItemInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	EXEC usp_MachineBasicInfo_iud @pProcessUserID, @pProcessLanguage, 'MachineBasicInfo', @pXml
	
	EXEC usp_MachineSpecInfo_iud @pProcessUserID, @pProcessLanguage, 'MachineSpecInfo', @pXml
	
	EXEC usp_MachineSparePartInfo_iud @pProcessUserID, @pProcessLanguage, 'MachineSparePartInfo', @pXml
	
	EXEC usp_MachinePmItem_iud @pProcessUserID, @pProcessLanguage, 'MachinePmItem', @pXml
END
