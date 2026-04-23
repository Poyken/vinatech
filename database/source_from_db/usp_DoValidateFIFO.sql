
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-23
-- Description:	선입선출 유효성 체크
-- =============================================

-- usp_DoValidateFIFO '','','VVT','VVT_F1','ROH_BG_WH','20250328000475'
CREATE PROCEDURE [dbo].[usp_DoValidateFIFO]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pMaterialWarehouseCode VARCHAR(20),
	@pMaterialLotNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@MaterialWarehouseCode VARCHAR(20) = @pMaterialWarehouseCode,
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@LotID VARCHAR(20) = ''

	DECLARE @MaterialCode VARCHAR(20),
			@GRDate DATE,			
			@Lotattr10 VARCHAR(19),  --add by Mr.Tung on 2022-sep-13
			@pCreateDateTime datetime,
			@CreateDateTime VARCHAR(19),
			@Lotattr10fifo VARCHAR(19)  --add by Mr.Tung on 2022-sep-13
	SELECT
			@MaterialCode = MLI.MaterialCode,
			@GRDate = MLI.GRDate,
			@LotID = LotID        ,           --ADD by Mr.Tung on 2022-04-08 to show LotID
			@Lotattr10 = LotAttr10,          --add by Mr.Tung on 2022-sep-13
			@pCreateDateTime = CreateDateTime
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	IF @MaterialLotNo IS NULL BEGIN
		DECLARE @NotFoundStockError NVARCHAR(500)
		EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
											@pName = '^재고를 찾을 수 없습니다.^',
											@pValue = @NotFoundStockError OUTPUT
		RAISERROR(@NotFoundStockError,16,1)
	END

	DECLARE @A VARCHAR(200),
			     @B VARCHAR(200)

	DECLARE @d VARCHAR(200)=@GRDate


begin try
     
	SELECT
			 @A = MLI.MaterialLotNo + ' ~ ' + MLI.LotID,

			@B =  MLI.CurrentQty - MLI.PickingQty,
			@Lotattr10fifo = MLi.LotAttr10
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.CompanyCode = @CompanyCode AND
			MLI.WorkCenterCode = @WorkCenterCode AND
			MLI.MaterialWarehouseCode = @MaterialWarehouseCode AND
			MLI.MaterialCode = @MaterialCode AND
			MLI.MaterialLotNo <> @MaterialLotNo AND
			(MLI.CurrentQty - MLI.PickingQty) > 0 AND
			(
				isnull(MLI.GRDate,@GRDate) < isnull(@GRDate,MLI.GRDate)  and  @CompanyCode<>'VVT' --add by Mr.Tung on 2023-Jun-06
				--or (convert(date,MLI.Lotattr10,120) < convert(date,@Lotattr10,120) and  @CompanyCode='VVT' --add by Mr.Tung on 2022-sep-13
				--or (Month(convert(date,MLI.Lotattr10,120)) < Month(convert(date,@Lotattr10,120)) 
				--or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM')) and  @CompanyCode='VVT'  --Mr Duy bỏ fifo theo ngày thêm fifo theo tháng
				--and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120)))--Mr Duy bỏ fifo theo ngày thêm fifo theo tháng

				or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM-dd')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM-dd')) and  @CompanyCode='VVT'  --2025-11-20 Mr Mạnh chuyển FIFO theo ngày
				and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120)))--2025-11-20 Mr Mạnh chuyển FIFO theo ngày
			)
end try
begin catch
			RAISERROR(N' Không thể chuyển đổi LotAttr10 (ngày nhập trong F330) thành giá trị ngày, vui lòng kiểm tra lại!',16,1)  --add by Mr.Tung on 2022-sep-13
			RETURN
