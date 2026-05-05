-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-06
-- Browsable : true
-- Group : 제품관리
-- Description:	일자별 제품재고정보 이력을 생성합니다.
-- Modified: 일자별 재고 생성의 의미라서 날짜를 받는 것이 의미가 없음.
-- =============================================
CREATE PROCEDURE [dbo].[DoCreateProductStockInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBaseDate DATE = NULL
AS
BEGIN
	Declare @BaseDate DATE = CASE WHEN @pBaseDate IS NULL THEN GETDATE() ELSE @pBaseDate END

	-- 기 데이터를 삭제하고,
	DELETE FROM STB_ProductStockInfo WHERE BaseDate = @BaseDate

	INSERT INTO STB_ProductStockInfo (
		BaseDate, ProductStockNo, CompanyCode, WorkCenterCode, MaterialCode
	   ,Barcode, PackingID, MaterialWarehouseCode, MaterialLocationCode, PaletteNo
	   ,StockQty, ManufacturingUnitPrice, CreateDateTime, CreateUserID, ChangeDateTime
	   ,ChangeUserID
	)
	SELECT @BaseDate, ProductStockNo, CompanyCode, WorkCenterCode, MaterialCode
	      ,Barcode, PackingID, MaterialWarehouseCode, MaterialLocationCode, PaletteNo
		  ,StockQty, ManufacturingUnitPrice, CreateDateTime, CreateUserID, ChangeDateTime
		  ,ChangeUserID
	  FROM STB_ProductStockInfoUpload

	-- 1주일 이전 일자 데이터를 삭제
	DELETE FROM STB_ProductStockInfo WHERE BaseDate = DATEADD(day, -7, @BaseDate)
END