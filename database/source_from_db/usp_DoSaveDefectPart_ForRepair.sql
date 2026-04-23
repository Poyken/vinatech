
-- =============================================
-- Author:	    Jeon Gyeong Ho (khjun@awoo.co.kr)
-- Create date: 2016-07-22
-- Browsable : true
-- Group : 품질관리
-- Description:	수리내역입력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveDefectPart_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	
	SET NOCOUNT ON;
    
	
	EXEC usp_DefectRepairInfo_iud @pProcessUserID, @pProcessLanguage, 'GetDefectRepairInfoByBarcode_ForRepair', @pXml

	EXEC usp_DefectRepairPartInfo_iud @pProcessUserID, @pProcessLanguage, 'DefectRepairPartInfo_ForRepair', @pXml    
    
END

