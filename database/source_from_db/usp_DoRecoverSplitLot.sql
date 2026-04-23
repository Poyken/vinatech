-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2025-03-11
-- Description: Split된 박스를 원복합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRecoverSplitLot]
	 	@pProcessLanguage VARCHAR(20),
	    @pProcessUserID VARCHAR(20),
	    @pPackingID VARCHAR(20)
AS
BEGIN
	Declare @PackingID VARCHAR(20) = @pPackingID
	       ,@OriginalPackingID VARCHAR(20) 
		   ,@TotQty INT

	Declare @TargetData TABLE (
		OriginalPackingID VARCHAR(20)
	   ,NewPackingID VARCHAR(20)
	   ,Qty INT
	);


	-- 입력된 PackingID로 원본 PackingID를 찾아 페어를 구한다.
	INSERT INTO @TargetData
		SELECT OriginalPackingID, NewPackingID, B.CurrentQty
		  FROM STB_PackingBoxChangeHist A
		  INNER JOIN STB_MaterialLotInfo B
		    ON A.NewPackingID = B.PackingID
		 WHERE A.OriginalPackingID IN (
									SELECT OriginalPackingID
									  FROM STB_PackingBoxChangeHist
									 WHERE NewPackingID  = @PackingID
								)

	IF NOT EXISTS (SELECT 1 FROM @TargetData) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '패킹ID의 분리 이력이 존재하지 않습니다. 패킹ID를 확인하시기 바랍니다.'

		RETURN
	END

	SELECT @TotQty = SUM(Qty)
	      ,@OriginalPackingID = MAX(OriginalPackingID)
	  FROM @TargetData

	-- 선택된 Packing ID 의 수량을 업데이트하고,

	UPDATE
			STB_MaterialLotInfo
	SET
			CurrentQty = @TotQty,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			PackingID = @PackingID

	-- 분할 했던 박스 중 하나를 삭제하여 최종 수량을 맞춤.
	DELETE FROM STB_MaterialLotInfo 
	 WHERE PackingID IN (SELECT NewPackingID FROM @TargetData)
	   AND PackingID <> @PackingID

	-- 분할 이력에서 오리지널 패킹 ID를 삭제함.
	DELETE FROM STB_PackingBoxChangeHist WHERE OriginalPackingID = @OriginalPackingID
END