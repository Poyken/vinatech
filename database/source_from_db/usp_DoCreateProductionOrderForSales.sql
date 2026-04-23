-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : ProductionOrder 생성. 기간으로 PO 를 생성하는 경우 PlanYearMonth 비교를 주석처리하고 기간부분 주석을 제거한다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateProductionOrderForSales]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE',
			@iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	DECLARE @RowData TABLE
	(
		PlanYearMonth VARCHAR(7),
		PlanStartDate DATE,
		PlanEndDate DATE,		
		SOISequence BIGINT,						
		MaterialCode VARCHAR(50),
		BomVersion VARCHAR(20),
		POQty NUMERIC(20,5)
	)
	INSERT INTO @RowData
	SELECT
			PlanYearMonth = XmlData.PlanYearMonth,
			PlanStartDate = XmlData.PlanStartDate,
			PlanEndDate = XmlData.PlanEndDate,
			SOISequence = XmlData.SOISequence,
			MaterialCode = XmlData.MaterialCode,
			BomVersion = XmlData.BomVersion,
			POQty = XmlData.POQty
	FROM
			OPENXML(@idoc , @UpdateTableName , 2)
			WITH  (
						PlanYearMonth VARCHAR(7),
						PlanStartDate DATE,
						PlanEndDate DATE,
						SOISequence BIGINT,						
						MaterialCode VARCHAR(50),
						BomVersion VARCHAR(20),
						POQty NUMERIC(20,5)
					) XMLData

	EXEC sp_xml_removedocument @iDoc

	DECLARE @PO TABLE
	(
		ROW INT IDENTITY(1,1),
		PlanYearMonth VARCHAR(7),
		--PlanStartDate DATE,
		--PlanEndDate DATE,
		MaterialCode VARCHAR(50),
		BomVersion VARCHAR(20),
		POQty NUMERIC(20,5)
	)
	INSERT INTO @PO
	SELECT
			-- 기간으로 PO 를 생성하는 경우 PlanYearMonth 비교를 주석처리하고 기간부분 주석을 제거한다.
			PlanYearMonth,
			--PlanStartDate,
			--PlanEndDate,
			MaterialCode,
			BomVersion,
			SUM(POQty) AS POQty
	FROM
			@RowData
	GROUP BY
			-- 기간으로 PO 를 생성하는 경우 PlanYearMonth 비교를 주석처리하고 기간부분 주석을 제거한다.
			PlanYearMonth,
			--PlanStartDate,
			--PlanEndDate,
			MaterialCode,
			BomVersion

	DECLARE @ROW INT = 1,
			@COUNT INT = (SELECT COUNT(1) FROM @PO),
			@PlanYearMonth VARCHAR(7),
			@PlanStartDate DATE,
			@PlanEndDate DATE,
			@MaterialCode VARCHAR(50),
			@BomVersion VARCHAR(20),
			@POQty NUMERIC(20,5),
			@PONos VARCHAR(MAX)

	WHILE @ROW <= @COUNT BEGIN
		SELECT
				@PlanYearMonth = P.PlanYearMonth,
				--@PlanStartDate = P.PlanStartDate,
				--@PlanEndDate = P.PlanEndDate,
				@MaterialCode = P.MaterialCode,
				@BomVersion = P.BomVersion,
				@POQty = P.POQty
		FROM
				@PO P
		WHERE
				P.ROW = @ROW

		EXEC usp_DoCreateProductionOrder @pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pPlanYearMonth = @PlanYearMonth,
											@pPlanStartDate = @PlanStartDate,
											@pPlanEndDate = @PlanEndDate,
											@pMaterialCode = @MaterialCode,
											@pBomVersion = @BomVersion,
											@pPOQty = @POQty,
											@pIgnoreMaxPlanQty = 1,
											@pPONos = @PONos OUTPUT

		MERGE STB_ProductionOrderSalesInfo AS T
		USING (
			SELECT
					POI.PONo,
					RD.SOISequence,
					RD.POQty
			FROM
					dbo.fnSplitToTable(',', @PONos) P
					INNER JOIN STB_ProductionOrderInfo POI
						ON	POI.PONo = P.Item
					INNER JOIN @RowData RD
						ON	RD.MaterialCode = POI.MaterialCode AND
							RD.BomVersion = POI.BomVersion AND
							-- 기간으로 PO 를 생성하는 경우 PlanYearMonth 비교를 주석처리하고 기간부분 주석을 제거한다.
							RD.PlanYearMonth = POI.PlanYearMonth -- AND
							--RD.PlanStartDate = POI.ProdPlanStartDate AND
							--RD.PlanEndDate = POI.ProdPlanEndDate
			) AS S
				ON	(S.PONo = T.PONo AND S.SOISequence = T.SOISequence)
			WHEN MATCHED THEN
				UPDATE
				SET
						PlanQty = PlanQty + S.POQty,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @ProcessUserID
			WHEN NOT MATCHED THEN
				INSERT
				(
					PONo,
					SOISequence,
					PlanQty,
					CreateDateTime,
					CreateUserID
				)
				VALUES
				(
					S.PONo,
					S.SOISequence,
					S.POQty,
					GETDATE(),
					@ProcessUserID
				);
			


		SET @ROW = @ROW + 1
	END
END
