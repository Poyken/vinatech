-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description:	출하검사 Lot을 생성합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateOqcInfoListForLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
					Barcode,
					ProdQty
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								Barcode VARCHAR(50),
								ProdQty NUMERIC(20,5)
							)
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@Barcode,
								@ProdQty

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
			
			EXEC usp_DoCreateOqcInfoForLot	@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pBarcode = @Barcode,
											@pProdQty = @ProdQty,
											@pMaterialQcNo = @MaterialQcNo OUTPUT
		END	
    END TRY
	BEGIN CATCH
		--SET @ERROR_MSG = ERROR_MESSAGE()
		--RAISERROR( @ERROR_MSG ,16, 1)

		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
															'^제품검사Lot생성 중 오류가 발생하였습니다^',
															@ERROR_MSG OUTPUT
		RAISERROR(@ERROR_MSG,16,1)
		RETURN
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc
END