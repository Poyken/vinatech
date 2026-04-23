
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:  usp_DayMaterialOrderAndAdditional_his '','','VVT','VVT_F1','2024-11-26','2024-11-26','','','' 
-- Modified:  usp_DayMaterialOrderAndAdditional_his '','','','','','','','','241023000016' 
--- 
 --    usp_DayMaterialOrderAndAdditional_exported '','','VVT','VVT_F1','2024-12-05','2024-12-05','','','' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrderAndAdditional_exported]
	@pProcessUserID VARCHAR(20)= NULL,
	@pProcessLanguage VARCHAR(20)= NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pPoNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
   		DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
		DECLARE @LineCode VARCHAR(30) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
		DECLARE	   @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	    DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00' 
		DECLARE @MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END			 
		DECLARE @PoNo VARCHAR(30) = @pPoNo


		--raiserror(@pCompanyCode,16,1)

--	SELECT 
--    PONo,
--    DayPlanNo,
--    ChildMaterialCode,
--    MaterialName,
--    LineCode,
--    CONVERT(DATE, Plandate) AS Plandate,  -- Chuyển đổi Plandate sang kiểu DATE
--    CreateDateTime,
--    CreateUserID,
--    ChangeDateTime,
--    ChangeUserID,
--    MaterialOrderNo,
--    SoLuongKeHoachNgay,
--    NVLngay,
--    UsedQtyDay,
--    IsAdditional,
--    OrderDesc,
--    CompanyCode,
--    WorkCenterCode,
--    QtyExp,
--    QtyByPO,
--    Id,
--    ExportDesc,
--    ExportDateTime,
--    ExportUserID,
--    ExportChangeTime,
--    ExportChangeUserID
--FROM STB_DayMaterialOrder where QtyExp >0  order by createdatetime DESc



				;with
				ha as (
								select
										PONo,
										DayPlanNo,
										ChildMaterialCode as MaterialCode,
										MaterialName,
										LineCode,
										CONVERT(DATE, Plandate) AS Plandate,  -- Chuyển đổi Plandate sang kiểu DATE
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID,
										MaterialOrderNo,
										SoLuongKeHoachNgay,
										NVLngay,
										UsedQtyDay,
										IsAdditional,
										OrderDesc,
										CompanyCode,
										WorkCenterCode,
										 QtyExp,
										QtyByPO,
										Id,
										ExportDesc,
										ExportDateTime,
										ExportUserID,
										ExportChangeTime,
										ExportChangeUserID,
										StatusWarehouseConfirm
										 from STB_DayMaterialOrder 

							--where 
								--CreateDateTime BETWEEN @FromDate AND @ToDate
								--AND  WorkCenterCode LIKE @WorkCenterCode 
								--AND  LineCode LIKE @LineCode
								--AND (QtyExp =0 or QtyExp ='' or QtyExp is null )

							
				) , 
				 test as (
							 SELECT 
							MaterialWarehouseInOutHistNo
							,MM.MaterialCode
							 ,MWIOH.LineCode				 	  
 							 , MDLI.StockQty               AS OutQty, 
							 MWIOH.CreateDateTime ,
								CAST(MWIOH.CreateDateTime AS DATE)    as ngayxuat                    -- 불출수량							   
									 
					  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1		       with(nolock)     ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2		        with(nolock)    ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		        with(nolock)            ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock)   ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN ( 
														SELECT LotID
														 	  ,MaterialCode
															  ,isnull((select sum(isnull(CurrentQty,0)) from STB_MaterialLotInfo  with(nolock)  where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty   --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														  FROM STB_MaterialDocLotInfo  smdli with(nolock) 
														  where  lotid not in (
																	  SELECT LotID  
																	FROM STB_MaterialLotInfo  with(nolock)  
																	where  MaterialWarehouseCode='HOLDING_VN_WH' 
														  )	
														  GROUP BY LotID, MaterialCode
														UNION ALL  

														SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
															,MaterialCode 
															,sum(CurrentQty )CurrentQty
														FROM STB_MaterialLotInfo  with(nolock)  
														where  MaterialWarehouseCode='HOLDING_VN_WH' 														
														GROUP BY LotID, MaterialCode 

														UNION ALL

															SELECT LotID                    --2022.05.26 add lot detach
															,MaterialCode 
															,sum(CurrentQty )CurrentQty 
														FROM STB_MaterialLotInfo  with(nolock)  
														where LotID like 'SP%'											
														GROUP BY LotID, MaterialCode--, CurrentQty 

													 ) MDLI ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM  with(nolock)  ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI  with(nolock)  ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode   
							  LEFT OUTER JOIN STB_MaterialLotInfo MLI    ON MLI.LotID = MWIOH.LotID
							 
							 
					 WHERE 1=1	   
					   And (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   And (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   --And MWIOH.CompanyCode ='VVT'
					   --And MWIOH.WorkCenterCode='VVT_F1'
					   And MWIOH.LotID NOT IN ( 
															   SELECT LotID 
																FROM STB_MaterialDocLotInfo  with(nolock)  
															   WHERE MaterialLocationCode LIKE 'ROUTE_%'
															      AND CreateDateTime  BETWEEN @FromDate AND @ToDate
															      --AND CreateDateTime BETWEEN '2024-12-04 00:00:00' AND '2024-12-04 23:59:59'
														    )
					   and MWIOH.SourceMaterialWarehouseCode not in ('ELEC_VN_WH')
					   And MWIOH.CreateDateTime    BETWEEN @FromDate AND @ToDate		
					   --And  MWIOH.CreateDateTime  BETWEEN '2024-12-04 00:00:00' AND '2024-12-30 23:59:59'
						And MWIOH.WarehouseInOutCode = 'O' and (MWIOH.SourceMaterialWarehouseCode like 'ROH_VN_WH%' and MWIOH.TargetMaterialWarehouseCode like 'ROUTE_VN_WH') 
						--or (MWIOH.SourceMaterialWarehouseCode like 'ROH_BG_WH%' and MWIOH.TargetMaterialWarehouseCode like 'ROUTE_BG_WH') 

				), b1 as (
							select MaterialOrderNo,
							LineCode,
							MaterialCode, 
							isnull(max(ExportChangeTime),(CAST(CAST(GETDATE() AS DATE) AS DATETIME) + '10:00:00')) as ExportChangeTime , 
							StatusWarehouseConfirm, 
							PONo,
							DayPlanNo,
							MaterialName,			
							Plandate,  
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,		
							SoLuongKeHoachNgay,
							NVLngay,
							UsedQtyDay,
							IsAdditional,
							OrderDesc,
							CompanyCode,
							WorkCenterCode,
							QtyExp,
							QtyByPO,
							Id,
							ExportDesc,
							ExportDateTime,
							ExportUserID,
							ExportChangeUserID
							from ha
							group by  materialorderno , linecode,MaterialCode, StatusWarehouseConfirm, 				
							PONo,
							DayPlanNo,
							MaterialName,			
							Plandate,  
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,		
							SoLuongKeHoachNgay,
							NVLngay,
							UsedQtyDay,
							IsAdditional,
							OrderDesc,
							CompanyCode,
							WorkCenterCode,
							QtyExp,
							QtyByPO,
							Id,
							ExportDesc,
							ExportDateTime,
							ExportUserID,
							ExportChangeUserID
				)
				,b11 as (
						select LineCode,MaterialCode,max(ExportChangeTime) as ExportChangeTime1 from b1  --where linecode='vvc-16'
						group by  LineCode,MaterialCode
				)
				, b2 as (
							 select 
							 a.MaterialOrderNo , b.MaterialCode AS MaterialCode , b.LineCode,CAST(sum(b.OutQty)  AS INT)  as OutQty, max(a.ExportChangeTime) as ExportChangeTime , max(b1.ExportChangeTime1) as ExportChangeTime2,a.StatusWarehouseConfirm,
							 		PONo,
									DayPlanNo,
									MaterialName,			
									Plandate,  
									a.CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,		
									SoLuongKeHoachNgay,
									NVLngay,
									UsedQtyDay,
									IsAdditional,
									OrderDesc,
									CompanyCode,
									WorkCenterCode,
									QtyExp,
									QtyByPO,
									Id,
									ExportDesc,
									ExportDateTime,
									ExportUserID,
									ExportChangeUserID
							  
							 from b1  a 
							 LEFT  join b11 b1 on  a.MaterialCode = b1.MaterialCode and a.LineCode = b1.LineCode
							 LEFT  join test b on  a.MaterialCode = b.MaterialCode and a.LineCode = b.LineCode
							 where b.createdatetime >=ExportChangeTime1 AND StatusWarehouseConfirm =0
							group by  a.materialorderno , b.MaterialCode, b.linecode, a.StatusWarehouseConfirm,
									PONo,
									DayPlanNo,
									MaterialName,			
									Plandate,  
									a.CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,		
									SoLuongKeHoachNgay,
									NVLngay,
									UsedQtyDay,
									IsAdditional,
									OrderDesc,
									CompanyCode,
									WorkCenterCode,
									QtyExp,
									QtyByPO,
									Id,
									ExportDesc,
									ExportDateTime,
									ExportUserID,
									ExportChangeUserID
					
				)
				
				
				select * from b2



END





