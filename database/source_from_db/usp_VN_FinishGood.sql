CREATE PROC usp_VN_FinishGood
	--@pProcessLanguage VARCHAR(20),
	--@pProcessUserID VARCHAR(20)--,
	--@pQcNo NVARCHAR(50) = NULL
AS
BEGIN

SET NOCOUNT ON;
				  --DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				  --@ProcessUserID VARCHAR(20) = @pProcessUserID
				  --DECLARE @Pss NVARCHAR(50)
				  --DECLARE @Lot NVARCHAR(50)
				  --DECLARE @Mcode NVARCHAR(50) --= @pQcNo

CREATE TABLE #STB_VN_FINISHGOOD
(
	--IDFG INT IDENTITY(1,1) NOT NULL PRIMARY KEY(IDFG),
	LotID NVARCHAR(70) NULL,
	LotNo NVARCHAR(70) NULL,
	MaterialQcNo NVARCHAR(70) NULL,
	MaterialCode NVARCHAR(70) NULL,
	DecisionResult  NVARCHAR(5) NULL,
	CurrentQty INT NULL,
	INPUT NVARCHAR(20) NULL DEFAULT N'Nhập',
	OUTPUTS NVARCHAR(20) NULL,
	DateIn DATETIME NULL,
	DateOut DATETIME NULL,
	CreateDateTime DATETIME NULL,
	CreateUserID VARCHAR(30) NULL,
	ChangeDateTime DATETIME NULL,
	ChangeUserID VARCHAR(30) NULL
)


				 --SELECT 
					--	@Lot=MaterialQcNo,
					--	@Pss=DecisionResult
				 --FROM
					--	STB_MaterialQcDetail

				 --WHERE  
					--	MaterialQcNo=@Mcode 

	--IF @Lot IS NULL 

	--			BEGIN
	--						DECLARE @NotEnoughStockError NVARCHAR(MAX)
	--						EXEC usp_GetSystemStringResource @ProcessLanguage,
	--													N'Mã barcode này không tồn tại, hoặc chưa được OQC Pass qua, trường hợp đặc biệt vui lòng liên hệ với IT',
	--													@NotEnoughStockError OUTPUT

	--				RAISERROR(@NotEnoughStockError,16,1)
	--				RETURN	
	--			END

    --IF @Lot IS NOT NULL AND @Pss=N'Pass'

	BEGIN

	INSERT INTO #STB_VN_FINISHGOOD (LotID,LotNo,MaterialQcNo,MaterialCode,DecisionResult,CurrentQty)

			SELECT 
					T1.LotID,
					T1.LotNo,
					T2.MaterialQcNo,
					T2.DecisionResult,
					T1.MaterialCode,
					T1.CurrentQty

			FROM
					STB_MaterialLotInfo T1

			LEFT JOIN 

					 STB_MaterialQcDetail T2 ON T2.MaterialQcNo= T1.LotNo


					WHERE

					 T2.MaterialQcNo IS NOT NULL
				
		SELECT 
				    LotID,
					LotNo,
					MaterialQcNo,
					DecisionResult,
					MaterialCode,
					CurrentQty,
					INPUT,
					OUTPUTS,
					DateIn,
					DateOut,
					CreateDateTime,
					CreateUserID,
					ChangeDateTime,
					ChangeUserID
		FROM
				#STB_VN_FINISHGOOD

		
			--WHERE

			--		DecisionResult='Pass' AND MaterialQcNo=@Mcode


		--GROUP BY 
		--			LotID,
		--			LotNo,
		--			MaterialQcNo,
		--			DecisionResult,
		--			MaterialCode,
		--			CurrentQty 

		--DROP TABLE #STB_VN_FINISHGOOD

END		

				 

END

--EXEC usp_VN_FinishGood '',''

-- SELECT MaterialQcNo FROM 	STB_MaterialQcDetail