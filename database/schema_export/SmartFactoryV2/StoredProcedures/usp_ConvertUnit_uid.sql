-- Procedure: usp_ConvertUnit_uid
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-04
-- Description:	Thêm dữ liệu chuyển đổi đơn vị
-- =============================================
CREATE PROCEDURE usp_ConvertUnit_uid
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
		DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	    DECLARE @ERROR_MSG NVARCHAR(MAX)
	  DECLARE @IUD_FLAG VARCHAR(10)
	Declare @ID int,
			@MaterialCode	varchar(50),
			@ConvertRate	numeric(38,19),
			@TargetUnit		varchar(20),
			@BaseUnit		varchar(20),
			@CreateDateTime		datetime,
			@CreateUserID	varchar(50),
			@ChangeDateTime datetime,
			@ChangeUserID	varchar(50)
		DECLARE @iDoc INT
	SET NOCOUNT ON;

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							MaterialCode,	
							ConvertRate	,
							TargetUnit,		
							BaseUnit	,	
							CreateDateTime	,
							CreateUserID	,
							ChangeDateTime ,
							ChangeUserID	

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										MaterialCode	varchar(50),
										ConvertRate	numeric(38,19),
										TargetUnit		varchar(20),
										BaseUnit		varchar(20),
										CreateDateTime		datetime,
										CreateUserID	varchar(50),
										ChangeDateTime datetime,
										ChangeUserID	varchar(50)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							MaterialCode,	
							ConvertRate	,
							TargetUnit,		
							BaseUnit	,	
							CreateDateTime	,
							CreateUserID	,
							ChangeDateTime ,
							ChangeUserID	
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										MaterialCode	varchar(50),
										ConvertRate	numeric(38,19),
										TargetUnit		varchar(20),
										BaseUnit		varchar(20),
										CreateDateTime		datetime,
										CreateUserID	varchar(50),
										ChangeDateTime datetime,
										ChangeUserID	varchar(50)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							MaterialCode,	
							ConvertRate	,
							TargetUnit,		
							BaseUnit	,	
							CreateDateTime	,
							CreateUserID	,
							ChangeDateTime ,
							ChangeUserID	
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										MaterialCode	varchar(50),
										ConvertRate	numeric(38,19),
										TargetUnit		varchar(20),
										BaseUnit		varchar(20),
										CreateDateTime		datetime,
										CreateUserID	varchar(50),
										ChangeDateTime datetime,
										ChangeUserID	varchar(50)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@MaterialCode	,
								@ConvertRate	,
								@TargetUnit		,
								@BaseUnit		,
								@CreateDateTime	,
								@CreateUserID	,
								@ChangeDateTime ,
								@ChangeUserID	
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_UnitConversion WHERE MaterialCode = @MaterialCode)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

					INSERT INTO STB_UnitConversion
						(
							MaterialCode,	
							ConvertRate	,
							TargetUnit,		
							BaseUnit	,	
							CreateDateTime	,
							CreateUserID	
						)
						VALUES
						(
							@MaterialCode	,
							@ConvertRate	,
							@TargetUnit		,
							@BaseUnit		,
							getdate(),
							@ProcessUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_UnitConversion
						SET

							ConvertRate = ISNULL(@ConvertRate, ConvertRate),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							MaterialCode = @MaterialCode

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_UnitConversion
						WHERE
							MaterialCode = @MaterialCode

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
    --END
END

GO