end catch
		DECLARE @ExistsEarlyStockError NVARCHAR(500)
		-- Đây là kiểm tra FIFO theo ngày khi nào có Audit đối với nhà máy bắc ninh
		set @CreateDateTime =  FORMAT(convert(datetime,@pCreateDateTime,103), 'yyyy-MM-dd')
		--RAISERROR(@MaterialLotNo,16,1) 
		--return;
	
	--Lấy thông tin để hiển thị ra ngoài biết lot nào đang cần xuất trước

		DECLARE @A1 VARCHAR(200),@B1 VARCHAR(200),
				@CreateDateTime1 date,@CreateDateTime2 VARCHAR(19)
				SELECT
							 @A1 = MLI.MaterialLotNo + ' ~ ' + MLI.LotID,

							@B1 =  MLI.CurrentQty - MLI.PickingQty,
							@CreateDateTime1=CreateDateTime
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.CompanyCode = @CompanyCode AND
							MLI.WorkCenterCode = @WorkCenterCode AND
							MLI.MaterialWarehouseCode = @MaterialWarehouseCode AND
							MLI.MaterialCode = @MaterialCode AND
							MLI.MaterialLotNo <> @MaterialLotNo AND
							(MLI.CurrentQty - MLI.PickingQty) > 0 AND
							(
								isnull(MLI.GRDate,@GRDate) < isnull(@GRDate,MLI.GRDate)  and  @CompanyCode<>'VVT' --add by Mr.Tung on 2023-Jun-06
							--or (convert(date,MLI.Lotattr10,120) < convert(date,Lotattr10,120) and  @CompanyCode='VVT' --add by Mr.Tung on 2022-sep-13
							--or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM')) and  @CompanyCode='VVT' --Mr Duy bỏ fifo theo ngày thêm fifo theo tháng
							----or (Month(convert(date,MLI.Lotattr10,120)) < Month(convert(date,@Lotattr10,120))         -- fifo theo tháng
							--and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120))) --Mr Duy bỏ fifo theo ngày thêm fifo theo tháng


							or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM-dd')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM-dd')) and  @CompanyCode='VVT' --2025-11-20 Mr Mạnh chuyển FIFO theo ngày
							and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120))) --2025-11-20 Mr Mạnh chuyển FIFO theo ngày
							)
					
		
		-- Đây là FIFO theo tháng đối với tất cả nhà máy.
						--declare @test varchar(20)= @Lotattr10
						--RAISERROR(@test,16,1)

		IF EXISTS	(
							SELECT
									1
							FROM
									STB_MaterialLotInfo MLI
									inner join STB_MaterialDocLotInfo MDLI on MLI.LotID = MDLI.LotID 
							WHERE 1=1
									AND MLI.CompanyCode = @CompanyCode 
									AND MLI.WorkCenterCode = @WorkCenterCode 
									AND MLI.MaterialWarehouseCode = @MaterialWarehouseCode 
									AND MLI.MaterialCode = @MaterialCode 
									AND MLI.MaterialLotNo <> @MaterialLotNo 
									AND (MLI.CurrentQty - MLI.PickingQty) > 0 
									--AND (MDLI.Isused <> 1 or MDLI.Isused is null)
									AND (
											isnull(MLI.GRDate,@GRDate) < isnull(@GRDate,MLI.GRDate)   
											and  @CompanyCode<>'VVT'  --add by Mr.Tung on 2023-Jun-06
									--or (convert(date,MLI.Lotattr10,120) < convert(date,@Lotattr10,120) and  @CompanyCode='VVT' --add by Mr.Tung on 2022-sep-13
									--or (Month(convert(date,MLI.Lotattr10,120)) < Month(convert(date,@Lotattr10,120)) 
									--or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM'))  --Mr Duy bỏ fifo theo ngày thêm fifo theo tháng
									--and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120))) --Mr Duy bỏ fifo theo ngày thêm fifo theo tháng

									or ( FORMAT(convert(date,MLI.Lotattr10,120), 'yyyy-MM-dd')  <  ( FORMAT(convert(date,@Lotattr10,120), 'yyyy-MM-dd'))  --2025-11-20 Mr Mạnh chuyển FIFO theo ngày
									and Year(convert(date,MLI.Lotattr10,120)) <= Year(convert(date,@Lotattr10,120))) --2025-11-20 Mr Mạnh chuyển FIFO theo ngày
										 )
								
						) 
			BEGIN
				
			
				EXEC usp_GetAddOnStringResource	@pLanguage = @pProcessLanguage,
													@pName = '^선입 자재를 먼저 피킹하세요.^',
													@pValue = @ExistsEarlyStockError OUTPUT

				if lower(@pProcessLanguage) like '%vi%' begin 				
					RAISERROR(N'Trước tiên hãy lấy nguyên liệu nhập trước. Mã được quét là %s ~ %s    ||   Tuy nhiên, Tồn tại mã vạch này được nhập trước (/ Sản Xuất trước): %s ~ %s ~ Ngày SX: %s',16,1, 
						@pMaterialLotNo,@LotID, @A1, @B1,@Lotattr10fifo) 
				end 
				else begin 
					RAISERROR('선입 자재를 먼저 피킹하세요  %s ~ %s    ||    %s ~ %s ~ VENDOR DATE: %s',16,1, 
						@pMaterialLotNo,@LotID, @A1, @B1,@Lotattr10) 
				end 

				RETURN
			END
			
END

