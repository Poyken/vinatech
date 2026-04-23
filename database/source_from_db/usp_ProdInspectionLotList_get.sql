-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-10-28
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_ProdInspectionLotList_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo

	SELECT SI.Barcode
	      ,SI.MaterialCode
		  ,MM.MaterialName
		  ,SI.InputLineCode
		  ,SI.InputJobDate
		  ,SI.SIExtText07
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON SI.MaterialCode = MM.MaterialCode
	 WHERE LotNumber = @MaterialQcNo
END