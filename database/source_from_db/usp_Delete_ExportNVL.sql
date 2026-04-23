-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-03-22
-- Description:	Khi xóa trong danh sách hàng xuất từ bắc giang sang bắc ninh hoặc ngược lại thì nó sẽ trả về đúng kho gửi đi
-- =============================================
CREATE PROCEDURE [dbo].[usp_Delete_ExportNVL]
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pMaterialWarehouseInOutHistNo varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    DECLARE
			@RealLocationCode VARCHAR(20),
			@MaterialLocationCode VARCHAR(50),
			@MaterialWarehouseCode VARCHAR(20),
			@LotID VARCHAR(50),
			@SourceLocation varchar(20),
			@SourceMaterialWarehouseCode varchar(20),
			@MaterialLotNo varchar(20)
		
	--Lấy lotID và kho gửi đi
	select @LotID =LotID ,@SourceMaterialWarehouseCode = SourceMaterialWarehouseCode
	from STB_MaterialWarehouseInOutHist  
	WHERE MaterialWarehouseInOutHistNo = @pMaterialWarehouseInOutHistNo

	--Lấy location của nvl ROH_VN_WH_01
	SELECT TOP 1 @SourceLocation = MaterialLocationCode
	  FROM STB_MaterialLocation
	 WHERE MaterialWarehouseCode = @SourceMaterialWarehouseCode
	 ORDER BY MaterialLocationCode ASC


	--Lấy localtion và MaterialWarecode của kho gửi đi của con nvl
	SELECT
			@RealLocationCode = ML.MaterialLocationCode,
			@MaterialWarehouseCode = ML.MaterialWarehouseCode
		
	FROM
			STB_MaterialLocation ML
	WHERE
			ML.MaterialLocationCode = @SourceLocation


	
	SELECT
					
					@MaterialLotNo = MLI.MaterialLotNo
			FROM
					STB_MaterialLotInfo MLI
					LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI 
						ON	MSAI.MaterialCode = MLI.MaterialCode
			WHERE
					MLI.LotID = @LotID


	IF(@pMaterialWarehouseInOutHistNo='')
		BEGIN
			DECLARE @errNullData  nvarchar(200)
			set @errNullData = N'Bạn chưa chọn dữ liệu để xóa!...';
			RAISERROR(@errNullData,16,1)
		END
	ELSE
		BEGIN
		 
		 update STB_MaterialDocLotInfo
			set MaterialLocationCode=@RealLocationCode
			where LotID = @LotID

			UPDATE
					STB_MaterialLotInfo
			SET
					PackingID = LotID,
					MaterialWarehouseCode = @MaterialWarehouseCode,
					MaterialLocationCode = @RealLocationCode,
					ChangeDateTime = GETDATE()
			WHERE
					MaterialLotNo = @MaterialLotNo

			Delete from STB_MaterialWarehouseInOutHist
			WHERE MaterialWarehouseInOutHistNo = @pMaterialWarehouseInOutHistNo
		
		END
END
