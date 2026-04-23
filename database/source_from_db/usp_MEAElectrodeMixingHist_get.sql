-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-11-04
-- Browsable : true
-- Group : MEA
-- Description:	MEA전극믹싱이력을 조회합니다.
-- Modified:
-- =============================================

CREATE Proc [dbo].[usp_MEAElectrodeMixingHist_get] 
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	-- Barcode 존재여부 체크
	IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = @Barcode) BEGIN
		RAISERROR('Lot번호가 존재하지 않습니다. :  %s', 16, 1, @Barcode)
	END

	SELECT @Barcode AS Barcode
		  ,ISNULL(MEMH.MEAMixingStepCode, BC.ItemCode) AS MEAMixingStepCode
		  ,@Barcode AS OldBarcode
		  ,ISNULL(MEMH.MEAMixingStepCode, BC.ItemCode) AS OldMEAMixingStepCode
		  ,BC.Description AS MEAMixingStepName
          ,MEMH.StartDateTime
          ,MEMH.EndDateTime
          ,MEMH.MachineCode
		  ,MM.MachineName
          ,MEMH.CreateDateTime
          ,MEMH.CreateUserID
          ,MEMH.ChangeDateTime
          ,MEMH.ChangeUserID
	  FROM SmartFramework.dbo.STB_BaseCode BC
	  LEFT OUTER JOIN STB_MEAElectrodeMixingHist MEMH
	    ON BC.CodeGroup = 'MEAMixingStepCode'
	   AND BC.ItemCode = MEMH.MEAMixingStepCode
	   AND MEMH.Barcode = @Barcode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = MEMH.MachineCode
	 WHERE 1=1
	   AND BC.CodeGroup = 'MEAMixingStepCode'
	 ORDER BY BC.ItemCode
END