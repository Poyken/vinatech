
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-03-28
-- Description:	자재발주상세순번으로 자재납품 현재상태에 따른 발주전표취소 가능여부 확인
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialDeliveryCurrentStatusIsCancelMaterialOrder]
	@pMaterialOrderNo VARCHAR(20)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @MaterialOrderNo VARCHAR(20)
	SET @MaterialOrderNo = @pMaterialOrderNo
	
	DECLARE @tbMaterialOrderItem TABLE
	(
		SeqNo INT IDENTITY,
		MaterialOrderNo VARCHAR(20),
		MaterialOrderItemNo VARCHAR(20)
	)
	
	INSERT INTO @tbMaterialOrderItem
	SELECT
			MOI.MaterialOrderNo,
			MOI.MaterialOrderItemNo
	FROM
			STB_MaterialOrderItem MOI
	WHERE
			MOI.MaterialOrderNo = @MaterialOrderNo
	ORDER BY
			MaterialOrderItemNo
			
	
	DECLARE @MaterialOrderItemNo  VARCHAR(20),
			@CurrentRowNumber INT,
			@MaterialOrderItemCnt INT,
			@DeliveryStatus VARCHAR(10)
	
	SET @CurrentRowNumber = 1
	SET @MaterialOrderItemCnt = (SELECT COUNT(*) FROM @tbMaterialOrderItem)
	
	
	WHILE(@CurrentRowNumber < @MaterialOrderItemCnt + 1) BEGIN
		SELECT
				@MaterialOrderItemNo = MaterialOrderItemNo
		FROM
				@tbMaterialOrderItem
		WHERE
				SeqNo = @CurrentRowNumber
		
		SELECT
				@DeliveryStatus = MD.DeliveryStatus
		FROM
				STB_MaterialDeliveryDetailByOrder MDDBO
				LEFT OUTER JOIN STB_MaterialDelivery MD 
					ON MDDBO.MaterialDeliveryNo = MD.MaterialDeliveryNo 
		WHERE
				MDDBO.MaterialOrderItemNo = @MaterialOrderItemNo
				
		
		IF @DeliveryStatus IS NOT NULL BEGIN
			IF @DeliveryStatus <> 'CANCEL' BEGIN
				RAISERROR('전표취소불가(납품서 존재).[발주상세번호]:%s [납품상태]:%s',16,1,@MaterialOrderItemNo,@DeliveryStatus)
				RETURN
			END
		END
		
		SET @CurrentRowNumber = @CurrentRowNumber + 1
	END	
END


