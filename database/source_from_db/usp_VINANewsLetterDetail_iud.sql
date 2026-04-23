
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VINANewsLetterDetail_iud]
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

    -- Declare Columns Variable
  DECLARE @OldNewsLetterDetailNo VARCHAR(20)
  DECLARE @NewsLetterDetailNo VARCHAR(20)
  DECLARE @NewsLetterNo VARCHAR(10)
  DECLARE @Title VARCHAR(200)
  DECLARE @TitleAlign VARCHAR(10)
  DECLARE @ImagePath VARCHAR(500)
  DECLARE @ImageAlign VARCHAR(10)
  DECLARE @ImageText VARCHAR(500)
  DECLARE @ImageTextAlign VARCHAR(10)
  DECLARE @Text VARCHAR(MAX)
  DECLARE @TextAlign VARCHAR(10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @ImageWidth INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VINANewsLetterDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_VINANewsLetterDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterDetailNo IS NULL THEN NewsLetterDetailNo
							    ELSE OldNewsLetterDetailNo
							END AS OldNewsLetterDetailNo,
							NewsLetterDetailNo,
							NewsLetterNo,
							Title,
							TitleAlign,
							ImagePath,
							ImageAlign,
							ImageText,
							ImageTextAlign,
							Text,
							TextAlign,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ImageWidth
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldNewsLetterDetailNo VARCHAR(20),
										NewsLetterDetailNo VARCHAR(20),
										NewsLetterNo VARCHAR(10),
										Title VARCHAR(200),
										TitleAlign VARCHAR(10),
										ImagePath VARCHAR(500),
										ImageAlign VARCHAR(10),
										ImageText VARCHAR(500),
										ImageTextAlign VARCHAR(10),
										Text VARCHAR(MAX),
										TextAlign VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ImageWidth INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterDetailNo = SourceTable.NewsLetterDetailNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NewsLetterNo = ISNULL(SourceTable.NewsLetterNo,TargetTable.NewsLetterNo),
					Title = ISNULL(SourceTable.Title,TargetTable.Title),
					TitleAlign = ISNULL(SourceTable.TitleAlign,TargetTable.TitleAlign),
					ImagePath = ISNULL(SourceTable.ImagePath,TargetTable.ImagePath),
					ImageAlign = ISNULL(SourceTable.ImageAlign,TargetTable.ImageAlign),
					ImageText = ISNULL(SourceTable.ImageText,TargetTable.ImageText),
					ImageTextAlign = ISNULL(SourceTable.ImageTextAlign,TargetTable.ImageTextAlign),
					Text = ISNULL(SourceTable.Text,TargetTable.Text),
					TextAlign = ISNULL(SourceTable.TextAlign,TargetTable.TextAlign),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ImageWidth = ISNULL(SourceTable.ImageWidth,TargetTable.ImageWidth)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NewsLetterDetailNo,
						NewsLetterNo,
						Title,
						TitleAlign,
						ImagePath,
						ImageAlign,
						ImageText,
						ImageTextAlign,
						Text,
						TextAlign,
						CreateDateTime,
						CreateUserID,
						ImageWidth
					)
				VALUES
					(
							SourceTable.NewsLetterDetailNo,
							SourceTable.NewsLetterNo,
							SourceTable.Title,
							SourceTable.TitleAlign,
							SourceTable.ImagePath,
							SourceTable.ImageAlign,
							SourceTable.ImageText,
							SourceTable.ImageTextAlign,
							SourceTable.Text,
							SourceTable.TextAlign,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ImageWidth
					);


			-- Process Update Table
            MERGE STB_VINANewsLetterDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterDetailNo IS NULL THEN NewsLetterDetailNo
							    ELSE OldNewsLetterDetailNo
							END AS OldNewsLetterDetailNo,
							NewsLetterDetailNo,
							NewsLetterNo,
							Title,
							TitleAlign,
							ImagePath,
							ImageAlign,
							ImageText,
							ImageTextAlign,
							Text,
							TextAlign,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ImageWidth
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldNewsLetterDetailNo VARCHAR(20),
										NewsLetterDetailNo VARCHAR(20),
										NewsLetterNo VARCHAR(10),
										Title VARCHAR(200),
										TitleAlign VARCHAR(10),
										ImagePath VARCHAR(500),
										ImageAlign VARCHAR(10),
										ImageText VARCHAR(500),
										ImageTextAlign VARCHAR(10),
										Text VARCHAR(MAX),
										TextAlign VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ImageWidth INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterDetailNo = SourceTable.OldNewsLetterDetailNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NewsLetterNo = ISNULL(SourceTable.NewsLetterNo,TargetTable.NewsLetterNo),
					Title = ISNULL(SourceTable.Title,TargetTable.Title),
					TitleAlign = ISNULL(SourceTable.TitleAlign,TargetTable.TitleAlign),
					ImagePath = ISNULL(SourceTable.ImagePath,TargetTable.ImagePath),
					ImageAlign = ISNULL(SourceTable.ImageAlign,TargetTable.ImageAlign),
					ImageText = ISNULL(SourceTable.ImageText,TargetTable.ImageText),
					ImageTextAlign = ISNULL(SourceTable.ImageTextAlign,TargetTable.ImageTextAlign),
					Text = ISNULL(SourceTable.Text,TargetTable.Text),
					TextAlign = ISNULL(SourceTable.TextAlign,TargetTable.TextAlign),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					ImageWidth = ISNULL(SourceTable.ImageWidth,TargetTable.ImageWidth)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NewsLetterDetailNo,
						NewsLetterNo,
						Title,
						TitleAlign,
						ImagePath,
						ImageAlign,
						ImageText,
						ImageTextAlign,
						Text,
						TextAlign,
						CreateDateTime,
						CreateUserID,
						ImageWidth
					)
				VALUES
					(
							SourceTable.NewsLetterDetailNo,
							SourceTable.NewsLetterNo,
							SourceTable.Title,
							SourceTable.TitleAlign,
							SourceTable.ImagePath,
							SourceTable.ImageAlign,
							SourceTable.ImageText,
							SourceTable.ImageTextAlign,
							SourceTable.Text,
							SourceTable.TextAlign,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ImageWidth
					);


			-- Process Delete Table
            MERGE STB_VINANewsLetterDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNewsLetterDetailNo IS NULL THEN NewsLetterDetailNo
							    ELSE OldNewsLetterDetailNo
							END AS OldNewsLetterDetailNo,
							NewsLetterDetailNo,
							NewsLetterNo,
							Title,
							TitleAlign,
							ImagePath,
							ImageAlign,
							ImageText,
							ImageTextAlign,
							Text,
							TextAlign,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							ImageWidth
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldNewsLetterDetailNo VARCHAR(20),
										NewsLetterDetailNo VARCHAR(20),
										NewsLetterNo VARCHAR(10),
										Title VARCHAR(200),
										TitleAlign VARCHAR(10),
										ImagePath VARCHAR(500),
										ImageAlign VARCHAR(10),
										ImageText VARCHAR(500),
										ImageTextAlign VARCHAR(10),
										Text VARCHAR(MAX),
										TextAlign VARCHAR(10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ImageWidth INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NewsLetterDetailNo = SourceTable.NewsLetterDetailNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldNewsLetterDetailNo,
									NewsLetterDetailNo,
									NewsLetterNo,
									Title,
									TitleAlign,
									ImagePath,
									ImageAlign,
									ImageText,
									ImageTextAlign,
									Text,
									TextAlign,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ImageWidth
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldNewsLetterDetailNo VARCHAR(20),
											 NewsLetterDetailNo VARCHAR(20),
											 NewsLetterNo VARCHAR(10),
											 Title VARCHAR(200),
											 TitleAlign VARCHAR(10),
											 ImagePath VARCHAR(500),
											 ImageAlign VARCHAR(10),
											 ImageText VARCHAR(500),
											 ImageTextAlign VARCHAR(10),
											 Text VARCHAR(MAX),
											 TextAlign VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ImageWidth INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldNewsLetterDetailNo IS NULL THEN NewsLetterDetailNo
										ELSE OldNewsLetterDetailNo
									END AS OldNewsLetterDetailNo,
									NewsLetterDetailNo,
									NewsLetterNo,
									Title,
									TitleAlign,
									ImagePath,
									ImageAlign,
									ImageText,
									ImageTextAlign,
									Text,
									TextAlign,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ImageWidth
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldNewsLetterDetailNo VARCHAR(20),
											 NewsLetterDetailNo VARCHAR(20),
											 NewsLetterNo VARCHAR(10),
											 Title VARCHAR(200),
											 TitleAlign VARCHAR(10),
											 ImagePath VARCHAR(500),
											 ImageAlign VARCHAR(10),
											 ImageText VARCHAR(500),
											 ImageTextAlign VARCHAR(10),
											 Text VARCHAR(MAX),
											 TextAlign VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ImageWidth INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldNewsLetterDetailNo IS NULL THEN NewsLetterDetailNo
										ELSE OldNewsLetterDetailNo
									END AS OldNewsLetterDetailNo,
									NewsLetterDetailNo,
									NewsLetterNo,
									Title,
									TitleAlign,
									ImagePath,
									ImageAlign,
									ImageText,
									ImageTextAlign,
									Text,
									TextAlign,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									ImageWidth
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldNewsLetterDetailNo VARCHAR(20),
											 NewsLetterDetailNo VARCHAR(20),
											 NewsLetterNo VARCHAR(10),
											 Title VARCHAR(200),
											 TitleAlign VARCHAR(10),
											 ImagePath VARCHAR(500),
											 ImageAlign VARCHAR(10),
											 ImageText VARCHAR(500),
											 ImageTextAlign VARCHAR(10),
											 Text VARCHAR(MAX),
											 TextAlign VARCHAR(10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 ImageWidth INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldNewsLetterDetailNo,
								 @NewsLetterDetailNo,
								 @NewsLetterNo,
								 @Title,
								 @TitleAlign,
								 @ImagePath,
								 @ImageAlign,
								 @ImageText,
								 @ImageTextAlign,
								 @Text,
								 @TextAlign,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @ImageWidth


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VINANewsLetterDetail WHERE NewsLetterDetailNo = @NewsLetterDetailNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @NewsLetterDetailNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VINANewsLetterDetail',@NewsLetterDetailNo OUTPUT
                    END

                    INSERT INTO STB_VINANewsLetterDetail
						(
						    NewsLetterDetailNo,
						    NewsLetterNo,
						    Title,
						    TitleAlign,
						    ImagePath,
						    ImageAlign,
						    ImageText,
						    ImageTextAlign,
						    Text,
						    TextAlign,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    ImageWidth
						)
						VALUES
						(
						    @NewsLetterDetailNo,
						    @NewsLetterNo,
						    @Title,
						    @TitleAlign,
						    @ImagePath,
						    @ImageAlign,
						    @ImageText,
						    @ImageTextAlign,
						    @Text,
						    @TextAlign,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @ImageWidth
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_VINANewsLetterDetail
						SET
						    NewsLetterNo =   ISNULL(@NewsLetterNo,NewsLetterNo),
						    Title =   ISNULL(@Title,Title),
						    TitleAlign =   ISNULL(@TitleAlign,TitleAlign),
						    ImagePath =   ISNULL(@ImagePath,ImagePath),
						    ImageAlign =   ISNULL(@ImageAlign,ImageAlign),
						    ImageText =   ISNULL(@ImageText,ImageText),
						    ImageTextAlign =   ISNULL(@ImageTextAlign,ImageTextAlign),
						    Text =   ISNULL(@Text,Text),
						    TextAlign =   ISNULL(@TextAlign,TextAlign),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    ImageWidth =   ISNULL(@ImageWidth,ImageWidth)
						WHERE
						    NewsLetterDetailNo = @OldNewsLetterDetailNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_VINANewsLetterDetail
						WHERE
						    NewsLetterDetailNo = @OldNewsLetterDetailNo
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
