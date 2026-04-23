-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_DoMakeMaterialQcSampleResult_BendingCutting
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
    DECLARE @MaxKeyInt INT --
	DECLARE @VVTMaxKeyInt  INT --

    -- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcDetailNo INT
	DECLARE @SampleQty INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcSampleResult_BendingCutting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
						XMLData.MaterialQcNo,
						XMLData.MaterialQcDetailNo,
						XMLData.SampleQty
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 MaterialQcNo VARCHAR(20),
								 MaterialQcDetailNo INT,
								 SampleQty INT
								) XMLData

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @SampleQty

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				SELECT
						@MaxKeyInt = ISNULL(MAX(MaterialQcSampleNo), 0)
				FROM
						STB_MaterialQcSampleResult_BendingCutting 
				WHERE
						MaterialQcNo = @MaterialQcNo AND
						MaterialQcDetailNo = @MaterialQcDetailNo


				--for Vietnam Only
				-- edit by Mr.Tung
				--on 2021-02-02
				if(@MaterialQcNo like 'V%' or @MaterialQcNo like 'M%') begin

					select @VVTMaxKeyInt = @MaxKeyInt;  -- add by Tung on 2021-02-02

						SELECT
								@MaxKeyInt = ISNULL(COUNT(MaterialQcSampleNo), 0) --using COUNT instead of MAX function
						FROM
								STB_MaterialQcSampleResult_BendingCutting 
						WHERE
								MaterialQcNo = @MaterialQcNo AND
								MaterialQcDetailNo = @MaterialQcDetailNo
						
				end
				--end by Tung on 2021-02-02


				-------2021.02.05 Test
				--	if(@MaterialQcNo IN ('VJLJ312R750604','VJLJ312R750622','VJLJ312R750625'))
					
				--	begin

				--		SELECT
				--				--@MaxKeyInt = ISNULL(COUNT(MaterialQcSampleNo), 0) --using COUNT instead of MAX function
				--				@MaxKeyInt = 30
				--		FROM
				--				STB_MaterialQcSampleResult 
				--		WHERE 1=1
				--		  -- AND MaterialQcNo = @MaterialQcNo 
				--		  --AND MaterialQcDetailNo = @MaterialQcDetailNo
				--		   AND MaterialQcNo in ('VJLJ312R750604','VJLJ312R750622','VJLJ312R750625')
				--		   AND MaterialQcDetailNo = '20'
						
				--end
				---- 2021.02.05




				
				-- 샘플리스트의 맥스값이 SampleQty 보다 클 경우 Break
				IF @MaxKeyInt >= (
				                            SELECT
													CASE WHEN ISNULL(SampleQty, 0) = 0 THEN RequestSampleQty ELSE ISNULL(SampleQty, 0) END
											FROM
													STB_MaterialQcDetail_BendingCutting 
											WHERE
													MaterialQcNo = @MaterialQcNo AND
													MaterialQcDetailNo = @MaterialQcDetailNo
										 )
				BEGIN
					BREAK
				END

			
				WHILE @MaxKeyInt < @SampleQty BEGIN
				
					SET @MaxKeyInt += 1
					
					
					INSERT INTO STB_MaterialQcSampleResult_BendingCutting
					(
						MaterialQcNo,
						MaterialQcDetailNo,
						MaterialQcSampleNo,
						CreateDateTime,
						CreateUserID
					)
					VALUES
					(
						@MaterialQcNo,
						@MaterialQcDetailNo,
						--@MaxKeyInt,
						case when @MaterialQcNo like 'V%' or @MaterialQcNo like 'M%' then @VVTMaxKeyInt + @MaxKeyInt else @MaxKeyInt end,  -- add by Tung on 2021-02-02 MAX + COUNT value
						GETDATE(),
						@pProcessUserID
					)
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
END
