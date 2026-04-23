CREATE PROC usp_VN_FinishGoodWHS
@pQcNo NVARCHAR(100)
AS
BEGIN

	DECLARE @LotID NVARCHAR(100),
			@LotNo NVARCHAR(100),
			@MaterialQcNo NVARCHAR(100),
			@DecisionResult NVARCHAR(100),
			@MaterialCode NVARCHAR(100),
			@CurrentQty INT
	
			SELECT 
					@LotID=T1.LotID,
					@LotNo=T1.LotNo,
					@MaterialQcNo=T2.MaterialQcNo,
					@DecisionResult=T2.DecisionResult,
					@MaterialCode=T1.MaterialCode,
					@CurrentQty=T1.CurrentQty

			FROM
					STB_MaterialLotInfo T1

			LEFT JOIN 

					 STB_MaterialQcDetail T2 ON T2.MaterialQcNo= T1.LotNo


					WHERE

					 T2.MaterialQcNo IS NOT NULL AND MaterialQcNo=@pQcNo


	DECLARE @MaterialQcNos NVARCHAR(100)
	DECLARE @OUTS NVARCHAR(30)

			SELECT
					@MaterialQcNos = T3.MaterialQcNo,
					@OUTS = T3.OUTPUTS
			FROM 
					STB_VN_FINISHGOOD T3
			WHERE
					T3.MaterialQcNo=@pQcNo
				
	IF @MaterialQcNos IS NOT NULL AND @OUTS IS NULL

			BEGIN
					UPDATE STB_VN_FINISHGOOD
					SET
							OUTPUTS = N'Xuất',
							DateOut = GETDATE()
					WHERE
							MaterialQcNo=@pQcNo
			END

	IF @MaterialQcNos IS NULL

			BEGIN
				 INSERT INTO STB_VN_FINISHGOOD
				 (
					LotID,
					LotNo,
					MaterialQcNo,
					MaterialCode,
					DecisionResult,
					CurrentQty,
					INPUT,
					DateIn
				 )
				 VALUES
				 (
					@LotID,
					@LotNo,
					@MaterialQcNo,
					@MaterialCode,
					@DecisionResult,
					@CurrentQty,
					N'Nhập',
					GETDATE()
				 )
			END
END

--EXEC usp_VN_FinishGoodWHS 'VJJP153R010504'


--SELECT * FROM STB_VN_FINISHGOOD

--CREATE PROC usp_VN_Checkbarcode
--@pQcNo NVARCHAR(100)
--AS
--BEGIN
--		SELECT 
					
--				   MaterialQcNo

--			FROM
--					STB_MaterialLotInfo T1

--			LEFT JOIN 

--					 STB_MaterialQcDetail T2 ON T2.MaterialQcNo= T1.LotNo

--			WHERE

--					 T2.MaterialQcNo IS NOT NULL AND MaterialQcNo=@pQcNo


--END

--DELETE STB_VN_FINISHGOOD