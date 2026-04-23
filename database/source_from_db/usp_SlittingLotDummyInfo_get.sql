-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-09
-- Browsable : true
-- Group : 생산관리
-- Description:	슬리팅결과입력을 위한 더미
-- =============================================
CREATE PROCEDURE [dbo].[usp_SlittingLotDummyInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
	       ,@ElectrodeThick NUMERIC(20,5)
		   ,@GoodQtyLength NUMERIC(20,5)
	SELECT @ElectrodeThick = MaterialThickness
	  FROM STB_MaterialMaster
	 WHERE MaterialCode IN (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @pElectrodeLotNumber)

	SELECT @ElectrodeLotNumber AS ElectrodeLotNumber
	      ,CONVERT(INT, @ElectrodeThick) AS ElectrodeThick
		  ,'' AS MaterialCode
		  ,0.0 AS SlittingWidth
		  ,0 AS SlittingQty
		  ,0.0 AS GoodQtyLength
END