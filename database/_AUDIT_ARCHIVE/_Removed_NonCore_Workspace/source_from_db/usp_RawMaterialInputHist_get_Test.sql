-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-10-30
-- Description : 생산관리 > 실적등록 > 자주검사/원자재투입 > 원자재투입이력
-- Modified :

-- 실행 : usp_RawMaterialInputHist_get '','','VJKK093R050708'
-- =============================================
Create PROCEDURE [dbo].[usp_RawMaterialInputHist_get_Test]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20)
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@RawMaterialInputHist INT 
		   ,@SizeCode VARCHAR(20) 

	SELECT @SizeCode = CASE WHEN MBISizeW IN (8, 10) THEN 'Small'
	                        WHEN MBISizeW IN (13, 16, 18) THEN 'Middle'
							WHEN MBISizeW IN (22, 25, 27, 30, 35) THEN 'Large'
							ELSE NULL END
	  FROM STB_ModelBasicInfo
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)

	SELECT @RawMaterialInputHist = COUNT(*)
	  FROM STB_RawMaterialInputHist
	 WHERE Barcode = @Barcode

	IF @RawMaterialInputHist = 0 BEGIN
		exec usp_DoMakeRawMaterialInputHist @Barcode, @SizeCode
	END

	SELECT RMIH.RawMaterialInputHistNo
	      ,RMBI.SizeCode
	      ,@Barcode AS Barcode
	      ,RMBI.ProductGroupCode
		  ,RMBI.ProductGroupName
		  ,RMIH.RawMaterialBarcode
		  ,RMIH.CreateUserID
		  ,RMIH.CreateDateTime
		  ,RMIH.ChangeUserID
		  ,RMIH.ChangeDateTime
		  ,RMBI.ProductGroupName_VVT                  -- 2020.02.14 추가 (베트남법인)
	  FROM STB_RawMaterialInputHist RMIH
			 LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	    ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode
	 WHERE Barcode = @Barcode
	 ORDER BY RMBI.DisplayIndex, RMIH.RawMaterialInputHistNo



END

