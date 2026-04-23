
-- =============================================
-- Author:	    Jackaroe
-- Create date: 2018-12-17
-- Browsable : true
-- Group : 인사
-- Description:	자격증 정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LicenseInfo_iud]
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
  DECLARE @OldLIC_NO VARCHAR(30)
  DECLARE @LIC_NO VARCHAR(30)
  DECLARE @EMPID VARCHAR(30)
  DECLARE @LCODE VARCHAR(10)
  DECLARE @DCODE VARCHAR(10)
  DECLARE @LIC_NM VARCHAR(100)
  DECLARE @LIC_START_DATE DATE
  DECLARE @LIC_END_DATE DATE
  DECLARE @REMARK VARCHAR(1000)
  DECLARE @REG_DATE DATE
  DECLARE @REG_YMS DATETIME
  DECLARE @UDT_DATE DATE
  DECLARE @UDT_YMS DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_LICENSE_INFO',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_LICENSE_INFO AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLIC_NO IS NULL THEN LIC_NO
							    ELSE OldLIC_NO
							END AS OldLIC_NO,
							LIC_NO,
							EMPID,
							LCODE,
							DCODE,
							LIC_NM,
							LIC_START_DATE,
							LIC_END_DATE,
							REMARK,
							REG_DATE,
							REG_YMS,
							UDT_DATE,
							UDT_YMS
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLIC_NO VARCHAR(30),
										LIC_NO VARCHAR(30),
										EMPID VARCHAR(30),
										LCODE VARCHAR(10),
										DCODE VARCHAR(10),
										LIC_NM VARCHAR(100),
										LIC_START_DATE DATETIMEOFFSET,
										LIC_END_DATE DATETIMEOFFSET,
										REMARK VARCHAR(1000),
										REG_DATE DATETIMEOFFSET,
										REG_YMS DATETIMEOFFSET,
										UDT_DATE DATETIMEOFFSET,
										UDT_YMS DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LIC_NO = SourceTable.LIC_NO
				)

			WHEN MATCHED THEN
				UPDATE SET
					LIC_NO = ISNULL(SourceTable.LIC_NO,TargetTable.LIC_NO),
					EMPID = ISNULL(SourceTable.EMPID,TargetTable.EMPID),
					LCODE = ISNULL(SourceTable.LCODE,TargetTable.LCODE),
					DCODE = ISNULL(SourceTable.DCODE,TargetTable.DCODE),
					LIC_NM = ISNULL(SourceTable.LIC_NM,TargetTable.LIC_NM),
					LIC_START_DATE = ISNULL(SourceTable.LIC_START_DATE,TargetTable.LIC_START_DATE),
					LIC_END_DATE = ISNULL(SourceTable.LIC_END_DATE,TargetTable.LIC_END_DATE),
					REMARK = ISNULL(SourceTable.REMARK,TargetTable.REMARK),
					UDT_DATE = GETDATE(),
					UDT_YMS = GETDATE()
			WHEN NOT MATCHED THEN
				INSERT
					(
						LIC_NO,
						EMPID,
						LCODE,
						DCODE,
						LIC_NM,
						LIC_START_DATE,
						LIC_END_DATE,
						REMARK,
						REG_DATE,
						REG_YMS,
						UDT_DATE,
						UDT_YMS
					)
				VALUES
					(
							SourceTable.LIC_NO,
							SourceTable.EMPID,
							SourceTable.LCODE,
							SourceTable.DCODE,
							SourceTable.LIC_NM,
							SourceTable.LIC_START_DATE,
							SourceTable.LIC_END_DATE,
							SourceTable.REMARK,
							GETDATE(),
							GETDATE(),
							GETDATE(),
							GETDATE()
					);


			-- Process Update Table
            MERGE STB_LICENSE_INFO AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLIC_NO IS NULL THEN LIC_NO
							    ELSE OldLIC_NO
							END AS OldLIC_NO,
							LIC_NO,
							EMPID,
							LCODE,
							DCODE,
							LIC_NM,
							LIC_START_DATE,
							LIC_END_DATE,
							REMARK,
							REG_DATE,
							REG_YMS,
							UDT_DATE,
							UDT_YMS
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLIC_NO VARCHAR(30),
										LIC_NO VARCHAR(30),
										EMPID VARCHAR(30),
										LCODE VARCHAR(10),
										DCODE VARCHAR(10),
										LIC_NM VARCHAR(100),
										LIC_START_DATE DATETIMEOFFSET,
										LIC_END_DATE DATETIMEOFFSET,
										REMARK VARCHAR(1000),
										REG_DATE DATETIMEOFFSET,
										REG_YMS DATETIMEOFFSET,
										UDT_DATE DATETIMEOFFSET,
										UDT_YMS DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LIC_NO = SourceTable.OldLIC_NO
				)

			WHEN MATCHED THEN
				UPDATE SET
					LIC_NO = ISNULL(SourceTable.LIC_NO,TargetTable.LIC_NO),
					EMPID = ISNULL(SourceTable.EMPID,TargetTable.EMPID),
					LCODE = ISNULL(SourceTable.LCODE,TargetTable.LCODE),
					DCODE = ISNULL(SourceTable.DCODE,TargetTable.DCODE),
					LIC_NM = ISNULL(SourceTable.LIC_NM,TargetTable.LIC_NM),
					LIC_START_DATE = ISNULL(SourceTable.LIC_START_DATE,TargetTable.LIC_START_DATE),
					LIC_END_DATE = ISNULL(SourceTable.LIC_END_DATE,TargetTable.LIC_END_DATE),
					REMARK = ISNULL(SourceTable.REMARK,TargetTable.REMARK),
					UDT_DATE = GETDATE(),
					UDT_YMS = GETDATE()
			WHEN NOT MATCHED THEN
				INSERT
					(
						LIC_NO,
						EMPID,
						LCODE,
						DCODE,
						LIC_NM,
						LIC_START_DATE,
						LIC_END_DATE,
						REMARK,
						REG_DATE,
						REG_YMS,
						UDT_DATE,
						UDT_YMS
					)
				VALUES
					(
							SourceTable.LIC_NO,
							SourceTable.EMPID,
							SourceTable.LCODE,
							SourceTable.DCODE,
							SourceTable.LIC_NM,
							SourceTable.LIC_START_DATE,
							SourceTable.LIC_END_DATE,
							SourceTable.REMARK,
							GETDATE(),
							GETDATE(),
							GETDATE(),
							GETDATE()
					);


			-- Process Delete Table
            MERGE STB_LICENSE_INFO AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLIC_NO IS NULL THEN LIC_NO
							    ELSE OldLIC_NO
							END AS OldLIC_NO,
							LIC_NO,
							EMPID,
							LCODE,
							DCODE,
							LIC_NM,
							LIC_START_DATE,
							LIC_END_DATE,
							REMARK,
							REG_DATE,
							REG_YMS,
							UDT_DATE,
							UDT_YMS
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLIC_NO VARCHAR(30),
										LIC_NO VARCHAR(30),
										EMPID VARCHAR(30),
										LCODE VARCHAR(10),
										DCODE VARCHAR(10),
										LIC_NM VARCHAR(100),
										LIC_START_DATE DATETIMEOFFSET,
										LIC_END_DATE DATETIMEOFFSET,
										REMARK VARCHAR(1000),
										REG_DATE DATETIMEOFFSET,
										REG_YMS DATETIMEOFFSET,
										UDT_DATE DATETIMEOFFSET,
										UDT_YMS DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LIC_NO = SourceTable.LIC_NO
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
									OldLIC_NO,
									LIC_NO,
									EMPID,
									LCODE,
									DCODE,
									LIC_NM,
									LIC_START_DATE,
									LIC_END_DATE,
									REMARK,
									REG_DATE,
									REG_YMS,
									UDT_DATE,
									UDT_YMS
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLIC_NO VARCHAR(30),
											 LIC_NO VARCHAR(30),
											 EMPID VARCHAR(30),
											 LCODE VARCHAR(10),
											 DCODE VARCHAR(10),
											 LIC_NM VARCHAR(100),
											 LIC_START_DATE DATETIMEOFFSET,
											 LIC_END_DATE DATETIMEOFFSET,
											 REMARK VARCHAR(1000),
											 REG_DATE DATETIMEOFFSET,
											 REG_YMS DATETIMEOFFSET,
											 UDT_DATE DATETIMEOFFSET,
											 UDT_YMS DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLIC_NO IS NULL THEN LIC_NO
										ELSE OldLIC_NO
									END AS OldLIC_NO,
									LIC_NO,
									EMPID,
									LCODE,
									DCODE,
									LIC_NM,
									LIC_START_DATE,
									LIC_END_DATE,
									REMARK,
									REG_DATE,
									REG_YMS,
									UDT_DATE,
									UDT_YMS
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLIC_NO VARCHAR(30),
											 LIC_NO VARCHAR(30),
											 EMPID VARCHAR(30),
											 LCODE VARCHAR(10),
											 DCODE VARCHAR(10),
											 LIC_NM VARCHAR(100),
											 LIC_START_DATE DATETIMEOFFSET,
											 LIC_END_DATE DATETIMEOFFSET,
											 REMARK VARCHAR(1000),
											 REG_DATE DATETIMEOFFSET,
											 REG_YMS DATETIMEOFFSET,
											 UDT_DATE DATETIMEOFFSET,
											 UDT_YMS DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLIC_NO IS NULL THEN LIC_NO
										ELSE OldLIC_NO
									END AS OldLIC_NO,
									LIC_NO,
									EMPID,
									LCODE,
									DCODE,
									LIC_NM,
									LIC_START_DATE,
									LIC_END_DATE,
									REMARK,
									REG_DATE,
									REG_YMS,
									UDT_DATE,
									UDT_YMS
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLIC_NO VARCHAR(30),
											 LIC_NO VARCHAR(30),
											 EMPID VARCHAR(30),
											 LCODE VARCHAR(10),
											 DCODE VARCHAR(10),
											 LIC_NM VARCHAR(100),
											 LIC_START_DATE DATETIMEOFFSET,
											 LIC_END_DATE DATETIMEOFFSET,
											 REMARK VARCHAR(1000),
											 REG_DATE DATETIMEOFFSET,
											 REG_YMS DATETIMEOFFSET,
											 UDT_DATE DATETIMEOFFSET,
											 UDT_YMS DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLIC_NO,
								 @LIC_NO,
								 @EMPID,
								 @LCODE,
								 @DCODE,
								 @LIC_NM,
								 @LIC_START_DATE,
								 @LIC_END_DATE,
								 @REMARK,
								 @REG_DATE,
								 @REG_YMS,
								 @UDT_DATE,
								 @UDT_YMS


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LICENSE_INFO WHERE LIC_NO = @LIC_NO) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LIC_NO)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_LICENSE_INFO',@LIC_NO OUTPUT
                    END

                    INSERT INTO STB_LICENSE_INFO
						(
						    LIC_NO,
						    EMPID,
						    LCODE,
						    DCODE,
						    LIC_NM,
						    LIC_START_DATE,
						    LIC_END_DATE,
						    REMARK,
						    REG_DATE,
						    REG_YMS,
						    UDT_DATE,
						    UDT_YMS
						)
						VALUES
						(
						    @LIC_NO,
						    @EMPID,
						    @LCODE,
						    @DCODE,
						    @LIC_NM,
						    @LIC_START_DATE,
						    @LIC_END_DATE,
						    @REMARK,
						    GETDATE(),
						    GETDATE(),
						    GETDATE(),
						    GETDATE()
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LICENSE_INFO
						SET
						    LIC_NO =   ISNULL(@LIC_NO,LIC_NO),
						    EMPID =   ISNULL(@EMPID,EMPID),
						    LCODE =   ISNULL(@LCODE,LCODE),
						    DCODE =   ISNULL(@DCODE,DCODE),
						    LIC_NM =   ISNULL(@LIC_NM,LIC_NM),
						    LIC_START_DATE =   ISNULL(@LIC_START_DATE,LIC_START_DATE),
						    LIC_END_DATE =   ISNULL(@LIC_END_DATE,LIC_END_DATE),
						    REMARK =   ISNULL(@REMARK,REMARK),
						    UDT_DATE =   GETDATE(),
						    UDT_YMS =   GETDATE()
						WHERE
						    LIC_NO = @OldLIC_NO
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LICENSE_INFO
						WHERE
						    LIC_NO = @OldLIC_NO
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
