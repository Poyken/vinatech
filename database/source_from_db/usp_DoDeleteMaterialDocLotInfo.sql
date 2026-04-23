

-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-10-18
-- Browsable : true
-- Group : 자재수불관리
-- Description:	입하상태의 선택된 라벨정보를 삭제처리합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteMaterialDocLotInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @iDoc INT
	DECLARE	@TableName VARCHAR(200)
	DECLARE @DocStatus VARCHAR(20)

	DECLARE @MaterialDocLotInfo TABLE
	(
		IDX INT IDENTITY,
		MaterialDocDetailNo VARCHAR(20),
		MDLISeqNo INT,
		MaterialDocNo VARCHAR(20),
		LotNo VARCHAR(100)
	)

	SET @TableName = '/DataSet/MaterialDocLotInfo'
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml 


	BEGIN TRY
		INSERT @MaterialDocLotInfo
		SELECT
				XMLData.MaterialDocDetailNo,
				XMLData.MDLISeqNo,
				XMLData.MaterialDocNo,
				XMLData.LotNo
		FROM
				OPENXML(@iDoc, @TableName, 2)
				WITH(
						MaterialDocDetailNo VARCHAR(20),
						MDLISeqNo INT,
						MaterialDocNo VARCHAR(20),
						LotNo VARCHAR(100)
					)XMLData
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)
	END CATCH
	
	
	EXEC sp_xml_removedocument @iDoc

	DECLARE @rowCnt INT 
	DECLARE @initNum INT = 1
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MDLISeqNo INT
	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @LotNo VARCHAR(100)

	SELECT 
			TOP 1 
			@MaterialDocNo = MaterialDocNo 
	FROM 
			@MaterialDocLotInfo

	SELECT
			@DocStatus = MDI.DocStatus
	FROM
			STB_MaterialDocInfo MDI
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	IF @DocStatus <> 'ARRIVAL' BEGIN
		RAISERROR('입하상태에서만 해당 라벨정보를 삭제할 수 있습니다. %s',16,1,@MaterialDocNo)
		RETURN
	END

	SELECT
			@rowCnt = COUNT(1)
	FROM
			@MaterialDocLotInfo

	WHILE @initNum <= @rowCnt BEGIN
		
		SELECT
				@MaterialDocDetailNo = MDI.MaterialDocDetailNo,
				@MDLISeqNo = MDI.MDLISeqNo,
				@LotNo = MDI.LotNo
		FROM
				@MaterialDocLotInfo MDI
		WHERE
				IDX = @initNum
				
		DELETE FROM STB_MaterialDocLotInfo
		WHERE
				MaterialDocDetailNo = @MaterialDocDetailNo AND
				MDLISeqNo = @MDLISeqNo
			
		SET @initNum = @initNum + 1
				
	END

END

