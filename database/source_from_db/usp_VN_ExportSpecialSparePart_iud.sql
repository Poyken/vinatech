-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-11
-- Description:	Export Special Sparepart
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ExportSpecialSparePart_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSparePartCode VARCHAR(30),
		@pIOQty INT,
		@pWorkCenterCode VARCHAR(10),
		@pLineCode VARCHAR(20),
		@pMachineCode VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Error NVARCHAR(500)
	DECLARE @StartNumber INT = 1
	DECLARE @NewLotID VARCHAR(50)
	DECLARE @Barcode VARCHAR(30)
	DECLARE @SparePartLotID VARCHAR(50)
	DECLARE @count INT = 1

	IF(@pSparePartCode NOT IN (SELECT SparePartCode FROM STB_VN_SpecialSparePartInfo))  -- nếu nhập mã khác trên hệ thống
		BEGIN
			set @Error=N'Mã SparePart đã xuất không có trên hệ thống, vui lòng kiểm tra lại!'
			RAISERROR(@Error,16, 1)
			return;
		END
	
	DECLARE @countInv  INT 
	SELECT @countInv = (sum(case when SSPIO.IOType='IN'  then SSPIO.IOQty else 0 end)
									- sum(case when SSPIO.IOType='OUT' then SSPIO.IOQty else 0 end))
									FROM STB_VN_SpecialSparePartIOHist SSPIO  WITH(NOLOCK)
									WHERE SSPIO.SparePartCode = @pSparePartCode

	DECLARE @qtyUsing  INT 
	SELECT @qtyUsing = SSPI.UsingQty	FROM STB_VN_SpecialSparePartInfo SSPI  WITH(NOLOCK)
										WHERE SSPI.SparePartCode = @pSparePartCode

	IF (@pIOQty > @countInv ) -- nếu số lượng xuất lớn hơn số lượng tồn kho thì báo lỗi
		BEGIN
			set @Error=N'Số lượng tồn kho không đủ để xuất kho !'
			RAISERROR(@Error,16, 1)
			return;
		END

	
	IF(@pIOQty <=0 OR @pIOQty > @qtyUsing)  -- nếu nhập số lượng nhỏ hơn 0 hoặc lớn hơn số lượng sử dụng thì báo lỗi
		BEGIN
			set @Error=N'Kiểm tra lại số lượng xuất kho!'
			RAISERROR(@Error,16, 1)
			return;
		END
	-- Mr.Triều Triển khai
    -- Lấy LotQty theo yêu cầu từ bảng STB_VN_SpecialSparePartInfo
	DECLARE @LotQtyRequired INT
	SELECT @LotQtyRequired = CAST(SSPI.CycleReplace / SSPI.LotQty AS INT)
	FROM STB_VN_SpecialSparePartInfo SSPI WITH(NOLOCK)
	WHERE SSPI.SparePartCode = @pSparePartCode

	-- Tìm Spepart cũ gần nhất (gắn vào line này) để kiểm tra số lượng LotQty
	DECLARE @OldSparePartLotID VARCHAR(50)
	SELECT TOP 1 @OldSparePartLotID = SparePartLotID
	FROM STB_VN_SpecialSparePartIOHist
	WHERE LineCode = @pLineCode AND SparePartCode = @pSparePartCode AND IOType = 'OUT'
	ORDER BY CreateDateTime DESC
	-- Đếm số lượng LotId của Spepart cũ trên Line
	DECLARE @CurrentLotCount INT
	SELECT @CurrentLotCount = COUNT(*)
	FROM STB_VN_SpecialSparePartLotInfo
	WHERE SparePartLotID = @OldSparePartLotID
	PRINT N'@OldSparePartLotID=' + ISNULL(@OldSparePartLotID, 'NULL')
	PRINT N'@CurrentLotCount=' + CAST(ISNULL(@CurrentLotCount,0) AS VARCHAR)
	PRINT N'@LotQtyRequired=' + CAST(ISNULL(@LotQtyRequired,0) AS VARCHAR)
	-- Kiểm tra đièu kiện đã đủ LotQty chưa
	IF (@OldSparePartLotID IS NOT NULL AND ISNULL(@CurrentLotCount,0) < @LotQtyRequired)
	BEGIN
		SET @Error = N'Không thể xuất kho spare part mới vì spare part cũ trên line chưa đủ số lượng lot theo quy định!'
		RAISERROR(@Error,16,1)
		RETURN;
	END

	SELECT TOP 1 @Barcode =  Barcode	FROM STB_SetInfo
										WHERE InputLineCode = @pLineCode
										ORDER BY InputDateTime desc


	--WHILE @StartNumber <= @pIOQty 
	--BEGIN
	
		--EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
		--set @SparePartLotID ='SSP' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 

		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_VN_SpecialSparePartIOHist', @NewLotID OUTPUT
		set @SparePartLotID = @NewLotID

		INSERT INTO	                -- Lịch sử xuất kho
				STB_VN_SpecialSparePartIOHist
					(
						SparePartLotID,
						SparePartCode,
						IOType,
						IOQty,
						WorkCenterCode,
						LineCode,
						MachineCode,
						CreateDateTime,
						CreateUserID									
					)

			VALUES
					(
						@SparePartLotID,
						@pSparePartCode,
						'OUT',
						@pIOQty,
						--1,
						@pWorkCenterCode,
						@pLineCode,
						@pMachineCode,
						GETDATE(),
						@pProcessUserID
					)




		INSERT INTO	                -- Lấy luôn Lot hiện tại đang trên Line sản xuất đó
				STB_VN_SpecialSparePartLotInfo
					(
						SparePartLotID,
						LotID
					)
			VALUES
					(
						@SparePartLotID,
						@Barcode		)

	--	SET @StartNumber = @StartNumber + 1	
			
	--END

	-- kêt thức spepart cũ (nếu có)

	UPDATE STB_VN_SparePartLineUsage
	SET IsUsing = 0,
		EndDate = GETDATE()
	WHERE LineCode = @pLineCode
	  AND SparePartCode = @pSparePartCode
	  AND IsUsing = 1

	  -- Ghi nhận spepart mới đang sử dụng trên line
	  INSERT INTO STB_VN_SparePartLineUsage (
		SparePartCode,
		SparePartLotID,
		LineCode,
		MachineCode,
		StartDate,
		IsUsing,
		CreateUserID,
		CreateDateTime,
		WorkCenterCode
	)
	VALUES (
		@pSparePartCode,
		@SparePartLotID,
		@pLineCode,
		@pMachineCode,
		GETDATE(),
		1,
		@pProcessUserID,
		GETDATE(),
		@pWorkCenterCode
	)

END
