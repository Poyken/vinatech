-- ED-VJPMTR000000017
-- =============================================
-- Author : SJC
-- Group : MEA
-- Browsable : true
-- Create date : 2022-08-12
-- Description : MES > 원자재투입
-- Modified :
-- 실행 : usp_MEARawMaterialInputHist_get '','','22418-22D18'
-- =============================================
CREATE PROCEDURE [dbo].[usp_MEARawMaterialInputHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20),
	@pWorkerCode VARCHAR(20)
AS

BEGIN

	SET NOCOUNT ON;

	Declare @Barcode                  VARCHAR(20) = @pBarcode
			, @RawMaterialInputHistNo INT 
			, @SizeCode                 VARCHAR(20)


	  SELECT @SizeCode = BeforeMaterialCode
	  FROM STB_MaterialMaster with(nolock) 
	 WHERE MaterialCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  WHERE Barcode = @Barcode)


	SELECT @RawMaterialInputHistNo = COUNT(*)
	  FROM STB_RawMaterialInputHist with(nolock) 
	 WHERE Barcode = @Barcode

	IF @RawMaterialInputHistNo = 0 
	
	BEGIN
		exec usp_DoMakeMEARawMaterialInputHist @Barcode, @SizeCode
	END

	SELECT RMIH.RawMaterialInputHistNo as RawMaterialInputHistNo
		, RMBI.SizeCode
		, @Barcode AS Barcode
		, RMBI.ProductGroupCode
		, RMBI.ProductGroupName
		, RMIH.RawMaterialBarcode	  
		, RMIH.Qty
		, RMIH.CreateUserID
		, RMIH.CreateDateTime
		, RMIH.ChangeUserID
		, RMIH.ChangeDateTime
		, RMIH.Remark
		, RMIH.RawMaterialBarcode AS OldRawMaterialBarcode
		, RMIH.MEADefectDivCode
		, BC.Description AS MEADefectDivName
		, 'KG' AS MaterialUnit -- 지지체용 표시단위
	  FROM STB_RawMaterialInputHist RMIH with(nolock) 
	  LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     
	    ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   
	   AND RMBI.SizeCode = @SizeCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'MEADefectDivCode'
	   AND BC.ItemCode = RMIH.MEADefectDivCode
	 WHERE RMIH.Barcode = @Barcode
	 ORDER BY RMBI.DisplayIndex, RMBI.ProductGroupCode, RMIH.RawMaterialInputHistNo


END