-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-12
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_VN_UpdateSpecialSparePartLot
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLineCode VARCHAR(20),
		@pControlNo VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SparePartLotID VARCHAR(30)    -- DinhManh update 2025-06-12
	DECLARE @LotID VARCHAR(30)
	SELECT @LotID = Barcode FROM STB_SetInfo WHERE ControlNo = @pControlNo

	DECLARE myCursor CURSOR FOR
		WITH NewestSpareSpartLotID AS (
			SELECT 
					SSPI.SparePartLotID,
					SSPI.SparePartCode,
					SSPI.IOType,
					SSPI.LineCode,
					SSPI.MachineCode,
					SSPI.CreateDateTime,
					ROW_NUMBER() OVER (PARTITION BY SparePartCode ORDER BY CreateDateTime desc) AS RN
				FROM	STB_VN_SpecialSparePartIOHist SSPI
				WHERE SSPI.IOType = 'OUT'
					and SSPI.LineCode = @pLineCode

		)
		SELECT NSS.SparePartLotID 
			FROM NewestSpareSpartLotID NSS
			WHERE NSS.RN = 1

		OPEN myCursor
		FETCH NEXT FROM myCursor INTO @SparePartLotID

		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT INTO	               -- Khi có lot mới đưa vào sản xuất sẽ update luôn ở bảng này
						STB_VN_SpecialSparePartLotInfo
							(
								SparePartLotID,
								LotID
							)
					VALUES
							(
								@SparePartLotID,
								@LotID
							)


			FETCH NEXT FROM myCursor INTO @SparePartLotID
		END

		CLOSE myCursor
		DEALLOCATE myCursor
END
