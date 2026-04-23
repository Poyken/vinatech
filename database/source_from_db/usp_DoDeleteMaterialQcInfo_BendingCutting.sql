-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_DoDeleteMaterialQcInfo_BendingCutting
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @GRProcessQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @TotalCount INT
	DECLARE @LoopCount INT
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @PickingAssingQty NUMERIC(20,5)
	DECLARE @BefQcStatus VARCHAR(10)
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo_BendingCutting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
				SELECT
						CASE 
							WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo
							ELSE XMLData.OldMaterialQcNo
						END AS OldMaterialIqcNo
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- STB_MaterialQcDetail 삭제
			DELETE FROM STB_MaterialQcDetail_BendingCutting
			 WHERE MaterialQcNo = @OldMaterialQcNo

			-- STB_MaterialQcInfo 삭제
			DELETE FROM STB_MaterialQcInfo_BendingCutting
			 WHERE MaterialQcNo = @OldMaterialQcNo

			-- STB_SetInfo 업데이트
			UPDATE STB_SetInfo
			   SET LotNumberBC = NULL
			 WHERE LotNumberBC = @OldMaterialQcNo

			 -- Mr.Manh update 2025-07-29 for Seperated Lot QC
			 UPDATE VVT_OQC_REFER
			 SET LotNumberBC = NULL
			 WHERE lotid = @OldMaterialQcNo


        END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	
END
