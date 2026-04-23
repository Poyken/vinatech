-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-12-10
-- Browsable : true
-- Group : 생산관리
-- Description:	포장잔량데이터 입력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessPackingRemainQtyInfo]
	@pRackIndex VARCHAR(20),
	@pRowIndex VARCHAR(20),
    @pColumnIndex VARCHAR(20),
	@pLotNo VARCHAR(20),
	@pPackingRemainQty VARCHAR(20)
AS
BEGIN
	Declare @RackIndex VARCHAR(20) = CONVERT(INT, @pRackIndex),
	        @RowIndex VARCHAR(20) = CONVERT(INT, @pRowIndex),
            @ColumnIndex VARCHAR(20) = CONVERT(INT, @pColumnIndex),
	        @LotNo VARCHAR(20) = @pLotNo,
	        @PackingRemainQty VARCHAR(20) = CONVERT(INT, @pPackingRemainQty),
			@PackingRemainingQtyNo VARCHAR(20)

	-- 존재하면, 출고처리
	IF EXISTS (SELECT 1 
	             FROM STB_PackingRemainingQtyInfo 
	            WHERE RackIndex = @RackIndex
				  AND LocationRowIndex = @RowIndex
				  AND LocationColumnIndex = @ColumnIndex) 
	BEGIN
		DELETE 
		  FROM STB_PackingRemainingQtyInfo
		 WHERE RackIndex = @RackIndex
		   AND LocationRowIndex = @RowIndex
		   AND LocationColumnIndex = @ColumnIndex
	END ELSE BEGIN -- 데이터가 없으면 입고처리
		EXEC usp_DoCreateSerial 'STB_PackingRemainingQtyInfo',@PackingRemainingQtyNo OUTPUT

		INSERT INTO STB_PackingRemainingQtyInfo (PackingRemainingQtyNo, CompanyCode, WorkCenterCode, Barcode, RackIndex
		                                       , LocationRowIndex, LocationColumnIndex, PackingRemainingQty)
			SELECT @PackingRemainingQtyNo, 'VNT', 'VNT_F1', @LotNo, @RackIndex
			     , @RowIndex, @ColumnIndex, @PackingRemainQty
	END
END