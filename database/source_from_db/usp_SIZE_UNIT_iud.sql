
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-10-31
-- Browsable : true
-- Group : 생산계획 
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SIZE_UNIT_iud]
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
  DECLARE @OldSIZE VARCHAR(20)
  DECLARE @OldFARAD FLOAT
  DECLARE @OldWIDTH FLOAT(38)
  DECLARE @OldKIND VARCHAR(20)
  DECLARE @SIZE VARCHAR(20)
  DECLARE @FARAD FLOAT(38)
  DECLARE @WIDTH FLOAT(38)
  DECLARE @KIND VARCHAR(20)
  DECLARE @PLUS INT
  DECLARE @MINUS INT
  DECLARE @비고 VARCHAR(200)
  DECLARE @VNT_PLAN_QTY INT
  DECLARE @VVT_PLAN_QTY INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'SIZE_UNIT',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE SIZE_UNIT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSIZE IS NULL THEN SIZE
							    ELSE OldSIZE
							END AS OldSIZE,
							CASE
							    WHEN OldFARAD IS NULL THEN FARAD
							    ELSE OldFARAD
							END AS OldFARAD,
							CASE
							    WHEN OldWIDTH IS NULL THEN WIDTH
							    ELSE OldWIDTH
							END AS OldWIDTH,
							CASE
							    WHEN OldKIND IS NULL THEN KIND
							    ELSE OldKIND
							END AS OldKIND,
							SIZE,
							FARAD,
							WIDTH,
							KIND,
							PLUS,
							MINUS,
							비고,
							VNT_PLAN_QTY,
							VVT_PLAN_QTY
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSIZE VARCHAR(20),
										OldFARAD FLOAT(38),
										OldWIDTH FLOAT(38),
										OldKIND VARCHAR(20),
										SIZE VARCHAR(20),
										FARAD FLOAT(38),
										WIDTH FLOAT(38),
										KIND VARCHAR(20),
										PLUS INT,
										MINUS INT,
										비고 VARCHAR(200),
										VNT_PLAN_QTY INT,
										VVT_PLAN_QTY INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SIZE = SourceTable.SIZE AND
					TargetTable.FARAD = SourceTable.FARAD AND
					TargetTable.WIDTH = SourceTable.WIDTH AND
					TargetTable.KIND = SourceTable.KIND
				)

			WHEN MATCHED THEN
				UPDATE SET
					SIZE = ISNULL(SourceTable.SIZE,TargetTable.SIZE),
					FARAD = ISNULL(SourceTable.FARAD,TargetTable.FARAD),
					WIDTH = ISNULL(SourceTable.WIDTH,TargetTable.WIDTH),
					KIND = ISNULL(SourceTable.KIND,TargetTable.KIND),
					PLUS = ISNULL(SourceTable.PLUS,TargetTable.PLUS),
					MINUS = ISNULL(SourceTable.MINUS,TargetTable.MINUS),
					VNT_PLAN_QTY = ISNULL(SourceTable.VNT_PLAN_QTY,TargetTable.VNT_PLAN_QTY),
					VVT_PLAN_QTY = ISNULL(SourceTable.VVT_PLAN_QTY,TargetTable.VVT_PLAN_QTY)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SIZE,
						FARAD,
						WIDTH,
						KIND,
						PLUS,
						MINUS,
						VNT_PLAN_QTY,
						VVT_PLAN_QTY
					)
				VALUES
					(
							SourceTable.SIZE,
							SourceTable.FARAD,
							SourceTable.WIDTH,
							SourceTable.KIND,
							SourceTable.PLUS,
							SourceTable.MINUS,
							SourceTable.VNT_PLAN_QTY,
							SourceTable.VVT_PLAN_QTY
					);


			-- Process Update Table
            MERGE SIZE_UNIT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSIZE IS NULL THEN SIZE
							    ELSE OldSIZE
							END AS OldSIZE,
							CASE
							    WHEN OldFARAD IS NULL THEN FARAD
							    ELSE OldFARAD
							END AS OldFARAD,
							CASE
							    WHEN OldWIDTH IS NULL THEN WIDTH
							    ELSE OldWIDTH
							END AS OldWIDTH,
							CASE
							    WHEN OldKIND IS NULL THEN KIND
							    ELSE OldKIND
							END AS OldKIND,
							SIZE,
							FARAD,
							WIDTH,
							KIND,
							PLUS,
							MINUS,
							비고,
							VNT_PLAN_QTY,
							VVT_PLAN_QTY
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSIZE VARCHAR(20),
										OldFARAD FLOAT(38),
										OldWIDTH FLOAT(38),
										OldKIND VARCHAR(20),
										SIZE VARCHAR(20),
										FARAD FLOAT(38),
										WIDTH FLOAT(38),
										KIND VARCHAR(20),
										PLUS INT,
										MINUS INT,
										비고 VARCHAR(200),
										VNT_PLAN_QTY INT,
										VVT_PLAN_QTY INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SIZE = SourceTable.OldSIZE AND
					TargetTable.FARAD = SourceTable.OldFARAD AND
					TargetTable.WIDTH = SourceTable.OldWIDTH AND
					TargetTable.KIND = SourceTable.OldKIND
				)

			WHEN MATCHED THEN
				UPDATE SET
					SIZE = ISNULL(SourceTable.SIZE,TargetTable.SIZE),
					FARAD = ISNULL(SourceTable.FARAD,TargetTable.FARAD),
					WIDTH = ISNULL(SourceTable.WIDTH,TargetTable.WIDTH),
					KIND = ISNULL(SourceTable.KIND,TargetTable.KIND),
					PLUS = ISNULL(SourceTable.PLUS,TargetTable.PLUS),
					MINUS = ISNULL(SourceTable.MINUS,TargetTable.MINUS),
					VNT_PLAN_QTY = ISNULL(SourceTable.VNT_PLAN_QTY,TargetTable.VNT_PLAN_QTY),
					VVT_PLAN_QTY = ISNULL(SourceTable.VVT_PLAN_QTY,TargetTable.VVT_PLAN_QTY)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SIZE,
						FARAD,
						WIDTH,
						KIND,
						PLUS,
						MINUS,
						VNT_PLAN_QTY,
						VVT_PLAN_QTY
					)
				VALUES
					(
							SourceTable.SIZE,
							SourceTable.FARAD,
							SourceTable.WIDTH,
							SourceTable.KIND,
							SourceTable.PLUS,
							SourceTable.MINUS,
							SourceTable.VNT_PLAN_QTY,
							SourceTable.VVT_PLAN_QTY
					);


			-- Process Delete Table
            MERGE SIZE_UNIT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSIZE IS NULL THEN SIZE
							    ELSE OldSIZE
							END AS OldSIZE,
							CASE
							    WHEN OldFARAD IS NULL THEN FARAD
							    ELSE OldFARAD
							END AS OldFARAD,
							CASE
							    WHEN OldWIDTH IS NULL THEN WIDTH
							    ELSE OldWIDTH
							END AS OldWIDTH,
							CASE
							    WHEN OldKIND IS NULL THEN KIND
							    ELSE OldKIND
							END AS OldKIND,
							SIZE,
							FARAD,
							WIDTH,
							KIND,
							PLUS,
							MINUS,
							비고,
							VNT_PLAN_QTY,
							VVT_PLAN_QTY
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSIZE VARCHAR(20),
										OldFARAD FLOAT(38),
										OldWIDTH FLOAT(38),
										OldKIND VARCHAR(20),
										SIZE VARCHAR(20),
										FARAD FLOAT(38),
										WIDTH FLOAT(38),
										KIND VARCHAR(20),
										PLUS INT,
										MINUS INT,
										비고 VARCHAR(200),
										VNT_PLAN_QTY INT,
										VVT_PLAN_QTY INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SIZE = SourceTable.SIZE AND
					TargetTable.FARAD = SourceTable.FARAD AND
					TargetTable.WIDTH = SourceTable.WIDTH AND
					TargetTable.KIND = SourceTable.KIND
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
									OldSIZE,
									OldFARAD,
									OldWIDTH,
									OldKIND,
									SIZE,
									FARAD,
									WIDTH,
									KIND,
									PLUS,
									MINUS,
									비고,
									VNT_PLAN_QTY,
									VVT_PLAN_QTY
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSIZE VARCHAR(20),
											 OldFARAD FLOAT(38),
											 OldWIDTH FLOAT(38),
											 OldKIND VARCHAR(20),
											 SIZE VARCHAR(20),
											 FARAD FLOAT(38),
											 WIDTH FLOAT(38),
											 KIND VARCHAR(20),
											 PLUS INT,
											 MINUS INT,
											 비고 VARCHAR(200),
											 VNT_PLAN_QTY INT,
											 VVT_PLAN_QTY INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSIZE IS NULL THEN SIZE
										ELSE OldSIZE
									END AS OldSIZE,
									CASE 
										WHEN OldFARAD IS NULL THEN FARAD
										ELSE OldFARAD
									END AS OldFARAD,
									CASE 
										WHEN OldWIDTH IS NULL THEN WIDTH
										ELSE OldWIDTH
									END AS OldWIDTH,
									CASE 
										WHEN OldKIND IS NULL THEN KIND
										ELSE OldKIND
									END AS OldKIND,
									SIZE,
									FARAD,
									WIDTH,
									KIND,
									PLUS,
									MINUS,
									비고,
									VNT_PLAN_QTY,
									VVT_PLAN_QTY
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSIZE VARCHAR(20),
											 OldFARAD FLOAT(38),
											 OldWIDTH FLOAT(38),
											 OldKIND VARCHAR(20),
											 SIZE VARCHAR(20),
											 FARAD FLOAT(38),
											 WIDTH FLOAT(38),
											 KIND VARCHAR(20),
											 PLUS INT,
											 MINUS INT,
											 비고 VARCHAR(200),
											 VNT_PLAN_QTY INT,
											 VVT_PLAN_QTY INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSIZE IS NULL THEN SIZE
										ELSE OldSIZE
									END AS OldSIZE,
									CASE 
										WHEN OldFARAD IS NULL THEN FARAD
										ELSE OldFARAD
									END AS OldFARAD,
									CASE 
										WHEN OldWIDTH IS NULL THEN WIDTH
										ELSE OldWIDTH
									END AS OldWIDTH,
									CASE 
										WHEN OldKIND IS NULL THEN KIND
										ELSE OldKIND
									END AS OldKIND,
									SIZE,
									FARAD,
									WIDTH,
									KIND,
									PLUS,
									MINUS,
									비고,
									VNT_PLAN_QTY,
									VVT_PLAN_QTY
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSIZE VARCHAR(20),
											 OldFARAD FLOAT(38),
											 OldWIDTH FLOAT(38),
											 OldKIND VARCHAR(20),
											 SIZE VARCHAR(20),
											 FARAD FLOAT(38),
											 WIDTH FLOAT(38),
											 KIND VARCHAR(20),
											 PLUS INT,
											 MINUS INT,
											 비고 VARCHAR(200),
											 VNT_PLAN_QTY INT,
											 VVT_PLAN_QTY INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSIZE,
								 @OldFARAD,
								 @OldWIDTH,
								 @OldKIND,
								 @SIZE,
								 @FARAD,
								 @WIDTH,
								 @KIND,
								 @PLUS,
								 @MINUS,
								 @비고,
								 @VNT_PLAN_QTY,
								 @VVT_PLAN_QTY


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM SIZE_UNIT WHERE SIZE = @SIZE 
					AND FARAD = @FARAD AND WIDTH = @WIDTH 
					AND KIND = @KIND) 
					
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SIZE)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'SIZE_UNIT',@SIZE OUTPUT
                    END

                    INSERT INTO SIZE_UNIT
						(
						    SIZE,
						    FARAD,
						    WIDTH,
						    KIND,
						    PLUS,
						    MINUS,
						    VNT_PLAN_QTY,
						    VVT_PLAN_QTY
						)
						VALUES
						(
						    @SIZE,
						    @FARAD,
						    @WIDTH,
						    @KIND,
						    @PLUS,
						    @MINUS,
						    @VNT_PLAN_QTY,
						    @VVT_PLAN_QTY
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE SIZE_UNIT
						SET
						    SIZE =   ISNULL(@SIZE,SIZE),
						    FARAD =   ISNULL(@FARAD,FARAD),
						    WIDTH =   ISNULL(@WIDTH,WIDTH),
						    KIND =   ISNULL(@KIND,KIND),
						    PLUS =   ISNULL(@PLUS,PLUS),
						    MINUS =   ISNULL(@MINUS,MINUS),
						    VNT_PLAN_QTY =   ISNULL(@VNT_PLAN_QTY,VNT_PLAN_QTY),
						    VVT_PLAN_QTY =   ISNULL(@VVT_PLAN_QTY,VVT_PLAN_QTY)
						WHERE
						    SIZE = @OldSIZE AND
						    FARAD = @OldFARAD AND
						    WIDTH = @OldWIDTH AND
						    KIND = @OldKIND
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM SIZE_UNIT
						WHERE
						    SIZE = @OldSIZE AND
						    FARAD = @OldFARAD AND
						    WIDTH = @OldWIDTH AND
						    KIND = @OldKIND
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
