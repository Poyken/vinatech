
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-08-05
-- Browsable : true
-- Group : 제품관리 > 
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_RCV_ASN_SingleShipment_iud]
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
  DECLARE @OldRCV_ORD_NO VARCHAR(20)
  DECLARE @OldPACK_ID VARCHAR(20)
  DECLARE @RCV_ORD_NO VARCHAR(20)
  DECLARE @PACK_ID VARCHAR(20)
  DECLARE @RCV_TYPE VARCHAR(1)
  DECLARE @ITM_CD VARCHAR(20)
  DECLARE @ITM_NM VARCHAR(100)
  DECLARE @ITM_QTY NUMERIC(6,0)
  DECLARE @STATUS VARCHAR(2)
  DECLARE @CRT_DT DATETIME


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'RCV_ASN',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE RCV_ASN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRCV_ORD_NO IS NULL THEN RCV_ORD_NO
							    ELSE OldRCV_ORD_NO
							END AS OldRCV_ORD_NO,
							CASE
							    WHEN OldPACK_ID IS NULL THEN PACK_ID
							    ELSE OldPACK_ID
							END AS OldPACK_ID,
							RCV_ORD_NO,
							PACK_ID,
							RCV_TYPE,
							ITM_CD,
							ITM_NM,
							ITM_QTY,
							STATUS,
							CRT_DT
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRCV_ORD_NO VARCHAR(20),
										OldPACK_ID VARCHAR(20),
										RCV_ORD_NO VARCHAR(20),
										PACK_ID VARCHAR(20),
										RCV_TYPE VARCHAR(1),
										ITM_CD VARCHAR(20),
										ITM_NM VARCHAR(100),
										ITM_QTY NUMERIC(6,0),
										STATUS VARCHAR(2),
										CRT_DT DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RCV_ORD_NO = SourceTable.RCV_ORD_NO AND
					TargetTable.PACK_ID = SourceTable.PACK_ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					RCV_ORD_NO = ISNULL(SourceTable.RCV_ORD_NO,TargetTable.RCV_ORD_NO),
					PACK_ID = ISNULL(SourceTable.PACK_ID,TargetTable.PACK_ID),
					RCV_TYPE = ISNULL(SourceTable.RCV_TYPE,TargetTable.RCV_TYPE),
					ITM_CD = ISNULL(SourceTable.ITM_CD,TargetTable.ITM_CD),
					ITM_NM = ISNULL(SourceTable.ITM_NM,TargetTable.ITM_NM),
					ITM_QTY = ISNULL(SourceTable.ITM_QTY,TargetTable.ITM_QTY),
					STATUS = ISNULL(SourceTable.STATUS,TargetTable.STATUS),
					CRT_DT = ISNULL(SourceTable.CRT_DT,TargetTable.CRT_DT)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RCV_ORD_NO,
						PACK_ID,
						RCV_TYPE,
						ITM_CD,
						ITM_NM,
						ITM_QTY,
						STATUS,
						CRT_DT
					)
				VALUES
					(
							SourceTable.RCV_ORD_NO,
							SourceTable.PACK_ID,
							SourceTable.RCV_TYPE,
							SourceTable.ITM_CD,
							SourceTable.ITM_NM,
							SourceTable.ITM_QTY,
							SourceTable.STATUS,
							SourceTable.CRT_DT
					);


			-- Process Update Table
            MERGE RCV_ASN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRCV_ORD_NO IS NULL THEN RCV_ORD_NO
							    ELSE OldRCV_ORD_NO
							END AS OldRCV_ORD_NO,
							CASE
							    WHEN OldPACK_ID IS NULL THEN PACK_ID
							    ELSE OldPACK_ID
							END AS OldPACK_ID,
							RCV_ORD_NO,
							PACK_ID,
							RCV_TYPE,
							ITM_CD,
							ITM_NM,
							ITM_QTY,
							STATUS,
							CRT_DT
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRCV_ORD_NO VARCHAR(20),
										OldPACK_ID VARCHAR(20),
										RCV_ORD_NO VARCHAR(20),
										PACK_ID VARCHAR(20),
										RCV_TYPE VARCHAR(1),
										ITM_CD VARCHAR(20),
										ITM_NM VARCHAR(100),
										ITM_QTY NUMERIC(6,0),
										STATUS VARCHAR(2),
										CRT_DT DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RCV_ORD_NO = SourceTable.OldRCV_ORD_NO AND
					TargetTable.PACK_ID = SourceTable.OldPACK_ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					RCV_ORD_NO = ISNULL(SourceTable.RCV_ORD_NO,TargetTable.RCV_ORD_NO),
					PACK_ID = ISNULL(SourceTable.PACK_ID,TargetTable.PACK_ID),
					RCV_TYPE = ISNULL(SourceTable.RCV_TYPE,TargetTable.RCV_TYPE),
					ITM_CD = ISNULL(SourceTable.ITM_CD,TargetTable.ITM_CD),
					ITM_NM = ISNULL(SourceTable.ITM_NM,TargetTable.ITM_NM),
					ITM_QTY = ISNULL(SourceTable.ITM_QTY,TargetTable.ITM_QTY),
					STATUS = ISNULL(SourceTable.STATUS,TargetTable.STATUS),
					CRT_DT = ISNULL(SourceTable.CRT_DT,TargetTable.CRT_DT)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RCV_ORD_NO,
						PACK_ID,
						RCV_TYPE,
						ITM_CD,
						ITM_NM,
						ITM_QTY,
						STATUS,
						CRT_DT
					)
				VALUES
					(
							SourceTable.RCV_ORD_NO,
							SourceTable.PACK_ID,
							SourceTable.RCV_TYPE,
							SourceTable.ITM_CD,
							SourceTable.ITM_NM,
							SourceTable.ITM_QTY,
							SourceTable.STATUS,
							SourceTable.CRT_DT
					);


			-- Process Delete Table
            MERGE RCV_ASN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRCV_ORD_NO IS NULL THEN RCV_ORD_NO
							    ELSE OldRCV_ORD_NO
							END AS OldRCV_ORD_NO,
							CASE
							    WHEN OldPACK_ID IS NULL THEN PACK_ID
							    ELSE OldPACK_ID
							END AS OldPACK_ID,
							RCV_ORD_NO,
							PACK_ID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRCV_ORD_NO VARCHAR(20),
										OldPACK_ID VARCHAR(20),
										RCV_ORD_NO VARCHAR(20),
										PACK_ID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RCV_ORD_NO = SourceTable.RCV_ORD_NO AND
					TargetTable.PACK_ID = SourceTable.PACK_ID
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
									OldRCV_ORD_NO,
									OldPACK_ID,
									RCV_ORD_NO,
									PACK_ID,
									RCV_TYPE,
									ITM_CD,
									ITM_NM,
									ITM_QTY,
									STATUS,
									CRT_DT
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRCV_ORD_NO VARCHAR(20),
											 OldPACK_ID VARCHAR(20),
											 RCV_ORD_NO VARCHAR(20),
											 PACK_ID VARCHAR(20),
											 RCV_TYPE VARCHAR(1),
											 ITM_CD VARCHAR(20),
											 ITM_NM VARCHAR(100),
											 ITM_QTY NUMERIC(6,0),
											 STATUS VARCHAR(2),
											 CRT_DT DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRCV_ORD_NO IS NULL THEN RCV_ORD_NO
										ELSE OldRCV_ORD_NO
									END AS OldRCV_ORD_NO,
									CASE 
										WHEN OldPACK_ID IS NULL THEN PACK_ID
										ELSE OldPACK_ID
									END AS OldPACK_ID,
									RCV_ORD_NO,
									PACK_ID,
									RCV_TYPE,
									ITM_CD,
									ITM_NM,
									ITM_QTY,
									STATUS,
									CRT_DT
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRCV_ORD_NO VARCHAR(20),
											 OldPACK_ID VARCHAR(20),
											 RCV_ORD_NO VARCHAR(20),
											 PACK_ID VARCHAR(20),
											 RCV_TYPE VARCHAR(1),
											 ITM_CD VARCHAR(20),
											 ITM_NM VARCHAR(100),
											 ITM_QTY NUMERIC(6,0),
											 STATUS VARCHAR(2),
											 CRT_DT DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRCV_ORD_NO IS NULL THEN RCV_ORD_NO
										ELSE OldRCV_ORD_NO
									END AS OldRCV_ORD_NO,
									CASE 
										WHEN OldPACK_ID IS NULL THEN PACK_ID
										ELSE OldPACK_ID
									END AS OldPACK_ID,
									RCV_ORD_NO,
									PACK_ID,
									RCV_TYPE,
									ITM_CD,
									ITM_NM,
									ITM_QTY,
									STATUS,
									CRT_DT
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRCV_ORD_NO VARCHAR(20),
											 OldPACK_ID VARCHAR(20),
											 RCV_ORD_NO VARCHAR(20),
											 PACK_ID VARCHAR(20),
											 RCV_TYPE VARCHAR(1),
											 ITM_CD VARCHAR(20),
											 ITM_NM VARCHAR(100),
											 ITM_QTY NUMERIC(6,0),
											 STATUS VARCHAR(2),
											 CRT_DT DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRCV_ORD_NO,
								 @OldPACK_ID,
								 @RCV_ORD_NO,
								 @PACK_ID,
								 @RCV_TYPE,
								 @ITM_CD,
								 @ITM_NM,
								 @ITM_QTY,
								 @STATUS,
								 @CRT_DT


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM RCV_ASN WHERE RCV_ORD_NO = @RCV_ORD_NO AND PACK_ID = @PACK_ID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RCV_ORD_NO)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'RCV_ASN',@RCV_ORD_NO OUTPUT
                    END

                    INSERT INTO RCV_ASN
						(
						    RCV_ORD_NO,
						    PACK_ID,
						    RCV_TYPE,
						    ITM_CD,
						    ITM_NM,
						    ITM_QTY,
						    STATUS,
						    CRT_DT
						)
						VALUES
						(
						    @RCV_ORD_NO,
						    @PACK_ID,
						    @RCV_TYPE,
						    @ITM_CD,
						    REPLACE(@ITM_NM, ',', '_'),
						    @ITM_QTY,
						    @STATUS,
						    @CRT_DT
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE RCV_ASN
						SET
						    RCV_ORD_NO =   ISNULL(@RCV_ORD_NO,RCV_ORD_NO),
						    PACK_ID =   ISNULL(@PACK_ID,PACK_ID),
						    RCV_TYPE =   ISNULL(@RCV_TYPE,RCV_TYPE),
						    ITM_CD =   ISNULL(@ITM_CD,ITM_CD),
						    ITM_NM =   REPLACE(ISNULL(@ITM_NM,ITM_NM), ',', '_'),
						    ITM_QTY =   ISNULL(@ITM_QTY,ITM_QTY),
						    STATUS =   ISNULL(@STATUS,STATUS),
						    CRT_DT =   ISNULL(@CRT_DT,CRT_DT)
						WHERE
						    RCV_ORD_NO = @OldRCV_ORD_NO AND
						    PACK_ID = @OldPACK_ID
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM RCV_ASN
						WHERE
						    RCV_ORD_NO = @OldRCV_ORD_NO AND
						    PACK_ID = @OldPACK_ID
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
