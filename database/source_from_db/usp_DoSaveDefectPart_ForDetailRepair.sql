
-- =============================================
-- Author:	    Jeon Gyeong Ho (khjun@awoo.co.kr)
-- Create date: 2016-07-22
-- Browsable : true
-- Group : 품질관리
-- Description:	수리내역입력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveDefectPart_ForDetailRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null,
	@pDefectGroupCode VARCHAR(20) = NULL,
	@pControlNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @DefectGroupCode VARCHAR(20) = @pDefectGroupCode
	       ,@ControlNo VARCHAR(20) = @pControlNo

	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(20),
		UID_KEY VARCHAR(50)
	)    
	
	EXEC usp_DefectRepairInfoForDetail_iud @pProcessUserID, @pProcessLanguage, 'GetDefectRepairInfoByBarcode_ForRepair', @pXml

	EXEC usp_DefectRepairDetailInfo_iud @pProcessUserID, @pProcessLanguage, 'DefectRepairDetailInfo_ForRepair', @pXml
    
	EXEC usp_DefectRepairPartInfo_iud @pProcessUserID, @pProcessLanguage, 'DefectRepairPartInfo_ForRepair', @pXml

	DROP TABLE #SEQUENCE_TABLE

	-- 수리대상이 공정검사 부적합품일 경우 부적합(Holding) 항목을 0(검사부적합이력제품)으로 업데이트 해준다. 2019.09.04 By Jackaroe
	IF @DefectGroupCode = 'RouteInsp' BEGIN -- 공정검사
		UPDATE STB_SetInfo
		   SET SIExtInt01 = 0
		 WHERE ControlNo = @ControlNo
	END
END

