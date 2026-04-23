CREATE PROCEDURE [dbo].[usp_SearchScrap]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode VARCHAR(50) = NULL
					

AS

BEGIN
	

	  DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	  DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage

	  DECLARE @NotEnoughStockError NVARCHAR(MAX)
	  DECLARE @Barcode VARCHAR(50) = @pBarcode	
	  DECLARE @LotNo VARCHAR(50)
	  DECLARE @BasicDate Date = DATEADD(HH, -2, GETDATE())
	  DECLARE @Status NVARCHAR(50) = N'CHO PHE'
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
	  DECLARE @cnt NUMERIC
	  DECLARE @Route VARCHAR(50)
	  DECLARE @RouteV22 INT

	IF (@Barcode IS NOT NULL  AND datalength(@BarCode) > 0  )
	BEGIN

		
		SELECT @cnt=count(*) FROM STB_ScrapsByLot WHERE LOTNO = @Barcode
		If @cnt =0
			BEGIN
				SELECT
				@RouteV22 = count(*)
				FROM 
						STB_ProdRouteHist WITH(NOLOCK)
				WHERE 1=1 
						AND
						routecode='V-22' 
						AND
						controlno= (select controlno from stb_setinfo where barcode = @BarCode)
				IF @RouteV22  <=0
					BEGIN
							EXEC usp_GetSystemStringResource	@pProcessLanguage,
																N'^Do not have Route V22^',
																@NotEnoughStockError OUTPUT

							RAISERROR(@NotEnoughStockError,16,1)
							RETURN		
					END


				SELECT
				@Route = routecode
				FROM 
						STB_ProdRouteHist WITH(NOLOCK)
				WHERE 1=1 
						AND
						routecode='V-28' 
						AND
						controlno= (select controlno from stb_setinfo where barcode = @BarCode)
			IF @Route  IS NOT NULL
			
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
			
			ELSE
				
								select top(1) @MaterialNo=AAA.MaterialCode,
					@MaterialName=AAA.MaterialName,
					@PONo=AAA.PONo,
					@ProdQty = AAA.ProdQty,
					@Quantity=AAA.ProdQty1,
					@RouteCode=AAA.RouteCode,
					@InputLineCode=AAA.InputLineCode
					from (SELECT PRH.MaterialCode
						   ,MM.MaterialName
						   ,PRH.LineCode as InputLineCode
						   ,SI.PONo
						   ,SI.ProdQty as ProdQty
						   ,PRH.RouteCode
						  -- ,RI.RouteName
						  -- ,PRH.WorkerCode
						  -- ,PWI.WorkerName AS WorkerName
						  --- ,PRH. MachineCode 
						  -- ,MM2.MachineName
						  -- ,PRH.ProdQty AS InputProdQty
						 --  ,ISNULL(DRI.DefectQty, 0) AS DefectQty
						   ,(PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty1
						  -- , PRH.pono, PRH.ProdRouteHistNo
						  , PRH.ProdDateTime AS ProdDate,
						   PRH.CreateDateTime
						  , CONVERT(BIT, CASE WHEN ROW_NUMBER () OVER ( ORDER BY PRH.RouteCode ASC) =   (select COUNT(*) FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @BarCode)) THEN 0 ELSE 1 END) AS ProdQtyFinishYn
					   FROM STB_ProdRouteHist PRH
							   LEFT OUTER JOIN STB_MaterialMaster MM	     ON PRH.MaterialCode = MM.MaterialCode
							   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	     ON PRH.WorkerCode = PWI.EmpNo
							   LEFT OUTER JOIN STB_MachineMaster MM2	     ON PRH.MachineCode = MM2.MachineCode
							   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
														  FROM STB_DefectRepairInfo 
														 WHERE RepairType NOT IN ('MISSING', 'FINISH')
														 GROUP BY ControlNo, FindRouteCode
													  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

							   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode
							   LEFT JOIN STB_SetInfo SI ON   PRH.ControlNo = SI.ControlNo

					  WHERE PRH.ControlNo = ( SELECT ControlNo
													   FROM STB_SetInfo SI
													  WHERE Barcode = @BarCode
													  )) AAA  where AAA.ProdQtyFinishYn =1 order by AAA.CreateDateTime desc
								


			


		
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
								@Quantity,
								DATEADD(HH, -2, GETDATE()),
								@pProcessUserID
						)
		
		END
	END
	
	SELECT			    ID,
						LOTNO,
						convert(varchar, BasicDate, 111) BasicDate,
						Statuss,
						ProdQty,
						Quantity,
						MaterialNo,
						MaterialName,
  						RouteCode,
 						InputLineCode ,
  						PONo,
						Line,
						QtyOut,
						Description,
						Reason,
						QtyCanOut,
						convert(varchar, CreateDateTime, 120) CreateDateTime,
						CreateUserID,
						convert(varchar, ChangeDateTime, 120) ChangeDateTime,
						ChangeUserID 
						FROM STB_ScrapsByLot  WHERE 1=1
						AND (@BarCode IS NULL OR @BarCode ='' OR LotNo =@BarCode)

END
