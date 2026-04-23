-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-06
-- Description : 스캔된 바코드 리스트로 LOT 정보 생성
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName,
			@iDoc INT,
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@DocStatus VARCHAR(20),
			@MaterialDocNo VARCHAR(20),
			@MaterialDocDetailNo VARCHAR(20),
			@MaterialIqcNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@CustomerCode VARCHAR(20),
			@LotID VARCHAR(50),
			@RequestQty NUMERIC(20,5),
			@LotQty NUMERIC(20,5),
			@AllowQty NUMERIC(20,5),
			@InspectionType VARCHAR(20),
			@DecisionResult VARCHAR(1)

	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	DECLARE @Materials TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		LotID VARCHAR(50),
		LotNo VARCHAR(100),
		RequestQty NUMERIC(20,5)
	)
	INSERT INTO @Materials
	SELECT
			MaterialDocNo,
			MaterialDocDetailNo,
			LotID,
			LotNo,
			RequestQty
	FROM
			OPENXML(@iDoc , @UpdateTableName , 2)
			WITH  (
					MaterialDocNo VARCHAR(20),
					MaterialDocDetailNo VARCHAR(20),
					LotID VARCHAR(50),
					LotNo VARCHAR(100),
					RequestQty NUMERIC(20,5)
				) X

			
	EXEC sp_xml_removedocument @iDoc

	DECLARE @LROW INT,
			@LCOUNT INT

	SET @LROW = 1
	SET @LCOUNT = (SELECT COUNT(1) FROM @Materials)

	WHILE @LROW <= @LCOUNT BEGIN
		SELECT
				@MaterialDocType = MDI.MaterialDocType,
				@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
				@DocStatus = MDI.DocStatus,
				@MaterialDocNo = L.MaterialDocNo, 				
				@MaterialDocDetailNo = L.MaterialDocDetailNo,
				@MaterialIqcNo = MDD.MaterialIqcNo,
				@CustomerCode = MDI.SourceCustomerCode,
				@MaterialCode  = MDD.MaterialCode,
				@LotID = L.LotID,
				@RequestQty = L.RequestQty
		FROM
				@Materials L
				INNER JOIN STB_MaterialDocDetail MDD
					ON	MDD.MaterialDocDetailNo = L.MaterialDocDetailNo
				INNER JOIN STB_MaterialDocInfo MDI
					ON	MDI.MaterialDocNo = MDD.MaterialDocNo
		WHERE
				L.ROW = @LROW

		IF EXISTS ( SELECT 1 FROM STB_MaterialDocLotInfo MDLI WHERE MDLI.MaterialDocNo = @MaterialDocNo AND MDLI.LotID = @LotID) BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage,
											'이미 추가된 바코드입니다.'
			RETURN
		END

		IF @MaterialDocType = 'GR' BEGIN
			IF @DocStatus <> 'ARRIVAL' BEGIN
				EXEC usp_RaiseLocalizedError	@ProcessLanguage,
												'입하처리가 되지 않았습니다.'
				RETURN
			END

			SELECT
					@InspectionType = MVM.InspectionType
			FROM
					STB_MaterialVendorMapping MVM
			WHERE
					MVM.MaterialCode = @MaterialCode AND
					MVM.CustomerCode = @CustomerCode

			IF @InspectionType <> 'NONE' AND ISNULL(@MaterialIqcNo,'') = '' BEGIN
				EXEC usp_RaiseLocalizedError	@ProcessLanguage,
												'수입검사의뢰 정보를 찾을 수 없습니다.'
				RETURN
			END

			SELECT
					@DecisionResult = MQI.DecisionResult
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @MaterialIqcNo

			IF @DecisionResult <> 'P' BEGIN
				EXEC usp_RaiseLocalizedError	@ProcessLanguage,
												'수입검사 합격처리가 되지 않았습니다.'
				RETURN
			END
		END

		SELECT
				@LotQty = SUM(MDLI.StockQty)
		FROM
				STB_MaterialDocLotInfo MDLI 
		WHERE
				MDLI.MaterialDocDetailNo = @MaterialDocDetailNo

		SELECT
				@AllowQty = MDD.AllowQty
		FROM
				STB_MaterialDocDetail MDD
		WHERE
				MDD.MaterialDocDetailNo = @MaterialDocDetailNo

		IF @AllowQty < @LotQty + @RequestQty BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage,
											'상세내역의 수량을 초과할 수 없습니다.'
			RETURN
		END

		INSERT INTO STB_MaterialDocLotInfo
		(
			MaterialDocDetailNo,
			MDLISeqNo,
			LotID,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			StockQty,
			IsChecked,
			MaterialLocationCode,
			MaterialDocNo,
			PackingID,
			LotNo,
			CreateDateTime,
			CreateUserID
		)
		SELECT
				L.MaterialDocDetailNo,
				(
					SELECT
							COUNT(1) + 1
					FROM
							STB_MaterialDocLotInfo MDLI
					WHERE
							MDLI.MaterialDocDetailNo = L.MaterialDocDetailNo
				),
				L.LotID,
				MDD.MaterialCode,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				@RequestQty,
				1,	-- IsChecked
				NULL,	-- MaterialLocationCode,
				L.MaterialDocNo,
				NULL, -- PackingID,
				L.LotNo, --LotNo,
				GETDATE(),
				@ProcessUserID
		FROM
				@Materials L
				INNER JOIN STB_MaterialDocDetail MDD
					ON	MDD.MaterialDocDetailNo = L.MaterialDocDetailNo
		WHERE
				L.ROW = @LROW

		SET @LROW = @LROW + 1
	END

	
END
