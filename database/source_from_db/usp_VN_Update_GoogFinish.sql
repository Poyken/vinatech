CREATE PROC [dbo].[usp_VN_Update_GoogFinish] -- EXEC usp_VN_Update_GoogFinish 'VVKQ123R010542','ABC'
@LotNo NVARCHAR(50),
@Uid NVARCHAR(50)
AS
BEGIN

		exec usp_VVT_checkFIFO_FinishGood @pLotNo=@LotNo

		DECLARE @Barcode NVARCHAR(50)
		DECLARE @Sts NVARCHAR(50)

		SELECT 
				@Barcode = LotNo,
				@Sts = Statusout
		FROM
				STB_VN_FINISHGOODS
		WHERE
				LotNo = @LotNo AND Statusout IS NULL

			IF @Barcode IS NOT NULL  AND @Sts IS NULL

				BEGIN
						UPDATE 	STB_VN_FINISHGOODS

							SET
								Statusout = N'Xuất',
								PersonExport = @Uid,
								DateExport = DATEADD(HH, -2, GETDATE())
						
						WHERE
									LotNo = @LotNo  
								
				END
END

