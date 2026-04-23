-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 품질관리 > 수입검사 > 시료별수입검사 > 검사LotNo 변경 Button
-- Description:	
-- Modified: 
-- Select IQCSampleLotList, DescText, * from STB_MaterialQcInfo where MaterialQcNo = '20090900001'

--update STB_MaterialQcInfo
--set DescText = '' 
--where MaterialQcNo = '20090900001'

-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInfoChangeLotNo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20),
	@pIQCSampleLotList NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	       ,   @IQCSampleLotList NVARCHAR(MAX) = ISNULL(@pIQCSampleLotList, '')

 
	UPDATE STB_MaterialQcInfo
	      SET IQCSampleLotList = @IQCSampleLotList
	 WHERE MaterialQcNo = @MaterialQcNo

END

--ALTER PROCEDURE [dbo].[usp_MaterialQcInfoChangeLotNo_iud]
--	@pProcessUserID VARCHAR(20),
--	@pProcessLanguage VARCHAR(20),
--    @pProcessViewName VARCHAR(50),
--	@pXml NVARCHAR(MAX) = null
--AS

--BEGIN
--	SET NOCOUNT ON;

--    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
--    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
--    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
--    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
--    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
--    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
--    DECLARE @ERROR_MSG NVARCHAR(MAX)
--    DECLARE @IUD_FLAG VARCHAR(10)
--    DECLARE @IsAutoKey BIT
--    DECLARE @IsLoopIUD BIT
--    DECLARE @PrefixString VARCHAR(20)
--    DECLARE @SerialLen INT

--    -- Declare Columns Variable
--  DECLARE @OldMaterialQcNo VARCHAR(20)
--  DECLARE @MaterialQcNo VARCHAR(20)
--  DECLARE @IQCSampleLotList NVARCHAR(MAX)


--	DECLARE @iDoc INT

--    EXEC usp_GetSerialRule 
--			@pTableName = 'STB_MaterialQcInfo',
--			@pIsAutoKey = @IsAutoKey OUTPUT,
--			@pIsLoopIUD = @IsLoopIUD OUTPUT,
--			@pPrefixData = @PrefixString OUTPUT,
--			@pSerialLen = @SerialLen OUTPUT
    
--    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
--        PRINT 'Batch was removed'
--    END ELSE BEGIN
        
--        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
--        BEGIN TRY
--		    DECLARE SourceData CURSOR FOR
--                SELECT
--                        'INSERT' AS IUD_FLAG,
--									OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @InsertTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											)
--							UNION ALL
--							SELECT
--									'UPDATE' AS IUD_FLAG,
--									CASE 
--										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
--										ELSE OldMaterialQcNo
--									END AS OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @UpdateTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											)
--							UNION ALL
--							SELECT
--									'DELETE' AS IUD_FLAG,
--									CASE 
--										WHEN OldMaterialQcNo IS NULL THEN MaterialQcNo
--										ELSE OldMaterialQcNo
--									END AS OldMaterialQcNo,
--									MaterialQcNo,
--									IQCSampleLotList
--							FROM
--									OPENXML(@idoc , @DeleteTableName , 2)
--							        WITH  (
--											 OldMaterialQcNo VARCHAR(20),
--											 MaterialQcNo VARCHAR(20),
--											 IQCSampleLotList NVARCHAR(MAX)
--											) 


--            OPEN SourceData

--            WHILE 1 = 1 BEGIN
--                FETCH NEXT FROM SourceData INTO
--								 @IUD_FLAG,
--								 @OldMaterialQcNo,
--								 @MaterialQcNo,
--								 @IQCSampleLotList


--                IF @@FETCH_STATUS <> 0 BEGIN
--					BREAK
--				END
--                IF @IUD_FLAG = 'INSERT' BEGIN

--                    IF EXISTS (SELECT 1 FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo) BEGIN
--						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialQcNo)
--					END

--                    IF @IsAutoKey = 1 BEGIN
--                        EXEC usp_DoCreateSerial 'STB_MaterialQcInfo',@MaterialQcNo OUTPUT
--                    END

--                    INSERT INTO STB_MaterialQcInfo
--						(
--						    MaterialQcNo,
--						    IQCSampleLotList
--						)
--						VALUES
--						(
--						    @MaterialQcNo,
--						    @IQCSampleLotList
--						)

--				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
--                    UPDATE STB_MaterialQcInfo
--						SET
--						    MaterialQcNo =   ISNULL(@MaterialQcNo,MaterialQcNo),
--						    IQCSampleLotList =   ISNULL(@IQCSampleLotList,IQCSampleLotList)
--						WHERE
--						    MaterialQcNo = @OldMaterialQcNo
--                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
--                    DELETE FROM STB_MaterialQcInfo
--						WHERE
--						    MaterialQcNo = @OldMaterialQcNo
--                END
--            END
--        END TRY
--		BEGIN CATCH
--			SET @ERROR_MSG = ERROR_MESSAGE()
--			RAISERROR( @ERROR_MSG ,16, 1)
--		END CATCH
			
--		CLOSE SourceData;
--		DEALLOCATE SourceData;
			
--		EXEC sp_xml_removedocument @idoc	

--    END
--END
