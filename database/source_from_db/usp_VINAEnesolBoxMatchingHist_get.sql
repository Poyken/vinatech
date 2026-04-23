-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-04-16
-- Browsable : true
-- Group : 비나에너솔
-- Description:	대지함 - 소지함 매핑정보를 조회합니다.
-- Modified:
-- =============================================

CREATE PROC usp_VINAEnesolBoxMatchingHist_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pLargeBoxLabelPrintHistNo VARCHAR(20)
AS
BEGIN
	Declare @LargeBoxLabelPrintHistNo VARCHAR(20) = @pLargeBoxLabelPrintHistNo

	-- 결과 조회
	SELECT BLPH.VINAEnesolBoxLabelPrintHistNo
          ,BLPH.MaterialCode
		  ,MM.MaterialName
          ,BLPH.ProdDate
          ,BLPH.ProdWeek
		  ,BC1.Description AS ProdWeekName
          ,BLPH.LastLotNo
		  ,BC2.Description AS LastLotName
          ,BLPH.ProdMachineCode
		  ,BC3.Description AS ProdMachineName
          ,BLPH.ProdLocationCode
		  ,BC4.Description AS ProdLocationName
          ,BLPH.PackingQty
          ,BLPH.LabelQty
          ,BLPH.CustomerPartNo
          ,BLPH.LotNo
          ,BLPH.LabelClassCode
		  ,BC5.Description AS LabelClassName
          ,BLPH.ModelSpec
          ,BLPH.SerialNo
          ,BLPH.Barcode
          ,BLPH.CreateDateTime
          ,BLPH.CreateUserID
          ,BLPH.ChangeDateTime
          ,BLPH.ChangeUserID
		  ,'Report' AS Command
	  FROM STB_VINAEnesolBoxLabelPrintHist BLPH
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = BLPH.MaterialCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.CodeGroup = 'ProdWeek'
	   AND BC1.ItemCode = BLPH.ProdWeek
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'LastLotNo'
	   AND BC2.ItemCode = BLPH.LastLotNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3
	    ON BC3.CodeGroup = 'ProdMachineCode'
	   AND BC3.ItemCode = BLPH.ProdMachineCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4
	    ON BC4.CodeGroup = 'ProdLocationCode'
	   AND BC4.ItemCode = BLPH.ProdLocationCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5
	    ON BC5.CodeGroup = 'LabelClassCode'
	   AND BC5.ItemCode = BLPH.LabelClassCode
	 WHERE VINAEnesolBoxLabelPrintHistNo IN (SELECT SmallBoxLabelPrintHistNo 
	                                           FROM STB_VINAEnesolBoxMatchingHist
											  WHERE LargeBoxLabelPrintHistNo = @LargeBoxLabelPrintHistNo)
END
