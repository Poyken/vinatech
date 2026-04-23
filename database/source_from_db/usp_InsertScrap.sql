

CREATE PROCEDURE  [dbo].[usp_InsertScrap]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pBarCode VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
	DECLARE @BarCode VARCHAR(50) = @pBarCode
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
	DECLARE @Template  VARCHAR(20)

	


	  DECLARE @OldCompanyCode INT
	  DECLARE @LotNo  VARCHAR(20)
	  DECLARE @BasicDate Date = DATEADD(HH, -2, GETDATE())
	  DECLARE @Status VARCHAR(50) = 'CHO PHE'
	  DECLARE @MaterialNo VARCHAR(50)
	  DECLARE @MaterialName VARCHAR(200)
	  DECLARE @Quantity NUMERIC
	  DECLARE @Line NVARCHAR(50)
	  DECLARE @Reason NVARCHAR(200)
	  DECLARE @PONo NVARCHAR(50)
	  DECLARE @InputLineCode varchar(50)
	  DECLARE @RouteCode varchar(20)
	  DECLARE @ProdQty numeric
	  DECLARE @QtyOut numeric 
	  DECLARE @Description NVARCHAR(200)
	  DECLARE @CreateDateTime DATETIME
	  DECLARE @CreateUserID VARCHAR(50)
	  DECLARE @ChangeDateTime  DATETIME
	  DECLARE @ChangeUserID VARCHAR(50)
	  DECLARE @iDoc INT

	  

	   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ScrapsByLot',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT   

  IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
   BEGIN TRY
 
	SELECT
			@MaterialNo=SI.MaterialCode,
	        @MaterialName= MM.MaterialName,
			@PONo = SI.PONo,
			@ProdQty = SI.ProdQty,
			@Quantity =SUM(PRH.ProdQty),
			@RouteCode = POR.RouteCode,
		--	PRH.WorkCenterCode,
			@InputLineCode = SI.InputLineCode
		--	MQI.DecisionResult,
		--	DPP.DPPExtText01
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN         STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = SI.PONo                   AND POR.IsOutputRoute = 1
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)		       ON PRH.ControlNo = SI.ControlNo        AND PRH.RouteCode = POR.RouteCode
			LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		       ON MQI.MaterialQcNo = SI.LotNumber                                                          --#200106J
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				           ON DPP.DayPlanNo = SI.DayPlanNo
			INNER JOIN STB_MaterialMaster MM	    ON SI.MaterialCode = MM.MaterialCode
			--INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)			--	ON MM.MaterialCode = SI.MaterialCode
			--INNER JOIN STB_MaterialType MT WITH(NOLOCK)  			--	ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			(
			SI.Barcode = @BarCode
			OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @BarCode)
			)
	GROUP BY
			SI.ControlNo,
			SI.PONo,
			SI.ProdQty,
			POR.RouteCode,
			PRH.WorkCenterCode,
			--MT.BasicMaterialType
			SI.InputLineCode,
			MQI.DecisionResult,
			DPP.DPPExtText01,SI.MaterialCode,
			MM.MaterialName 

	  	-- Process Insert Table	
	MERGE STB_ScrapsByLot AS TargetTable

	USING
	
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.LotNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.LotNo,
							XMLData.BasicDate,
							XMLData.Status,
							XMLData.Description,
							XMLData.Reason,
							XMLData.Quantity,
							XMLData.MaterialNo,
							XMLData.MaterialName,
							XMLData.Line,
							XMLData.ProdQty ,
							XMLData.RouteCode,
 							XMLData.InputLineCode,
  							XMLData.PONo,
							XMLData.QtyOut,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										LotNo varchar(20),
										BasicDate Date,
										Status VARCHAR(50),
										Description NVARCHAR(200),
										Reason NVARCHAR(200),
										Quantity NUMERIC,
										MaterialNo VARCHAR(50),
										MaterialName VARCHAR(200),
										Line NVARCHAR(50),
										ProdQty NUMERIC,
  										RouteCode varchar(20),
 										InputLineCode varchar(50),
  										PONo varchar(50),
										QtyOut NUMERIC,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					ON
				(
					TargetTable.LotNo = SourceTable.LotNo
				)
			WHEN MATCHED THEN
				UPDATE SET
					BasicDate = SourceTable.BasicDate,
					Status = SourceTable.Status,
					Description = SourceTable.Description,
					Reason = SourceTable.Reason,
					QtyOut = SourceTable.QtyOut,
					Line = SourceTable.Line,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

				INSERT
					(
						LotNo,
						BasicDate,
						Status,
						ProdQty,
						Quantity,
						MaterialNo,
						MaterialName,
  						RouteCode,
 						InputLineCode ,
  						PONo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
						--	SourceTable.DocNo,
							@BarCode,
						--	SourceTable.BasicDate,
							@BasicDate,
							@Status,
							@ProdQty,
							@Quantity,
							@MaterialNo,
							@MaterialName,
							@RouteCode,
							@InputLineCode,
							@PONo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

-- Process Update Table
	 MERGE STB_ScrapsByLot AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.LotNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.LotNo,
							XMLData.BasicDate,
							XMLData.Status,
							XMLData.Description,
							XMLData.Reason,
							XMLData.Quantity,
							XMLData.MaterialNo,
							XMLData.MaterialName,
							XMLData.Line,
							XMLData.ProdQty,
  							XMLData.RouteCode,
 							XMLData.InputLineCode ,
  							XMLData.PONo,
							XMLData.QtyOut,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										LotNo varchar(20),
										BasicDate Date,
										Status nvarchar(50),
										Description Nvarchar(200),
										Reason Nvarchar(200),
										Quantity numeric,
										MaterialNo Nvarchar(50),
										MaterialName Nvarchar(200),
										Line varchar(50),
										ProdQty numeric,
  										RouteCode varchar(20),
 										InputLineCode varchar(50),
  										PONo varchar(50),
										QtyOut Numeric,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.LotNo
				)
	WHEN MATCHED THEN
					UPDATE SET
					BasicDate = SourceTable.BasicDate,
					Status = SourceTable.Status,
					Description = SourceTable.Description,
					Reason = SourceTable.Reason,
					Line = SourceTable.Line,
					QtyOut = SourceTable.QtyOut,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

	INSERT
					(
						LotNo,
						BasicDate,
						Status,
						ProdQty,
						Quantity,
						MaterialNo,
						MaterialName,
  						RouteCode,
 						InputLineCode ,
  						PONo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							@BarCode,
						--	SourceTable.BasicDate,
							@BasicDate,
							@Status,
							@ProdQty,
							@Quantity,
							@MaterialNo,
							@MaterialName,
							@RouteCode,
							@InputLineCode,
							@PONo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


-- Process Delete Table
	MERGE STB_ScrapsByLot AS TargetTable
	USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.LotNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.LotNo,
							XMLData.BasicDate,
							XMLData.Status,
							XMLData.Description,
							XMLData.Reason,
							XMLData.Quantity,
							XMLData.MaterialNo,
							XMLData.MaterialName,
							XMLData.Line,
							XMLData.ProdQty,
  							XMLData.RouteCode,
 							XMLData.InputLineCode ,
  							XMLData.PONo,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										LotNo varchar(20),
										BasicDate Date,
										Status nvarchar(50),
										Description Nvarchar(200),
										Reason Nvarchar(200),
										Quantity numeric,
										MaterialNo Nvarchar(50),
										MaterialName Nvarchar(200),
										Line varchar(50),
										ProdQty numeric,
  										RouteCode varchar(20),
 										InputLineCode varchar(50),
  										PONo varchar(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(50)
									) XMLData
				) AS SourceTable
					ON
				(
					TargetTable.LotNo = SourceTable.LotNo
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
									XMLData.LotNo,
									XMLData.BasicDate,
									XMLData.Status,
									XMLData.Description,
									XMLData.Reason,
									XMLData.Quantity,
									XMLData.MaterialNo,
									XMLData.MaterialName,
									XMLData.Line,
									XMLData.ProdQty,
  									XMLData.RouteCode,
 									XMLData.InputLineCode ,
  									XMLData.PONo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											LotNo varchar(20),
											BasicDate Date,
											Status nvarchar(50),
											Description Nvarchar(200),
											Reason Nvarchar(200),
											Quantity numeric,
											MaterialNo Nvarchar(50),
											MaterialName Nvarchar(200),
											Line varchar(50),
											ProdQty numeric,
  											RouteCode varchar(20),
 											InputLineCode varchar(50),
  											PONo varchar(50),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(50),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(50)
											) XMLData
							UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.LotNo
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.LotNo,
									XMLData.BasicDate,
									XMLData.Status,
									XMLData.Description,
									XMLData.Reason,
									XMLData.Quantity,
									XMLData.MaterialNo,
									XMLData.MaterialName,
									XMLData.Line,
									XMLData.ProdQty,
  									XMLData.RouteCode,
 									XMLData.InputLineCode ,
  									XMLData.PONo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											LotNo varchar(20),
											BasicDate Date,
											Status nvarchar(50),
											Description Nvarchar(200),
											Reason Nvarchar(200),
											Quantity numeric,
											MaterialNo Nvarchar(50),
											MaterialName Nvarchar(200),
											Line varchar(50),
											ProdQty numeric,
  											RouteCode varchar(20),
 											InputLineCode varchar(50),
  											PONo varchar(50),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(50),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(50)
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.LotNo
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.LotNo,
									XMLData.BasicDate,
									XMLData.Status,
									XMLData.Description,
									XMLData.Reason,
									XMLData.Quantity,
									XMLData.MaterialNo,
									XMLData.MaterialName,
									XMLData.Line,
									XMLData.ProdQty,
  									XMLData.RouteCode,
 									XMLData.InputLineCode ,
  									XMLData.PONo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											LotNo varchar(20),
											BasicDate Date,
											Status nvarchar(50),
											Description Nvarchar(200),
											Reason Nvarchar(200),
											Quantity numeric,
											MaterialNo Nvarchar(50),
											MaterialName Nvarchar(200),
											Line varchar(50),
											ProdQty numeric,
  											RouteCode varchar(20),
 											InputLineCode varchar(50),
  											PONo varchar(50),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(50),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(50)
											) XMLData
					 OPEN SourceData
					   	   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @BasicDate,
								 @Status,
								 @Description,
								 @Reason,
								 @Quantity,
								 @MaterialNo,
								 @MaterialName,
								 @Line,
								 @ProdQty,
								 @RouteCode,
								 @InputLineCode,
								 @PONo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ScrapsByLot WHERE LotNo = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ScrapsByLot', @OldCompanyCode OUTPUT
            

				INSERT INTO STB_ScrapsByLot
						(
							LotNo,
							BasicDate,
							Status,
							ProdQty,
							Quantity,
							MaterialNo,
							MaterialName,
  							RouteCode,
 							InputLineCode ,
  							PONo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@BarCode,
						--	SourceTable.BasicDate,
							@BasicDate,
							@Status,
							@ProdQty,
							@Quantity,
							@MaterialNo,
							@MaterialName,
							@RouteCode,
							@InputLineCode,
							@PONo,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_ScrapsByLot
				SET
							BasicDate =   CASE
						                WHEN @BasicDate IS NOT NULL THEN @BasicDate
						                ELSE BasicDate
						            END,
							@Status = CASE
								 WHEN @Status IS NOT NULL THEN @Status
						                ELSE Status
						            END,

							@Description = CASE
								 WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
						            END,
							@Reason = CASE
								 WHEN @Reason IS NOT NULL THEN @Reason
						                ELSE Reason
						            END,
							@Line = CASE
								 WHEN @Line IS NOT NULL THEN @Line
						                ELSE Line
						            END,
							@QtyOut = CASE
								WHEN @QtyOut IS NOT NULL THEN @QtyOut
										ELSE QtyOut
								END,

							ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID

WHERE
						    LotNo = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_ScrapsByLot
						WHERE
						    LotNo = @OldCompanyCode
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