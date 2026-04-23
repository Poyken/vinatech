-- =============================================
-- Author: ngoloan
-- Create date: 2020-12-07

-- =============================================
CREATE PROCEDURE [dbo].[usp_EmployeeDepartment_iud]
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
  DECLARE @OldCodeEmp VARCHAR(20)
  DECLARE @CodeEmp NVARCHAR(50)
  DECLARE @Name NVARCHAR(200)
  DECLARE @Department NVARCHAR(200)
  DECLARE @Sex NVARCHAR(200)
  DECLARE @Birthday NVARCHAR(200)
  DECLARE @Address NVARCHAR(200)
  DECLARE @PhoneNumber NVARCHAR(200)
  DECLARE @Description NVARCHAR(200)
  DECLARE @Attribute NVARCHAR(200)
  DECLARE @Attribute1 NVARCHAR(200)
  DECLARE @Attribute2 NVARCHAR(200)
  DECLARE @Attribute3 NVARCHAR(200)
  DECLARE @Attribute4 NVARCHAR(200)
  DECLARE @Attribute5 NVARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @PartName NVARCHAR(100)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'Stb_EmployeeDepartment',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE Stb_EmployeeDepartment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCodeEmp IS NULL THEN XMLData.OldCodeEmp
							    ELSE XMLData.OldCodeEmp
							END AS OldCodeEmp,
							XMLData.CodeEmp,
							XMLData.Name,
							XMLData.Department,
							XMLData.Sex,
							XMLData.Birthday,
							XMLData.Address,
							XMLData.PhoneNumber,
							XMLData.Description,
							XMLData.Attribute,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.PartName,
							XMLData.IsUsed,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCodeEmp NVARCHAR(50),
										CodeEmp NVARCHAR(50),
										Name NVARCHAR(200),
										Department NVARCHAR(200),
										Sex NVARCHAR(20),
										Birthday NVARCHAR(20),
										Address NVARCHAR(20),
										PhoneNumber NVARCHAR(20),
										Description NVARCHAR(20),
										Attribute NVARCHAR(200),
										Attribute1 NVARCHAR(200),
										Attribute2 NVARCHAR(200),
										Attribute3 NVARCHAR(200),
										Attribute4 NVARCHAR(200),
										Attribute5 NVARCHAR(200),
										PartName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CodeEmp = SourceTable.CodeEmp
				)

			WHEN MATCHED THEN
				UPDATE SET
					CodeEmp = SourceTable.CodeEmp,
					Name = SourceTable.Name,
					Department = SourceTable.Department,
					Sex = SourceTable.Sex,
					Birthday = SourceTable.Birthday,
					Address = SourceTable.Address,
					PhoneNumber = SourceTable.PhoneNumber,
					Description = SourceTable.Description,
					Attribute = SourceTable.Attribute,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					PartName = SourceTable.PartName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CodeEmp,
						Name,
						Department,
						Sex,
						Birthday,
						Address,
						PhoneNumber,
						Description,
						Attribute,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						PartName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CodeEmp,
							SourceTable.Name,
							SourceTable.Department,
							SourceTable.Sex,
							SourceTable.Birthday,
							SourceTable.Address,
							SourceTable.PhoneNumber,
							SourceTable.Description,
							SourceTable.Attribute,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.PartName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE Stb_EmployeeDepartment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCodeEmp IS NULL THEN XMLData.CodeEmp
							    ELSE XMLData.OldCodeEmp
							END AS OldCodeEmp,
							XMLData.CodeEmp,
							XMLData.Name,
							XMLData.Department,
							XMLData.Sex,
							XMLData.Birthday,
							XMLData.Address,
							XMLData.PhoneNumber,
							XMLData.Description,
							XMLData.Attribute,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.PartName,
							XMLData.IsUsed,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCodeEmp NVARCHAR(50),
										CodeEmp NVARCHAR(50),
										Name NVARCHAR(200),
										Department NVARCHAR(200),
										Sex NVARCHAR(200),
										Birthday NVARCHAR(200),
										Address NVARCHAR(200),
										PhoneNumber NVARCHAR(200),
										Description NVARCHAR(200),
										Attribute NVARCHAR(200),
										Attribute1 NVARCHAR(200),
										Attribute2 NVARCHAR(200),
										Attribute3 NVARCHAR(200),
										Attribute4 NVARCHAR(200),
										Attribute5 NVARCHAR(200),
										PartName NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CodeEmp = SourceTable.OldCodeEmp
				)

			WHEN MATCHED THEN
				UPDATE SET
					CodeEmp = SourceTable.CodeEmp,
					Name = SourceTable.Name,
					Department = SourceTable.Department,
					Sex = SourceTable.Sex,
					Birthday = SourceTable.Birthday,
					Address = SourceTable.Address,
					PhoneNumber = SourceTable.PhoneNumber,
					Attribute = SourceTable.Attribute,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					PartName = SourceTable.PartName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CodeEmp,
						Name,
						Department,
						Sex,
						Birthday,
						Address,
						PhoneNumber,
						Description,
						Attribute,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						PartName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CodeEmp,
							SourceTable.Name,
							SourceTable.Department,
							SourceTable.Sex,
							SourceTable.Birthday,
							SourceTable.Address,
							SourceTable.PhoneNumber,
							SourceTable.Description,
							SourceTable.Attribute,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.PartName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE Stb_EmployeeDepartment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCodeEmp IS NULL THEN XMLData.OldCodeEmp
							    ELSE XMLData.OldCodeEmp
							END AS OldCodeEmp,
							XMLData.CodeEmp,
							XMLData.Name,
							XMLData.Department,
							XMLData.Sex,
							XMLData.Birthday,
							XMLData.Address,
							XMLData.PhoneNumber,
							XMLData.Description,
							XMLData.Attribute,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.PartName,
							XMLData.IsUsed,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCodeEmp NVARCHAR(50),
										CodeEmp NVARCHAR(50),
										Name NVARCHAR(200),
										Department NVARCHAR(200),
										Sex NVARCHAR(200),
										Birthday NVARCHAR(200),
										Address NVARCHAR(200),
										PhoneNumber NVARCHAR(200),
										Description NVARCHAR(200),
										Attribute NVARCHAR(200),
										Attribute1 NVARCHAR(200),
										Attribute2 NVARCHAR(200),
										Attribute3 NVARCHAR(200),
										Attribute4 NVARCHAR(200),
										Attribute5 NVARCHAR(200),
										PartName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CodeEmp = SourceTable.CodeEmp
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
									XMLData.OldCodeEmp,
									XMLData.CodeEmp,
									XMLData.Name,
									XMLData.Department,
									XMLData.Sex,
									XMLData.Birthday,
									XMLData.Address,
									XMLData.PhoneNumber,
									XMLData.Description,
									XMLData.Attribute,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.PartName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldCodeEmp NVARCHAR(50),
											CodeEmp NVARCHAR(50),
											Name NVARCHAR(200),
											Department NVARCHAR(200),
											Sex NVARCHAR(200),
											Birthday NVARCHAR(200),
											Address NVARCHAR(200),
											PhoneNumber NVARCHAR(200),
											Description NVARCHAR(200),
											Attribute NVARCHAR(200),
											Attribute1 NVARCHAR(200),
											Attribute2 NVARCHAR(200),
											Attribute3 NVARCHAR(200),
											Attribute4 NVARCHAR(200),
											Attribute5 NVARCHAR(200),
											PartName NVARCHAR(100),
											IsUsed BIT,
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCodeEmp IS NULL THEN XMLData.CodeEmp
										ELSE XMLData.OldCodeEmp
									END AS OldTCodeEmp,
									XMLData.CodeEmp,
									XMLData.Name,
									XMLData.Department,
									XMLData.Sex,
									XMLData.Birthday,
									XMLData.Address,
									XMLData.PhoneNumber,
									XMLData.Description,
									XMLData.Attribute,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.PartName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCodeEmp NVARCHAR(50),
											CodeEmp NVARCHAR(50),
											Name NVARCHAR(200),
											Department NVARCHAR(200),
											Sex NVARCHAR(200),
											Birthday NVARCHAR(200),
											Address NVARCHAR(200),
											PhoneNumber NVARCHAR(200),
											 Description NVARCHAR(100),
											 Attribute NVARCHAR(200),
											 Attribute1 NVARCHAR(200),
											 Attribute2 NVARCHAR(200),
											 Attribute3 NVARCHAR(200),
											 Attribute4 NVARCHAR(200),
											 Attribute5 NVARCHAR(200),
											 PartName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCodeEmp IS NULL THEN XMLData.CodeEmp
										ELSE XMLData.OldCodeEmp
									END AS OldCodeEmp,
									XMLData.CodeEmp,
									XMLData.Name,
									XMLData.Department,
									XMLData.Sex,
									XMLData.Birthday,
									XMLData.Address,
									XMLData.PhoneNumber,
									XMLData.Description,
									XMLData.Attribute,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.PartName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCodeEmp NVARCHAR(50),
											 CodeEmp NVARCHAR(50),
											 Name NVARCHAR(200),
											 Department NVARCHAR(200),
											 Sex NVARCHAR(200),
											 Birthday NVARCHAR(200),
											 Address NVARCHAR(200),
											 PhoneNumber NVARCHAR(200),
											 Description NVARCHAR(100),
											 Attribute NVARCHAR(200),
											 Attribute1 NVARCHAR(200),
											 Attribute2 NVARCHAR(200),
											 Attribute3 NVARCHAR(200),
											 Attribute4 NVARCHAR(200),
											 Attribute5 NVARCHAR(200),
											 PartName NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCodeEmp,
								 @CodeEmp,
								 @Name,
								 @Department,
								 @Sex,
								 @Birthday,
								 @Address,
								 @PhoneNumber,
								 @Description,
								 @Attribute,
								 @Attribute1,
								 @Attribute2,
								 @Attribute3,
								 @Attribute4,
								 @Attribute5,
								 @PartName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM Stb_EmployeeDepartment WHERE CodeEmp = @CodeEmp) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CodeEmp)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'Stb_EmployeeDepartment', @CodeEmp OUTPUT
                    END

                    INSERT INTO Stb_EmployeeDepartment
						(
						    CodeEmp,
						    Name,
							Department,
							Sex,
							Birthday,
							Address,
							PhoneNumber,
						    Description,
						    Attribute,
						    Attribute1,
							Attribute2,
							Attribute3,
							Attribute4,
							Attribute5,
							PartName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CodeEmp,
						    @Name,
							@Department,
							@Sex,
							@Birthday,
							@Address,
							@PhoneNumber,
						    @Description,
						    @Attribute,
						    @Attribute1,
							@Attribute2,
							@Attribute3,
							@Attribute4,
							@Attribute5,
							@PartName,
						    @IsUsed,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE Stb_EmployeeDepartment
						SET
						    CodeEmp =   CASE
						                WHEN @CodeEmp IS NOT NULL THEN @CodeEmp
						                ELSE CodeEmp
						            END,
						    Name =   CASE
						                WHEN @Name IS NOT NULL THEN @Name
						                ELSE Name
						            END,
							 Department =   CASE
						                WHEN @Department IS NOT NULL THEN @Department
						                ELSE Department
						            END,
							 Sex =   CASE
						                WHEN @Sex IS NOT NULL THEN @Sex
						                ELSE Sex
						            END,
							 Birthday =   CASE
						                WHEN @Birthday IS NOT NULL THEN @Birthday
						                ELSE Birthday
						            END,
							 PhoneNumber =   CASE
						                WHEN @PhoneNumber IS NOT NULL THEN @PhoneNumber
						                ELSE PhoneNumber
						            END,
						    Description =   CASE
						                WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
						            END,
						    Attribute =   CASE
						                WHEN @Attribute IS NOT NULL THEN @Attribute
						                ELSE Attribute
						            END,
						    Attribute1 =   CASE
						                WHEN @Attribute1 IS NOT NULL THEN @Attribute1
						                ELSE Attribute1
						            END,
							Attribute2 =   CASE
						                WHEN @Attribute2 IS NOT NULL THEN @Attribute2
						                ELSE Attribute2
						            END,
							Attribute3 =   CASE
						                WHEN @Attribute3 IS NOT NULL THEN @Attribute3
						                ELSE Attribute3
						            END,
						  Attribute4 =   CASE
						                WHEN @Attribute4 IS NOT NULL THEN @Attribute4
						                ELSE Attribute4
						            END,
						   Attribute5 =   CASE
						                WHEN @Attribute5 IS NOT NULL THEN @Attribute5
						                ELSE Attribute5
						            END,
							PartName =   CASE
						                WHEN @PartName IS NOT NULL THEN @PartName
						                ELSE PartName
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CodeEmp = @OldCodeEmp
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM Stb_EmployeeDepartment
						WHERE
						    CodeEmp = @CodeEmp
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

