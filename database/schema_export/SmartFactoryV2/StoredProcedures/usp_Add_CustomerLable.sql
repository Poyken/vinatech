-- Procedure: usp_Add_CustomerLable
CREATE PROC [dbo].[usp_Add_CustomerLable]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
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


	DECLARE @Ymd NVARCHAR(50)
DECLARE @Years NVARCHAR(50)
DECLARE @Moth NVARCHAR(50)
DECLARE @Days NVARCHAR(50)
DECLARE @date date = '2022-01-03';
DECLARE @Wk NVARCHAR(53)
SELECT  @Wk=DATEPART(week, @date);
DECLARE @IDS INT
DECLARE @D2 NVARCHAR(150)
DECLARE @CODELS  NVARCHAR(150)
--SELECT  @Ymd = CONVERT(VARCHAR, GETDATE(), 112)
SELECT @Years = DATEPART(year, CURRENT_TIMESTAMP);
SELECT @Moth = DATEPART(MONTH, CURRENT_TIMESTAMP);
SELECT @Days = DATEPART(DAY, CURRENT_TIMESTAMP);


		 DECLARE @OldCompanyCode INT
		 DECLARE @RLCS NVARCHAR(30)
		 DECLARE @FIXCODE NVARCHAR(30)
		 DECLARE @YMDS NVARCHAR(50)
		 DECLARE @SERIALNO NVARCHAR(50) 
		 DECLARE @WNCPNVSID NVARCHAR(100)
		 DECLARE @PARTNUMBER NVARCHAR(100)
		 DECLARE @DCBRAND NVARCHAR(30)
		 DECLARE @LOTNO NVARCHAR(50)
		 DECLARE @VINATECHPARTNUMBER NVARCHAR(50)
		 DECLARE @MARKING NVARCHAR(100)
		 DECLARE @QTY NVARCHAR(10)
		 DECLARE @D2QRCODE NVARCHAR(150)
		 DECLARE @CODERLCS NVARCHAR(150)
		 DECLARE @LabelQty INT
		 DECLARE @STATUSPRINTER BIT
		 DECLARE @CreateDateTime DATETIME
		 DECLARE @CreateUserID NVARCHAR(30)
		 DECLARE @ChangeDateTime DATETIME
		 DECLARE @ChangeUserID NVARCHAR(50)
		 DECLARE @iDoc INT

		 EXEC SmartFramework.dbo.usp_GetSerialRule 
		 @pTableName = 'STB_VN_CUSTOMER_LABLE',
		 @pIsAutoKey = @IsAutoKey OUTPUT,
		 @pIsLoopIUD = @IsLoopIUD OUTPUT,
		 @pPrefixData = @PrefixString OUTPUT,
		 @pSerialLen = @SerialLen OUTPUT
		 

		IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY

					 MERGE STB_VN_CUSTOMER_LABLE AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							--XMLData.RLCS,
							--XMLData.FIXCODE,
							--XMLData.YMD,
							XMLData.SERIALNO,
							--XMLData.WNCPNVSID,
							--XMLData.PARTNUMBER,
							XMLData.DCBRAND,
							XMLData.LOTNO,
							--XMLData.VINATECHPARTNUMBER,
							--XMLData.MARKING,
							XMLData.QTY,
							XMLData.D2QRCODE,
							XMLData.CODERLCS,
							XMLData.LabelQty,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										--RLCS NVARCHAR(30),
										--FIXCODE NVARCHAR(30),
										--YMD NVARCHAR(50),
										SERIALNO NVARCHAR(50),
										--WNCPNVSID NVARCHAR(100),
										--PARTNUMBER NVARCHAR(100),
										DCBRAND NVARCHAR(30),
										LOTNO NVARCHAR(50),
										--VINATECHPARTNUMBER NVARCHAR(50),
										--MARKING NVARCHAR(100),
										QTY NVARCHAR(10),
										D2QRCODE NVARCHAR(150),
										CODERLCS NVARCHAR(150),
										LabelQty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)
			WHEN MATCHED THEN
				UPDATE SET
					--RLCS = SourceTable.RLCS,
					--FIXCODE = SourceTable.FIXCODE,
					--YMD =SourceTable.YMD,
					SERIALNO = SourceTable.SERIALNO,
					--WNCPNVSID = SourceTable.WNCPNVSID,
					--PARTNUMBER = SourceTable.PARTNUMBER,
					DCBRAND = SourceTable.DCBRAND,
					LOTNO = SourceTable.LOTNO,
					--VINATECHPARTNUMBER = SourceTable.VINATECHPARTNUMBER,
					--MARKING = SourceTable.MARKING,
					QTY = SourceTable.QTY,
					D2QRCODE = RLCS + FIXCODE + @Ymd + SourceTable.SERIALNO + ',' + WNCPNVSID + ',' +  RIGHT(@Years,2) + @Wk + 'VINA TECH' + ',' + SourceTable.LOTNO + ','+ SourceTable.QTY,
					CODERLCS = RLCS + FIXCODE + @Ymd + SourceTable.SERIALNO,
					LabelQty = SourceTable.LabelQty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
  WHEN NOT MATCHED THEN
				INSERT
					(
						--RLCS,
						--FIXCODE,
						--YMD,
						SERIALNO,
						--WNCPNVSID,
						--PARTNUMBER,
						DCBRAND,
						LOTNO,
						--VINATECHPARTNUMBER,
						--MARKING,
						QTY,
						D2QRCODE,
						CODERLCS,
						LabelQty,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							--SourceTable.RLCS,
							--SourceTable.FIXCODE,
							--SourceTable.YMD,
							SourceTable.SERIALNO,
							--SourceTable.WNCPNVSID,
							--SourceTable.PARTNUMBER,
							SourceTable.DCBRAND,
							SourceTable.LOTNO,
							--SourceTable.VINATECHPARTNUMBER,
							--SourceTable.MARKING,
							SourceTable.QTY,
							SourceTable.D2QRCODE,
							SourceTable.CODERLCS,
							SourceTable.LabelQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);


