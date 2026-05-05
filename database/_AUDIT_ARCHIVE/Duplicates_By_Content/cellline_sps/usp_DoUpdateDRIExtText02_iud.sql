-- ==================================================================
-- Author      : Jackaroe(yjyu@vina.co.kr)
-- Create date : 2020-08-27
-- Browsable   : true
-- Group       : 생산관리
-- Description : 불량비고 업데이트 (불량 등록 시 입력하지 못한 불량 비고를 불량 등록 이후 업데이트 합니다.)
-- Modified    : 
-- ==================================================================

CREATE PROC usp_DoUpdateDRIExtText02_iud
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pDefectSummaryNo VARCHAR(20),
				@pDRIExtText02 NVARCHAR(400) = NULL                                  
AS
BEGIN
	Declare @DefectSummaryNo VARCHAR(20) = @pDefectSummaryNo
	       ,@DRIExtText02 NVARCHAR(400) = @pDRIExtText02

	UPDATE STB_DefectRepairInfo
	   SET DRIExtText02 = @DRIExtText02
	 WHERE DefectSummaryNo = @DefectSummaryNo
END