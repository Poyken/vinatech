CREATE PROCEDURE [dbo].[usp_UpdateStatusScrap]
@pProcessLanguage VARCHAR(20),
@pProcessUserID VARCHAR(20),
@pLotno	NVARCHAR(50) = NULL,
@pStatus NVARCHAR(20) = NULL,
@pLineOut NVARCHAR(20) = NULL,
@pQtyOut NVARCHAR(20) = NULL,
@pQuantity NVARCHAR(20) = NULL,
@pQtyCanOut NVARCHAR(20) = NULL,
@pID NUMERIC = NULL,
@pReason NVARCHAR(200) = NULL,
@pDescription NVARCHAR(200) = NULL
AS
BEGIN

	
	DECLARE @NotEnoughStockError NVARCHAR(MAX)
	DECLARE @MaterialNo VARCHAR(50)
	DECLARE @MaterialName VARCHAR(200)
	DECLARE @PONo VARCHAR(50)
	DECLARE @ProdQty NUMERIC
	DECLARE @Quantity NUMERIC
	DECLARE @RouteCode NVARCHAR(50)
	DECLARE @InputLineCode NVARCHAR(50)
	DECLARE @QtyCanOutCAST NVARCHAR(20) = cast(@pQtyCanOut as NUMERIC)- CAST(@pQtyOut AS NUMERIC)
	DECLARE @Status VARCHAR(50)

	select @Status= statuss from STB_ScrapsByLot where ID = @pID
	-- Output to production
	IF (@pStatus='XUAT RA SAN XUAT' OR @pStatus='BAO PHE')
		
	BEGIN
	--	RAISERROR(@pStatus ,16,1)
    --Press info qty, line
			
				IF @Status = 'BAO PHE'
				BEGIN
					BEGIN
							EXEC usp_GetSystemStringResource	@pProcessLanguage,
																N'^Not change information when status is BAO PHE^',
																@NotEnoughStockError OUTPUT

							RAISERROR(@NotEnoughStockError,16,1)
							RETURN		
					END
				END
				IF @pQtyOut IS NULL 
					BEGIN
							EXEC usp_GetSystemStringResource	@pProcessLanguage,
																N'^Press Enter Quantity Output^',
																@NotEnoughStockError OUTPUT

							RAISERROR(@NotEnoughStockError,16,1)
							RETURN		
					END
					
				IF   CAST(@pQtyOut as NUMERIC) > CAST( @pQtyCanOut as NUMERIC) 
				BEGIN
					    EXEC usp_GetSystemStringResource	@pProcessLanguage,
															N'^Quantity Output not bigger quantity can Out^',
															@NotEnoughStockError OUTPUT

						RAISERROR(@NotEnoughStockError,16,1)
						RETURN		
				END
				if @pStatus='XUAT RA SAN XUAT'
				BEGIN
				
						If @pLineOut IS NULL 
					BEGIN
						
						EXEC usp_GetSystemStringResource	@pProcessLanguage,
															N'^Press Enter Line Output^',
															@NotEnoughStockError OUTPUT

						RAISERROR(@NotEnoughStockError,16,1)
						RETURN		
					END
				END
				--check quantity less quantity finish
				--IF quantity output less more quantity finish will detach line
				
				IF CAST(@pQtyOut as NUMERIC)  <  CAST( @pQtyCanOut as NUMERIC)  
				BEGIN
					
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
							SI.Barcode = @pLotno
							OR SI.Barcode = (SELECT NewBarcode   FROM STB_LotChangeMaterialHistory  WHERE OldBarcode = @pLotno)
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
					
				

					
					INSERT INTO STB_ScrapsByLot
						(
							LotNo,
							BasicDate,
							Statuss,
							ProdQty,
							Quantity,
							MaterialNo,
							MaterialName,
  							RouteCode,
 							InputLineCode ,
  							PONo,
							QtyCanOut,
							CreateDateTime,
							CreateUserID
						)
					VALUES
						(
							--	SourceTable.DocNo,
								@pLotno,
							--	SourceTable.BasicDate,
								DATEADD(HH, -2, GETDATE()),
								N'CHO PHE',
								@ProdQty,
								@Quantity,
								@MaterialNo,
								@MaterialName,
								@RouteCode,
								@InputLineCode,
								@PONo,
								@QtyCanOutCAST,
								DATEADD(HH, -2, GETDATE()),
								@pProcessUserID
						)

				END		
	
			
			INSERT STB_SCRAPHISTORY
		(
			LOTNO ,
			BASICDATE ,
			STATUSSCRAP ,
			QUANTITY ,
			LINECODE,
			REASON ,
			DESCRIPTION ,
			CREATEDATETIME ,
			CREATEUSERID )
		VALUES (
			@pLotno,
			DATEADD(HH, -2, GETDATE()),
			@pStatus,
			@pQtyOut,
			@pReason,
			@pLineOut,
			@pDescription,
			DATEADD(HH, -2, GETDATE()),
			@pProcessUserID
		)

		UPDATE STB_ScrapsByLot set statuss =@pStatus, Reason = @pReason, Description = @pDescription, QtyOut = @pQtyOut, Line = @pLineOut, QtyCanOut = @pQtyOut, ChangeDateTime = DATEADD(HH, -2, GETDATE()), ChangeUserID=@pProcessUserID where ID = @pID
	END

		

		
   -- UPDATE STB_ScrapsByLot set status =  @pStatus where ID =@pID
  /* IF @pStatus='BAO PHE'
   BEGIN
		RAISERROR(@pStatus ,16,1)
   END
   IF @pStatus='CHO PHE'
   BEGIN
		EXEC usp_GetSystemStringResource	@pProcessLanguage,
															N'^Press Change  Status^',
															@NotEnoughStockError OUTPUT

						RAISERROR(@NotEnoughStockError,16,1)
						RETURN		
   END*/
END