-- Process Update Table

	 MERGE STB_VN_CUSTOMER_LABLE AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
						    XMLData.ID,
							--XMLData.RLCS,
							--XMLData.FIXCODE,
							--XMLData.YMD,
							XMLData.SERIALNO,
							--XMLData.WNCPNVSID,
							--XMLData.PARTNUMBER,
							XMLData.DCBRAND,
							XMLData.LOTNO,
							--XMLData.VINATECHPARTNUMBER,
							--XMLData.MARKING,
							XMLData.QTY,
							XMLData.D2QRCODE,
							XMLData.CODERLCS,
							XMLData.LabelQty,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										--RLCS NVARCHAR(30),
										--FIXCODE NVARCHAR(30),
										--YMD NVARCHAR(50),
										SERIALNO NVARCHAR(50),
										--WNCPNVSID NVARCHAR(100),
										--PARTNUMBER NVARCHAR(100),
										DCBRAND NVARCHAR(30),
										LOTNO NVARCHAR(50),
										--VINATECHPARTNUMBER NVARCHAR(50),
										--MARKING NVARCHAR(100),
										QTY NVARCHAR(10),
										D2QRCODE NVARCHAR(150),
										CODERLCS NVARCHAR(150),
										LabelQty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)
 
 WHEN MATCHED THEN
				UPDATE SET
					--RLCS = SourceTable.RLCS,
					--FIXCODE = SourceTable.FIXCODE,
					--YMD =SourceTable.YMD,
					SERIALNO = SourceTable.SERIALNO,
					--WNCPNVSID = SourceTable.WNCPNVSID,
					--PARTNUMBER = SourceTable.PARTNUMBER,
					DCBRAND = SourceTable.DCBRAND,
					LOTNO = SourceTable.LOTNO,
					--VINATECHPARTNUMBER = SourceTable.VINATECHPARTNUMBER,
					--MARKING = SourceTable.MARKING,
					QTY = SourceTable.QTY,
					D2QRCODE = RLCS + FIXCODE + @Ymd + SourceTable.SERIALNO + ',' + WNCPNVSID + ',' +  RIGHT(@Years,2) + @Wk + 'VINA TECH' + ',' + SourceTable.LOTNO + ','+ SourceTable.QTY,
					CODERLCS = RLCS + FIXCODE + @Ymd + SourceTable.SERIALNO,
					LabelQty = SourceTable.LabelQty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
				
			WHEN NOT MATCHED THEN
		INSERT
					(
						--RLCS,
						--FIXCODE,
						--YMD,
						SERIALNO,
						--WNCPNVSID,
						--PARTNUMBER,
						DCBRAND,
						LOTNO,
						--VINATECHPARTNUMBER,
						--MARKING,
						QTY,
						D2QRCODE,
						CODERLCS,
						LabelQty,
						CreateDateTime,
						CreateUserID
					
					)
				VALUES
					(
							--SourceTable.RLCS,
							--SourceTable.FIXCODE,
							--SourceTable.YMD,
							SourceTable.SERIALNO,
							--SourceTable.WNCPNVSID,
							--SourceTable.PARTNUMBER,
							 @Wk + '-VINA TECH',
							SourceTable.LOTNO,
							--SourceTable.VINATECHPARTNUMBER,
							--SourceTable.MARKING,
							SourceTable.QTY,
							SourceTable.D2QRCODE,
							SourceTable.CODERLCS,
							SourceTable.LabelQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

					-- Process Delete Table

					   MERGE STB_VN_CUSTOMER_LABLE AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
						    XMLData.ID,
							--XMLData.RLCS,
							--XMLData.FIXCODE,
							--XMLData.YMD,
							XMLData.SERIALNO,
							--XMLData.WNCPNVSID,
							--XMLData.PARTNUMBER,
							XMLData.DCBRAND,
							XMLData.LOTNO,
							--XMLData.VINATECHPARTNUMBER,
							--XMLData.MARKING,
							XMLData.QTY,
							XMLData.D2QRCODE,
							XMLData.CODERLCS,
							XMLData.LabelQty,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										--RLCS NVARCHAR(30),
										--FIXCODE NVARCHAR(30),
										--YMD NVARCHAR(50),
										SERIALNO NVARCHAR(50),
										--WNCPNVSID NVARCHAR(100),
										--PARTNUMBER NVARCHAR(100),
										DCBRAND NVARCHAR(30),
										LOTNO NVARCHAR(50),
										--VINATECHPARTNUMBER NVARCHAR(50),
										--MARKING NVARCHAR(100),
										QTY NVARCHAR(10),
										D2QRCODE NVARCHAR(150),
										CODERLCS NVARCHAR(150),
										LabelQty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.ID = SourceTable.ID
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
									XMLData.OldCompanyCode,
									XMLData.ID,
									--XMLData.RLCS,
									--XMLData.FIXCODE,
									--XMLData.YMD,
									XMLData.SERIALNO,
									--XMLData.WNCPNVSID,
									--XMLData.PARTNUMBER,
									XMLData.DCBRAND,
									XMLData.LOTNO,
									--XMLData.VINATECHPARTNUMBER,
									--XMLData.MARKING,
									XMLData.QTY,
									XMLData.D2QRCODE,
									XMLData.CODERLCS,
									XMLData.LabelQty,
									DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
									@pProcessUserID AS CreateUserID,
									DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
									@pProcessUserID AS ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											ID INT,
											--RLCS NVARCHAR(30),
											--FIXCODE NVARCHAR(30),
											--YMD NVARCHAR(50),
											SERIALNO NVARCHAR(50),
											--WNCPNVSID NVARCHAR(100),
											--PARTNUMBER NVARCHAR(100),
											DCBRAND NVARCHAR(30),
											LOTNO NVARCHAR(50),
											--VINATECHPARTNUMBER NVARCHAR(50),
											--MARKING NVARCHAR(100),
											QTY NVARCHAR(10),
											D2QRCODE NVARCHAR(150),
											CODERLCS NVARCHAR(150),
											LabelQty INT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
									UNION ALL

									SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
										XMLData.ID,
										--XMLData.RLCS,
										--XMLData.FIXCODE,
										--XMLData.YMD,
										XMLData.SERIALNO,
										--XMLData.WNCPNVSID,
										--XMLData.PARTNUMBER,
										XMLData.DCBRAND,
										XMLData.LOTNO,
										--XMLData.VINATECHPARTNUMBER,
										--XMLData.MARKING,
										XMLData.QTY,
										XMLData.D2QRCODE,
										XMLData.CODERLCS,
										XMLData.LabelQty,
										DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
										@pProcessUserID AS CreateUserID,
										DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
										@pProcessUserID AS ChangeUserID
								
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											ID INT,
											--RLCS NVARCHAR(30),
											--FIXCODE NVARCHAR(30),
											--YMD NVARCHAR(50),
											SERIALNO NVARCHAR(50),
											--WNCPNVSID NVARCHAR(100),
											--PARTNUMBER NVARCHAR(100),
											DCBRAND NVARCHAR(30),
											LOTNO NVARCHAR(50),
											--VINATECHPARTNUMBER NVARCHAR(50),
											--MARKING NVARCHAR(100),
											QTY NVARCHAR(10),
											D2QRCODE NVARCHAR(150),
											CODERLCS NVARCHAR(150),
											LabelQty INT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
										XMLData.ID,
										--XMLData.RLCS,
										--XMLData.FIXCODE,
										--XMLData.YMD,
										XMLData.SERIALNO,
										--XMLData.WNCPNVSID,
										--XMLData.PARTNUMBER,
										XMLData.DCBRAND,
										XMLData.LOTNO,
										--XMLData.VINATECHPARTNUMBER,
										--XMLData.MARKING,
										XMLData.QTY,
										XMLData.D2QRCODE,
										XMLData.CODERLCS,
										XMLData.LabelQty,
										DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
										@pProcessUserID AS CreateUserID,
										DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
										@pProcessUserID AS ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											ID INT,
											--RLCS NVARCHAR(30),
											--FIXCODE NVARCHAR(30),
											--YMD NVARCHAR(50),
											SERIALNO NVARCHAR(50),
											--WNCPNVSID NVARCHAR(100),
											--PARTNUMBER NVARCHAR(100),
											DCBRAND NVARCHAR(30),
											LOTNO NVARCHAR(50),
											--VINATECHPARTNUMBER NVARCHAR(50),
											--MARKING NVARCHAR(100),
											QTY NVARCHAR(10),
											D2QRCODE NVARCHAR(150),
											CODERLCS NVARCHAR(150),
											LabelQty INT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											
											) XMLData
					 OPEN SourceData

					 
					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 --@RLCS,
								 --@FIXCODE,
								 --@YMD,
								 @SERIALNO,
								 --@WNCPNVSID,
								 --@PARTNUMBER,
								 @DCBRAND,
								 @LOTNO,
								 --@VINATECHPARTNUMBER,
								 --@MARKING,
								 @QTY,
								 @D2QRCODE,
								 @CODERLCS,
								 @LabelQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

			
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_CUSTOMER_LABLE WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_CUSTOMER_LABLE', @OldCompanyCode OUTPUT

		
		INSERT INTO STB_VN_CUSTOMER_LABLE
						(
							--RLCS,
							--FIXCODE,
							--YMD,
						    SERIALNO,
							--WNCPNVSID,
							--PARTNUMBER,
						    DCBRAND,
						    LOTNO,
							--VINATECHPARTNUMBER,
							--MARKING,
						    QTY,
						    D2QRCODE,
							CODERLCS,
							LabelQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
							--@RLCS,
							--@FIXCODE,
							--@YMD,
						    @SERIALNO,
							--@WNCPNVSID,
							--@PARTNUMBER,
						    @DCBRAND,
						    @LOTNO,
							--@VINATECHPARTNUMBER,
							--@MARKING,
						    @QTY,
						    @RLCS + @WNCPNVSID + @Wk + 'VINA' + @LOTNO + @QTY,
							@RLCS + @FIXCODE + @Ymds + @SERIALNO,
							@LabelQty,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_CUSTOMER_LABLE
						SET

						SERIALNO = CASE
									WHEN @SERIALNO IS NOT NULL THEN @SERIALNO
									ELSE SERIALNO
									END,
						
						DCBRAND =   CASE
						                WHEN @DCBRAND IS  NULL THEN @DCBRAND
						                ELSE DCBRAND
						            END,

							 LOTNO =   CASE
						                WHEN @LOTNO IS NOT NULL THEN @LOTNO
						                ELSE LOTNO
						            END,

							 QTY =   CASE
						                WHEN @QTY IS NOT NULL THEN @QTY
						                ELSE QTY
						            END,
							 D2QRCODE =   CASE
						                WHEN @D2QRCODE IS  NULL THEN RLCS + FIXCODE + @Ymd + SERIALNO + ',' + WNCPNVSID + ',' +  RIGHT(@Years,2) + @Wk + 'VINA TECH' + ',' + LOTNO + ','+ QTY
						                ELSE D2QRCODE
						            END,
						 CODERLCS =   CASE
						                WHEN @CODERLCS IS  NULL THEN @CODERLCS
						                ELSE CODERLCS
						            END,
						
						 LabelQty =   CASE
						                WHEN @LabelQty IS NOT NULL THEN @LabelQty
						                ELSE LabelQty
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_CUSTOMER_LABLE
						WHERE
						    ID = @OldCompanyCode
                    END
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



GO

