-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ExportReference_iud]
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
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldID INT
  DECLARE @ID INT
  DECLARE @No nvarchar(50)
  DECLARE @Customer nvarchar(50)
  DECLARE @DateBasic date
  DECLARE @Description nvarchar(500)
  DECLARE @CreateDateTime datetime
  DECLARE @CreateUserID nvarchar(20)
  DECLARE @ChangeDateTime datetime
  DECLARE @ChangeUserID nvarchar(20)


	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.No,
								XMLData.Customer,
								XMLData.DateBasic,
								XMLData.Description,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										No nvarchar(50),
										Customer nvarchar(50),
										DateBasic date,
										Description nvarchar(500),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.No,
								XMLData.Customer,
								XMLData.DateBasic,
								XMLData.Description,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											No nvarchar(50),
											Customer nvarchar(50),
											DateBasic date,
											Description nvarchar(500),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.No,
								XMLData.Customer,
								XMLData.DateBasic,
								XMLData.Description,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											No nvarchar(50),
											Customer nvarchar(50),
											DateBasic date,
											Description nvarchar(500),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldID,
								@ID,
								@No,
								@Customer,
								@DateBasic,
								@Description,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'
				-- Get Max No and Create Next No
				--Declare @MaxNo INT
				--       ,@NextNo INT

				--SELECT @MaxNo = ISNULL(MAX(No), 0)
				--  FROM Stb_MeetingAgenda
				-- WHERE Date_Meeting = @Date_Meeting

				--SET @NextNo = @MaxNo + 1

				--PRINT @NextNo

                INSERT INTO Stb_ExportReference
					(
						No,
						Customer,
						DateBasic,
						Description,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
					    @No,
						@Customer,
						Dateadd(day,1,@DateBasic),
						@Description,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE Stb_ExportReference
					SET
						No =   CASE
						            WHEN @No IS NOT NULL THEN @No
						            ELSE No
						        END,
						Customer =   CASE
						            WHEN @Customer IS NOT NULL THEN @Customer
						            ELSE Customer
						        END,
						DateBasic =   CASE
						            WHEN @DateBasic IS NOT NULL THEN Dateadd(day,1,@DateBasic)
						            ELSE DateBasic
						        END,
						Description =   CASE
						            WHEN @Description IS NOT NULL THEN @Description
						            ELSE Description
						        END,
						CreateDateTime =   CASE
						            WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						            ELSE CreateDateTime
						        END,
						CreateUserID =   CASE
						            WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						            ELSE CreateUserID
						        END,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
					WHERE
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM Stb_ExportReference
					WHERE
						ID = @ID
            END
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


