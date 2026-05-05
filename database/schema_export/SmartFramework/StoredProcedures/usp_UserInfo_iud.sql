-- Procedure: usp_UserInfo_iud





-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-09
-- Browsable : true
-- Group : 공용
-- Description:	사용자 정보를 INSERT/UUPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pIsUseDefaultSystemCode BIT = 1
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
  DECLARE @OldUserID VARCHAR(20)
  DECLARE @UserID VARCHAR(20)
  DECLARE @UserName NVARCHAR(100)
  DECLARE @Password NVARCHAR(100)
  DECLARE @Phone VARCHAR(20)
  DECLARE @Mobile VARCHAR(20)
  DECLARE @Email VARCHAR(40)
  DECLARE @AllowFlag VARCHAR(20)
  DECLARE @UserImg VARBINARY(MAX)
  DECLARE @LastLoginDateTime DATETIME
  DECLARE @CanMakeReport BIT
  DECLARE @IsDeveloper BIT
  DECLARE @Appendix1 NVARCHAR(100)
  DECLARE @Appendix2 NVARCHAR(100)
  DECLARE @Appendix3 NVARCHAR(100)
  DECLARE @Appendix4 NVARCHAR(100)
  DECLARE @Appendix5 NVARCHAR(100)
  DECLARE @Appendix6 NVARCHAR(100)
  DECLARE @Appendix7 NVARCHAR(100)
  DECLARE @Appendix8 NVARCHAR(100)
  DECLARE @Appendix9 NVARCHAR(100)
  DECLARE @Appendix10 NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @ChangeDateTime DATETIME
  DECLARE @SystemCode VARCHAR(20)
  DECLARE @DefaultSystemCode VARCHAR(20)
  DECLARE @IsUseDefaultSystemCode BIT = @pIsUseDefaultSystemCode


	SELECT
			@DefaultSystemCode = CCI.ConstValue
	FROM
			STB_ConstCodeInfo CCI
	WHERE
			CCI.ConstName = 'DefaultSystemCode'

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UserInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							UserName,
							Password,
							Phone,
							Mobile,
							Email,
							AllowFlag,
							dbo.fnBase64ToBinary(UserImg) as UserImg,
							LastLoginDateTime,
							CanMakeReport,
							IsDeveloper,
							Appendix1,
							Appendix2,
							Appendix3,
							Appendix4,
							Appendix5,
							Appendix6,
							Appendix7,
							Appendix8,
							Appendix9,
							Appendix10,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime,
						 	SystemCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										UserName NVARCHAR(100),
										Password NVARCHAR(100),
										Phone VARCHAR(20),
										Mobile VARCHAR(20),
										Email VARCHAR(40),
										AllowFlag VARCHAR(20),
										UserImg NVARCHAR(MAX),
										LastLoginDateTime DATETIMEOFFSET,
										CanMakeReport BIT,
										IsDeveloper BIT,
										Appendix1 NVARCHAR(100),
										Appendix2 NVARCHAR(100),
										Appendix3 NVARCHAR(100),
										Appendix4 NVARCHAR(100),
										Appendix5 NVARCHAR(100),
										Appendix6 NVARCHAR(100),
										Appendix7 NVARCHAR(100),
										Appendix8 NVARCHAR(100),
										Appendix9 NVARCHAR(100),
										Appendix10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET,
										SystemCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = ISNULL(SourceTable.UserID,TargetTable.UserID),
					UserName = ISNULL(SourceTable.UserName,TargetTable.UserName),
					Password = CASE WHEN ISNULL(SourceTable.Password,'') = '' THEN TargetTable.Password ELSE PWDENCRYPT(SourceTable.Password) END,
					Phone = ISNULL(SourceTable.Phone,TargetTable.Phone),
					Mobile = ISNULL(SourceTable.Mobile,TargetTable.Mobile),
					Email = ISNULL(SourceTable.Email,TargetTable.Email),
					AllowFlag = ISNULL(SourceTable.AllowFlag,TargetTable.AllowFlag),
					UserImg = ISNULL(SourceTable.UserImg,TargetTable.UserImg),
					LastLoginDateTime = ISNULL(SourceTable.LastLoginDateTime,TargetTable.LastLoginDateTime),
					CanMakeReport = ISNULL(SourceTable.CanMakeReport,TargetTable.CanMakeReport),
					IsDeveloper = ISNULL(SourceTable.IsDeveloper,TargetTable.IsDeveloper),
					Appendix1 = ISNULL(SourceTable.Appendix1,TargetTable.Appendix1),
					Appendix2 = ISNULL(SourceTable.Appendix2,TargetTable.Appendix2),
					Appendix3 = ISNULL(SourceTable.Appendix3,TargetTable.Appendix3),
					Appendix4 = ISNULL(SourceTable.Appendix4,TargetTable.Appendix4),
					Appendix5 = ISNULL(SourceTable.Appendix5,TargetTable.Appendix5),
					Appendix6 = ISNULL(SourceTable.Appendix6,TargetTable.Appendix6),
					Appendix7 = ISNULL(SourceTable.Appendix7,TargetTable.Appendix7),
					Appendix8 = ISNULL(SourceTable.Appendix8,TargetTable.Appendix8),
					Appendix9 = ISNULL(SourceTable.Appendix9,TargetTable.Appendix9),
					Appendix10 = ISNULL(SourceTable.Appendix10,TargetTable.Appendix10),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					SystemCode = ISNULL(SourceTable.SystemCode, TargetTable.SystemCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						UserName,
						Password,
						Phone,
						Mobile,
						Email,
						AllowFlag,
						UserImg,
						LastLoginDateTime,
						CanMakeReport,
						IsDeveloper,
						Appendix1,
						Appendix2,
						Appendix3,
						Appendix4,
						Appendix5,
						Appendix6,
						Appendix7,
						Appendix8,
						Appendix9,
						Appendix10,
						CreateDateTime,
						SystemCode
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.UserName,
							PWDENCRYPT(SourceTable.Password),
							SourceTable.Phone,
							SourceTable.Mobile,
							SourceTable.Email,
							SourceTable.AllowFlag,
							SourceTable.UserImg,
							SourceTable.LastLoginDateTime,
							SourceTable.CanMakeReport,
							SourceTable.IsDeveloper,
							SourceTable.Appendix1,
							SourceTable.Appendix2,
							SourceTable.Appendix3,
							SourceTable.Appendix4,
							SourceTable.Appendix5,
							SourceTable.Appendix6,
							SourceTable.Appendix7,
							SourceTable.Appendix8,
							SourceTable.Appendix9,
							SourceTable.Appendix10,
							SourceTable.CreateDateTime,
							CASE WHEN @IsUseDefaultSystemCode = 1 THEN @DefaultSystemCode ELSE SourceTable.SystemCode END
					);


			-- Process Update Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							UserName,
							Password,
							Phone,
							Mobile,
							Email,
							AllowFlag,
							dbo.fnBase64ToBinary(UserImg) as UserImg,
							LastLoginDateTime,
							CanMakeReport,
							IsDeveloper,
							Appendix1,
							Appendix2,
							Appendix3,
							Appendix4,
							Appendix5,
							Appendix6,
							Appendix7,
							Appendix8,
							Appendix9,
							Appendix10,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime,
							SystemCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										UserName NVARCHAR(100),
										Password NVARCHAR(100),
										Phone VARCHAR(20),
										Mobile VARCHAR(20),
										Email VARCHAR(40),
										AllowFlag VARCHAR(20),
										UserImg NVARCHAR(MAX),
										LastLoginDateTime DATETIMEOFFSET,
										CanMakeReport BIT,
										IsDeveloper BIT,
										Appendix1 NVARCHAR(100),
										Appendix2 NVARCHAR(100),
										Appendix3 NVARCHAR(100),
										Appendix4 NVARCHAR(100),
										Appendix5 NVARCHAR(100),
										Appendix6 NVARCHAR(100),
										Appendix7 NVARCHAR(100),
										Appendix8 NVARCHAR(100),
										Appendix9 NVARCHAR(100),
										Appendix10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET,
										SystemCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.OldUserID
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = ISNULL(SourceTable.UserID,TargetTable.UserID),
					UserName = ISNULL(SourceTable.UserName,TargetTable.UserName),
					Password = CASE WHEN ISNULL(SourceTable.Password,'') = '' THEN TargetTable.Password ELSE PWDENCRYPT(SourceTable.Password) END,
					Phone = ISNULL(SourceTable.Phone,TargetTable.Phone),
					Mobile = ISNULL(SourceTable.Mobile,TargetTable.Mobile),
					Email = ISNULL(SourceTable.Email,TargetTable.Email),
					AllowFlag = ISNULL(SourceTable.AllowFlag,TargetTable.AllowFlag),
					UserImg = ISNULL(SourceTable.UserImg,TargetTable.UserImg),
					LastLoginDateTime = ISNULL(SourceTable.LastLoginDateTime,TargetTable.LastLoginDateTime),
					CanMakeReport = ISNULL(SourceTable.CanMakeReport,TargetTable.CanMakeReport),
					IsDeveloper = ISNULL(SourceTable.IsDeveloper,TargetTable.IsDeveloper),
					Appendix1 = ISNULL(SourceTable.Appendix1,TargetTable.Appendix1),
					Appendix2 = ISNULL(SourceTable.Appendix2,TargetTable.Appendix2),
					Appendix3 = ISNULL(SourceTable.Appendix3,TargetTable.Appendix3),
					Appendix4 = ISNULL(SourceTable.Appendix4,TargetTable.Appendix4),
					Appendix5 = ISNULL(SourceTable.Appendix5,TargetTable.Appendix5),
					Appendix6 = ISNULL(SourceTable.Appendix6,TargetTable.Appendix6),
					Appendix7 = ISNULL(SourceTable.Appendix7,TargetTable.Appendix7),
					Appendix8 = ISNULL(SourceTable.Appendix8,TargetTable.Appendix8),
					Appendix9 = ISNULL(SourceTable.Appendix9,TargetTable.Appendix9),
					Appendix10 = ISNULL(SourceTable.Appendix10,TargetTable.Appendix10),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					SystemCode = ISNULL(SourceTable.SystemCode, TargetTable.SystemCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						UserName,
						Password,
						Phone,
						Mobile,
						Email,
						AllowFlag,
						UserImg,
						LastLoginDateTime,
						CanMakeReport,
						IsDeveloper,
						Appendix1,
						Appendix2,
						Appendix3,
						Appendix4,
						Appendix5,
						Appendix6,
						Appendix7,
						Appendix8,
						Appendix9,
						Appendix10,
						CreateDateTime,
						SystemCode
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.UserName,
							PWDENCRYPT(SourceTable.Password),
							SourceTable.Phone,
							SourceTable.Mobile,
							SourceTable.Email,
							SourceTable.AllowFlag,
							SourceTable.UserImg,
							SourceTable.LastLoginDateTime,
							SourceTable.CanMakeReport,
							SourceTable.IsDeveloper,
							SourceTable.Appendix1,
							SourceTable.Appendix2,
							SourceTable.Appendix3,
							SourceTable.Appendix4,
							SourceTable.Appendix5,
							SourceTable.Appendix6,
							SourceTable.Appendix7,
							SourceTable.Appendix8,
							SourceTable.Appendix9,
							SourceTable.Appendix10,
							SourceTable.CreateDateTime,
							CASE WHEN @IsUseDefaultSystemCode = 1 THEN @DefaultSystemCode ELSE SourceTable.SystemCode END
					);


			-- Process Delete Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							UserName,
							Password,
							Phone,
							Mobile,
							Email,
							AllowFlag,
							dbo.fnBase64ToBinary(UserImg) as UserImg,
							LastLoginDateTime,
							CanMakeReport,
							IsDeveloper,
							Appendix1,
							Appendix2,
							Appendix3,
							Appendix4,
							Appendix5,
							Appendix6,
							Appendix7,
							Appendix8,
							Appendix9,
							Appendix10,
							GETDATE() AS CreateDateTime,
							GETDATE() AS ChangeDateTime,
							SystemCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										UserName NVARCHAR(100),
										Password NVARCHAR(100),
										Phone VARCHAR(20),
										Mobile VARCHAR(20),
										Email VARCHAR(40),
										AllowFlag VARCHAR(20),
										UserImg NVARCHAR(MAX),
										LastLoginDateTime DATETIMEOFFSET,
										CanMakeReport BIT,
										IsDeveloper BIT,
										Appendix1 NVARCHAR(100),
										Appendix2 NVARCHAR(100),
										Appendix3 NVARCHAR(100),
										Appendix4 NVARCHAR(100),
										Appendix5 NVARCHAR(100),
										Appendix6 NVARCHAR(100),
										Appendix7 NVARCHAR(100),
										Appendix8 NVARCHAR(100),
										Appendix9 NVARCHAR(100),
										Appendix10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										ChangeDateTime DATETIMEOFFSET,
										SystemCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID
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
									OldUserID,
									UserID,
									UserName,
									Password,
									Phone,
									Mobile,
									Email,
									AllowFlag,
									dbo.fnBase64ToBinary(UserImg) as UserImg,
									LastLoginDateTime,
									CanMakeReport,
									IsDeveloper,
									Appendix1,
									Appendix2,
									Appendix3,
									Appendix4,
									Appendix5,
									Appendix6,
									Appendix7,
									Appendix8,
									Appendix9,
									Appendix10,
									CreateDateTime,
									ChangeDateTime,
									SystemCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 UserName NVARCHAR(100),
											 Password NVARCHAR(100),
											 Phone VARCHAR(20),
											 Mobile VARCHAR(20),
											 Email VARCHAR(40),
											 AllowFlag VARCHAR(20),
											 UserImg NVARCHAR(MAX),
											 LastLoginDateTime DATETIMEOFFSET,
											 CanMakeReport BIT,
											 IsDeveloper BIT,
											 Appendix1 NVARCHAR(100),
											 Appendix2 NVARCHAR(100),
											 Appendix3 NVARCHAR(100),
											 Appendix4 NVARCHAR(100),
											 Appendix5 NVARCHAR(100),
											 Appendix6 NVARCHAR(100),
											 Appendix7 NVARCHAR(100),
											 Appendix8 NVARCHAR(100),
											 Appendix9 NVARCHAR(100),
											 Appendix10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET,
											 SystemCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									UserID,
									UserName,
									Password,
									Phone,
									Mobile,
									Email,
									AllowFlag,
									dbo.fnBase64ToBinary(UserImg) as UserImg,
									LastLoginDateTime,
									CanMakeReport,
									IsDeveloper,
									Appendix1,
									Appendix2,
									Appendix3,
									Appendix4,
									Appendix5,
									Appendix6,
									Appendix7,
									Appendix8,
									Appendix9,
									Appendix10,
									CreateDateTime,
									ChangeDateTime,
									SystemCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 UserName NVARCHAR(100),
											 Password NVARCHAR(100),
											 Phone VARCHAR(20),
											 Mobile VARCHAR(20),
											 Email VARCHAR(40),
											 AllowFlag VARCHAR(20),
											 UserImg NVARCHAR(MAX),
											 LastLoginDateTime DATETIMEOFFSET,
											 CanMakeReport BIT,
											 IsDeveloper BIT,
											 Appendix1 NVARCHAR(100),
											 Appendix2 NVARCHAR(100),
											 Appendix3 NVARCHAR(100),
											 Appendix4 NVARCHAR(100),
											 Appendix5 NVARCHAR(100),
											 Appendix6 NVARCHAR(100),
											 Appendix7 NVARCHAR(100),
											 Appendix8 NVARCHAR(100),
											 Appendix9 NVARCHAR(100),
											 Appendix10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET,
											 SystemCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									UserID,
									UserName,
									Password,
									Phone,
									Mobile,
									Email,
									AllowFlag,
									dbo.fnBase64ToBinary(UserImg) as UserImg,
									LastLoginDateTime,
									CanMakeReport,
									IsDeveloper,
									Appendix1,
									Appendix2,
									Appendix3,
									Appendix4,
									Appendix5,
									Appendix6,
									Appendix7,
									Appendix8,
									Appendix9,
									Appendix10,
									CreateDateTime,
									ChangeDateTime,
									SystemCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 UserName NVARCHAR(100),
											 Password NVARCHAR(100),
											 Phone VARCHAR(20),
											 Mobile VARCHAR(20),
											 Email VARCHAR(40),
											 AllowFlag VARCHAR(20),
											 UserImg NVARCHAR(MAX),
											 LastLoginDateTime DATETIMEOFFSET,
											 CanMakeReport BIT,
											 IsDeveloper BIT,
											 Appendix1 NVARCHAR(100),
											 Appendix2 NVARCHAR(100),
											 Appendix3 NVARCHAR(100),
											 Appendix4 NVARCHAR(100),
											 Appendix5 NVARCHAR(100),
											 Appendix6 NVARCHAR(100),
											 Appendix7 NVARCHAR(100),
											 Appendix8 NVARCHAR(100),
											 Appendix9 NVARCHAR(100),
											 Appendix10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 ChangeDateTime DATETIMEOFFSET,
											 SystemCode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldUserID,
								 @UserID,
								 @UserName,
								 @Password,
								 @Phone,
								 @Mobile,
								 @Email,
								 @AllowFlag,
								 @UserImg,
								 @LastLoginDateTime,
								 @CanMakeReport,
								 @IsDeveloper,
								 @Appendix1,
								 @Appendix2,
								 @Appendix3,
								 @Appendix4,
								 @Appendix5,
								 @Appendix6,
								 @Appendix7,
								 @Appendix8,
								 @Appendix9,
								 @Appendix10,
								 @CreateDateTime,
								 @ChangeDateTime,
								 @SystemCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UserInfo WHERE UserID = @UserID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @UserID)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(UserID)
						FROM
								STB_UserInfo 
						WHERE
								UserID LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @UserID = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @UserID = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_UserInfo
						(
						    UserID,
						    UserName,
						    Password,
						    Phone,
						    Mobile,
						    Email,
						    AllowFlag,
						    UserImg,
						    LastLoginDateTime,
						    CanMakeReport,
						    IsDeveloper,
						    Appendix1,
						    Appendix2,
						    Appendix3,
						    Appendix4,
						    Appendix5,
						    Appendix6,
						    Appendix7,
						    Appendix8,
						    Appendix9,
						    Appendix10,
						    CreateDateTime,
						    ChangeDateTime,
							SystemCode
						)
						VALUES
						(
						    @UserID,
						    @UserName,
						    PWDENCRYPT(@Password),
						    @Phone,
						    @Mobile,
						    @Email,
						    @AllowFlag,
						    @UserImg,
						    @LastLoginDateTime,
						    @CanMakeReport,
						    @IsDeveloper,
						    @Appendix1,
						    @Appendix2,
						    @Appendix3,
						    @Appendix4,
						    @Appendix5,
						    @Appendix6,
						    @Appendix7,
						    @Appendix8,
						    @Appendix9,
						    @Appendix10,
						    GETDATE(),
						    @ChangeDateTime,
							@SystemCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_UserInfo
						SET
						    UserID =   ISNULL(@UserID,UserID),
						    UserName =   ISNULL(@UserName,UserName),
						    Password =   ISNULL(PWDENCRYPT(@Password),Password),
						    Phone =   ISNULL(@Phone,Phone),
						    Mobile =   ISNULL(@Mobile,Mobile),
						    Email =   ISNULL(@Email,Email),
						    AllowFlag =   ISNULL(@AllowFlag,AllowFlag),
						    UserImg =   ISNULL(@UserImg,UserImg),
						    LastLoginDateTime =   ISNULL(@LastLoginDateTime,LastLoginDateTime),
						    CanMakeReport =   ISNULL(@CanMakeReport,CanMakeReport),
						    IsDeveloper =   ISNULL(@IsDeveloper,IsDeveloper),
						    Appendix1 =   ISNULL(@Appendix1,Appendix1),
						    Appendix2 =   ISNULL(@Appendix2,Appendix2),
						    Appendix3 =   ISNULL(@Appendix3,Appendix3),
						    Appendix4 =   ISNULL(@Appendix4,Appendix4),
						    Appendix5 =   ISNULL(@Appendix5,Appendix5),
						    Appendix6 =   ISNULL(@Appendix6,Appendix6),
						    Appendix7 =   ISNULL(@Appendix7,Appendix7),
						    Appendix8 =   ISNULL(@Appendix8,Appendix8),
						    Appendix9 =   ISNULL(@Appendix9,Appendix9),
						    Appendix10 =   ISNULL(@Appendix10,Appendix10),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    ChangeDateTime = GETDATE(),
							SystemCode = ISNULL(@SystemCode, SystemCode)
						WHERE
						    UserID = @OldUserID
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_UserInfo
						WHERE
						    UserID = @UserID
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

	EXEC SmartFactoryV2.dbo.usp_UserInfo_iud	@pProcessUserID = @ProcessUserID,
												@pProcessLanguage = @ProcessLanguage,
												@pProcessViewName = @ProcessViewName,
												@pXml = @pXml
END





GO

