-- =============================================
-- Author:		Mr.Duy	
-- Create date: 2025-03-08
-- Description:	Báo cáo về nguyên vật liệu hà nam
-- =============================================
--      EXEC usp_MaterialReportTK_new_HN '2025-03-01','2025-03-31'
CREATE PROCEDURE [dbo].[usp_MaterialReportTK_new_HN]
	@pFromDate date = NULL,
	@pToDate   date = NULL
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;


declare @FromDate varchar(19) =   convert(varchar(10),@pFromDate,120)               + ' 10:00:00'

declare @ToDate  varchar(19)  =   convert(varchar(10),dateadd(day,1,@pToDate),120)  + ' 10:00:00'

DECLARE @pMaterialWarehouseCode VARCHAR(50) = 'ROH_VN_WH'
DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

declare @daten varchar(19) = @FromDate

if(@FromDate>='2025-01-01' and @FromDate<='2025-02-28') begin
	print 'a'
			;with
			InventoryMaterial as( -- tồn đầu kì được kiểm kê đầu năm 2025
				select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock) where [Period]='2025-03-01' and workcentercode='VVT_F3'
			),
			InputMaterialCode as ( -- lấy ra nhập vào kho nvl
					select  (case when mli.materialcode<> mm.MaterialCode then mli.materialcode else mm.MaterialCode end) MaterialCode
					  , mm.materialName, mm.MMExtText03 as NameHQ, mm.MMExtText04 as CodeHQ ,  --mm.MaterialUnit,
					(case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime 
					else mdi.CreateDateTime 
					end) basicdate,

							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime
					else mdi.CreateDateTime 
					end)  < @FromDate  then StockQty  end as NhapDauKy,


							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime
					else mdi.CreateDateTime
					end)  between '2023-01-01 10:00:00' and @daten   then StockQty  end as NhapDauKy1,


							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime 
					else mdi.CreateDateTime 
					end)  between  @FromDate and @ToDate   then StockQty end as NhapTrongKy


							from STB_MaterialMaster  mm WITH(NOLOCK)
							left join STB_MaterialDocDetail mdt WITH(NOLOCK) ON mm.MaterialCode = mdt.MaterialCode
							left join STB_MaterialDocInfo mdi WITH(NOLOCK) ON  mdt.MaterialDocNo = mdi.MaterialDocNo
							left join STB_MaterialDocLotInfo mli WITH(NOLOCK) on  mdt.MaterialDocDetailNo = mli.MaterialDocDetailNo
							left join STB_MaterialLotInfo mli1 WITH(NOLOCK) on  mli.LotID = mli1.LotID
					where   mdi.TargetCompanyCode='VVT' --and mdi.TargetWorkCenterCode='VVT_F1' 
					and		mdi.materialDocType='GR' and mdi.materialdoctypecode in ('GR_NORMAL','GR_RETURN_MATERIAL') and mdi.docstatus in ('FIX','FINISH','ARRIVAL')
			),
			 table1  as (
				select MaterialCode, NameHQ, CodeHQ , 
				sum(NhapDauKy) as NhapDauKy, sum(NhapDauKy1) as NhapDauKy1, sum(NhapTrongKy) as NhapTrongKy from InputMaterialCode 
				group by materialcode, namehq, codehq
			)
			, table2 as -- lấy ra nhập xuất khỏi kho nvl
			(
					SELECT						
									  MaterialWarehouseInOutHistNo
									  ,WarehouseInOutCode
									  ,BC.Description                               AS WarehouseInOutName
									  ,SourceMaterialWarehouseCode
									  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
									  ,TargetMaterialWarehouseCode
									  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
									  ,MWIOH.LotID				  
									 , MM.MaterialCode						 
									  ,MM.MaterialName
									  ,MWIOH.WorkerCode
									  ,PWI.WorkerName
									  ,MWIOH.LineCode
									 ,LI.LineName, 
									 case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and MWIOH.linecode='R-KR' then 'Tai Xuat'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode  in ('XCDMDSD','XTH') then 'Xuat chuyen doi, tieu huy'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode='XK' then 'Xuat khac'
										   when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode='ROH_BG_WH'/* and  MWIOH.linecode='BG'*/ then 'Xuat BG'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD') then'Xuat san xuat' 
										  when   MWIOH.SourceMaterialWarehouseCode='HOLDING_VN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH'  then 'Holding_Back'
										   when  MWIOH.SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode='HOLDING_VN_WH'  then 'To_Holding'
										  when  WarehouseInOutCode='I' and TargetMaterialWarehouseCode='ROH_VN_WH' /*and MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD' )*/ then 'Nhap Lai Tu SanXuat' 
											when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_BG_WH'  and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH'  then 'Nhap lai tu BG'
										  when  SourceMaterialWarehouseCode<>TargetMaterialWarehouseCode then 'XUAT_KHO_AO'
										  end as typeOut 
						
									  ,ProcessedLotID
									  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
									  ,MWIOH.CreateDateTime  AS RequestDateTime				 
									 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
									 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
									 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 									 , MDLI.CurrentQty              AS OutQty                                 -- 불출수량							   					
									 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
									 , MDLI.CurrentQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)		
									 ,MWIOH.CreateDateTime		   AS OutDate   
									 , MM.BasicCostPrice AS BasicCostPrice       

						FROM            STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
										  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
										  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
														AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
										  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)  --( 
													
													 ON MWIOH.LotID = MDLI.LotID 
										  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
										  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
										  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
								 WHERE 1=1	   
								   And ( MWIOH.CompanyCode = 'VVT') 
								   --And (MWIOH.WorkCenterCode = 'VVT_F1') 
								   and  /*(isnull(MWIOH.ProcessedLotID,'') <> '' or*/ (MWIOH.SourceMaterialWarehouseCode = 'HOLDING_VN_WH' or MWIOH.TargetMaterialWarehouseCode = 'HOLDING_VN_WH') 
								   --and  MWIOH.CreateDateTime between @FromDate and @ToDate
								   --And MWIOH.LotID NOT IN ( 
											--							   SELECT LotID 
											--								FROM STB_MaterialDocLotInfo 
											--							   WHERE MaterialLocationCode LIKE 'ROUTE_%' 
											--						    ) 
			),
			getExportMaterialCode as(
				select  a1.materialcode, a1.materialName,a1.MMExtText03 as NameHQ,a1.MMExtText04 as CodeHQ,a1.MaterialUnit,
						(isnull(a6.FirstInventory,0) ) as openninginventory,
						 NhapDauKy,
		
			-- Nhap lai tu BG
						case when a3.outdate < @FromDate and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuyDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhacDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Xuat BG' then isnull(a3.OutQty,0) end as XuatBGDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuatDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuatDauKy,
						case when a3.outdate < @FromDate and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO_DAU_KY,
						case when a3.outdate < @FromDate and typeOut = 'Nhap lai tu BG' then isnull(a3.OutQty,0) end as NhaplaiBGdauky,
						 NhapDauKy1,
						 NhapTrongKy,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat BG' then isnull(a3.OutQty,0) end as XuatBG1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO1,
						case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Nhap lai tu BG' then isnull(a3.OutQty,0) end as NhaplaiBG1,


						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'To_Holding'   then isnull(a3.OutQty,0) end as To_Holding,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Holding_Back' then isnull(a3.OutQty,0) end as Holding_Back,

						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat BG' then isnull(a3.OutQty,0) end as XuatBG,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Nhap lai tu BG' then isnull(a3.OutQty,0) end as NhaplaiBG
		
				from STB_MaterialMaster a1 
				left join table1 a2 on a1.MaterialCode = a2.materialcode
				left join table2 a3 on a1.MaterialCode = a3.MaterialCode 
				left join InventoryMaterial A6 on a1.materialcode = A6.MaterialCode
							
			),
			CalculatorInventoryMaterial as (
			
				select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
				case  when @FromDate = '2023-01-01 10:00:00' /*or @FromDate = '2023-01-01'*/ then COALESCE(max(openninginventory),0)
					  when  @FromDate > '2023-01-01 10:00:00' /*or @FromDate > '2023-01-01'*/ then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+COALESCE(sum(NhaplaiBG1),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0)- COALESCE(sum(XuatBG1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0)  /*- COALESCE(sum(XUAT_KHO_AO),0)*/
					  else 
						COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*- coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
					  end
					  as TonDauKy,
				-- 253460.00000 +
				COALESCE(max(NhapTrongKy),0) as TongNhap,
				COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
				COALESCE(sum(TaiXuat),0) as TaiXuat,
				COALESCE(sum(XUAT_KHO_AO),0) as XUAT_KHO_AO,
				COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
				COALESCE(sum(XuatKhac),0) as XuatKhac,
				COALESCE(sum(XuatBG),0) as XuatBG,
				COALESCE(sum(Holding_Back),0) as Holding_Back,
				COALESCE(sum(To_Holding),0) as To_Holding,
				COALESCE(sum(NhaplaiBG),0) as NhaplaiBG,
				 max(NhapDauKy1) as NhapDauKy1,

				COALESCE(sum(TaiXuatDauKy),0) as  TaiXuatDauKy,
				--COALESCE(sum(TaiXuatDauKy1),0) as  TaiXuatDauKy1,
				COALESCE(sum(XuatTieuHuy1),0) as  XuatTieuHuy1,
				COALESCE(sum(XuatKhac1),0) as XuatKhac1,
				COALESCE(sum(XuatBG1),0) as XuatBG1,
				COALESCE(sum(XuatSanXuat1),0) as   XuatSanXuat1,
				COALESCE(sum(TaiXuat1),0) as TaiXuat1,
				COALESCE(sum(XUAT_KHO_AO1),0) as  XUAT_KHO_AO1,
				COALESCE(sum(NhaplaiBG1),0) as NhaplaiBG1,
 

				case  when @FromDate = '2023-01-01 10:00:00' then COALESCE(max(openninginventory),0) +COALESCE(max(NhapTrongKy),0) +COALESCE(sum(NhaplaiBG),0)/*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0)-COALESCE(sum(XuatBG),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
					  when  @FromDate > '2023-01-01 10:00:00'  then 
					  COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+COALESCE(max(NhaplaiBG1),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0)- COALESCE(sum(XuatBG1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/	  
					  +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) -COALESCE(sum(XuatBG),0)- COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
					  else 
						COALESCE(max(NhapDauKy),0)+COALESCE(max(NhaplaiBG),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*-coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
									 +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0)-COALESCE(sum(XuatBG),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0) */
					  end
					  as TonCuoi 					 
				from getExportMaterialCode AA
							group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
						
			)

			select * from CalculatorInventoryMaterial BB
				where (TonDauKy > 0 or TongNhap > 0 or XuatTieuHuy > 0 or xuatsanxuat > 0 or XuatKhac > 0 or XuatBG > 0 or XuatSanXuat > 0 or TaiXuat > 0 or XUAT_KHO_AO > 0 or Holding_Back > 0  ) 

 


end

else if(@FromDate>='2025-03-01') begin
		print 'b'
			;with
			InventoryMaterial as( -- tồn đầu kì được kiểm kê đầu năm 2023
				select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock) where [Period]='2025-03-01' and workcentercode='VVT_F3'
			),
			InputMaterialCode as ( -- lấy ra nhập vào kho nvl
					select  (case when mli.materialcode<> mm.MaterialCode then mli.materialcode else mm.MaterialCode end) MaterialCode
					  , mm.materialName, mm.MMExtText03 as NameHQ, mm.MMExtText04 as CodeHQ ,  --mm.MaterialUnit,
					(case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime 
					else mdi.CreateDateTime 
					end) basicdate,

							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime
					else mdi.CreateDateTime 
					end)  < @FromDate  then StockQty  end as NhapDauKy,


							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime
					else mdi.CreateDateTime
					end)  between '2025-03-01 10:00:00' and @daten   then StockQty  end as NhapDauKy1,


							case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
					then mli.CreateDateTime 
					else mdi.CreateDateTime 
					end)  between  @FromDate and @ToDate   then StockQty end as NhapTrongKy


							from STB_MaterialMaster  mm WITH(NOLOCK)
							left join STB_MaterialDocDetail mdt WITH(NOLOCK) ON mm.MaterialCode = mdt.MaterialCode
							left join STB_MaterialDocInfo mdi WITH(NOLOCK) ON  mdt.MaterialDocNo = mdi.MaterialDocNo
							left join STB_MaterialDocLotInfo mli WITH(NOLOCK) on  mdt.MaterialDocDetailNo = mli.MaterialDocDetailNo
							left join STB_MaterialLotInfo mli1 WITH(NOLOCK) on  mli.LotID = mli1.LotID
							left join STB_UserInfo ui WITH(NOLOCK) on mli.createUserid = ui.UserID
					where   mdi.TargetCompanyCode='VVT' --and mdi.TargetWorkCenterCode='VVT_F1' 
					and		mdi.materialDocType='GR' and mdi.materialdoctypecode in ('GR_NORMAL','GR_RETURN_MATERIAL') and mdi.docstatus in ('FIX','FINISH','ARRIVAL')
				--	and		mli.MaterialLocationCode in ('ROH_VN_WH_01')
					and		ui.Workcentercode ='VVT_F3'
			),
			 table1  as (
				select MaterialCode, NameHQ, CodeHQ , 
				sum(NhapDauKy) as NhapDauKy, sum(NhapDauKy1) as NhapDauKy1, sum(NhapTrongKy) as NhapTrongKy from InputMaterialCode 
				group by materialcode, namehq, codehq
			)
			, table2 as -- lấy ra nhập xuất khỏi kho nvl
			(
					SELECT						
									  MaterialWarehouseInOutHistNo
									  ,WarehouseInOutCode
									    ,MWIOH.WorkCenterCode
									  ,BC.Description                               AS WarehouseInOutName
									  ,SourceMaterialWarehouseCode
									  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
									  ,TargetMaterialWarehouseCode
									  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
									  ,MWIOH.LotID				  
									  , MM.MaterialCode						 
									  ,MM.MaterialName
									  ,MWIOH.WorkerCode
									  ,PWI.WorkerName
									  ,MWIOH.LineCode
									 ,LI.LineName, 
									 case 
										  when   MWIOH.SourceMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH') and MWIOH.TargetMaterialWarehouseCode in ('NUOC_NGOAI_HN','NOI_DIA_HN')	and MWIOH.linecode in ('TVNCC_HN')	then 'Tralaincc' -- trả lại nhà cc

										  when   MWIOH.SourceMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH') and MWIOH.TargetMaterialWarehouseCode='NG_RAW_HN_WH' and MWIOH.linecode in ('XTH_HN')   then 'XuatTieuHuy' -- xuất tiêu hủy

										  when   MWIOH.SourceMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH') and MWIOH.TargetMaterialWarehouseCode='ROH_WH'		and MWIOH.linecode in ('R-KR_HN')		then 'ReturnVinatech' -- trả lại công ty mẹ
										
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH')   and MWIOH.TargetMaterialWarehouseCode='ROUTE_HN_WH' and  MWIOH.linecode='XK_HN' then 'Xuat khac'
										
										  when WarehouseInOutCode='O' 
										  and SourceMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH')  
										  and MWIOH.TargetMaterialWarehouseCode IN ('ROUTE_HN_WH','MODULE_HN_WH')    
										  and MWIOH.linecode not in ('R-KR_HN','XCDMDSD_HN','XTH_HN','XK_HN','KVHD_HN','TVNCC_HN','SLITTING')
										  then'Xuat san xuat'

										  when WarehouseInOutCode='O'
										  and MWIOH.SourceMaterialWarehouseCode='ROH_HN_WH'
										  and MWIOH.TargetMaterialWarehouseCode='SLITTING_HN_WH'
										  and MWIOH.linecode ='SLITTING'
										  then 'Xuat SLITTING'

										  when   MWIOH.SourceMaterialWarehouseCode='HOLDING_HN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_HN_WH'  then 'Holding_Back'

										  when  MWIOH.SourceMaterialWarehouseCode='ROH_HN_WH' and MWIOH.TargetMaterialWarehouseCode='HOLDING_HN_WH'  then 'To_Holding'

										  when  WarehouseInOutCode='I' 
										  and TargetMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH') 
										  and (MWIOH.SourceMaterialWarehouseCode<>'HOLDING_HN_WH' OR MWIOH.SourceMaterialWarehouseCode<>'SLITTING_HN_WH')
										 and MWIOH.linecode <> 'SLITTING' 
										  then 'Nhap Lai Tu SanXuat' 

										  
										
										   
										  --when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode not in ('HOLDING_VN_WH') then 'Xuat_khac'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode<>TargetMaterialWarehouseCode then 'XUAT_KHO_AO'
										  else 'XuatSai'
										  end as typeOut 
						
									  ,ProcessedLotID
									  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
									  ,MWIOH.CreateDateTime  AS RequestDateTime				 
									 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
									 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
									 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 									 ,coalesce(MWIOH.ActualExportQuantity, MDLI.CurrentQty)              AS OutQty                                 -- 불출수량							   					
									 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
									 , coalesce(MWIOH.ActualExportQuantity, MDLI.CurrentQty) * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)		
									 , MWIOH.CreateDateTime		   AS OutDate   
									 , MM.BasicCostPrice AS BasicCostPrice       

						FROM            STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
										  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
										  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
														AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
										  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)   ON MWIOH.LotID = MDLI.LotID 
										--LEFT OUTER JOIN  STB_MaterialDocLotInfo  MLI  with(nolock)    ON MWIOH.LotID = MLI.LotID 
										  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
										  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
										  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
								 WHERE 1=1	   
								   And ( MWIOH.CompanyCode = 'VVT') 
								   And (MWIOH.WorkCenterCode = 'VVT_F3') 
								   and  (isnull(MWIOH.ProcessedLotID,'') <> '') --or MWIOH.SourceMaterialWarehouseCode = 'HOLDING_VN_WH' or MWIOH.TargetMaterialWarehouseCode = 'HOLDING_VN_WH') 
								   and  MWIOH.CreateDateTime >= '2025-03-01 10:00:00'
							union all 	

					SELECT						
									  MaterialWarehouseInOutHistNo
									  ,WarehouseInOutCode
									  ,MWIOH.WorkCenterCode
									  ,BC.Description                               AS WarehouseInOutName
									  ,SourceMaterialWarehouseCode
									  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
									  ,TargetMaterialWarehouseCode
									  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
									  ,MWIOH.LotID				  
									  , MM.MaterialCode						 
									  ,MM.MaterialName
									  ,MWIOH.WorkerCode
									  ,PWI.WorkerName
									  ,MWIOH.LineCode
									 ,LI.LineName, 
									 case 
										 
										  when WarehouseInOutCode='I' 
										  and SourceMaterialWarehouseCode in ('SLITTING_HN_WH')  
										  and TargetMaterialWarehouseCode in ('ROH_HN_WH','HOLDING_HN_WH') 
										  and MWIOH.linecode ='SLITTING'
										   then 'Nhap lai tu SLITTING'
										  --when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode not in ('HOLDING_VN_WH') then 'Xuat_khac'
										 end as typeOut 
						
									  ,ProcessedLotID
									  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
									  ,MWIOH.CreateDateTime  AS RequestDateTime				 
									 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
									 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
									 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 									 , coalesce(MWIOH.ActualExportQuantity, MDLI.CurrentQty)              AS OutQty                                 -- 불출수량							   					
									 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
									 , coalesce(MWIOH.ActualExportQuantity, MDLI.CurrentQty) * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)		
									 , MWIOH.CreateDateTime		   AS OutDate   
									 , MM.BasicCostPrice AS BasicCostPrice       

						FROM            STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
										  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
										  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
														AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
										  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)   ON MWIOH.LotID = MDLI.LotID 
										   -- LEFT OUTER JOIN  STB_MaterialDocLotInfo  MLI  with(nolock)   ON MWIOH.LotID = MLI.LotID 
										  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
										  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
										  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
								 WHERE 1=1	   
								   And ( MWIOH.CompanyCode = 'VVT') 
								   And (MWIOH.WorkCenterCode = 'VVT_F3') 
								   and MWIOH.SourceMaterialWarehouseCode = 'SLITTING_HN_WH' 
								   and MWIOH.TargetMaterialWarehouseCode = 'ROH_HN_WH' 
								   and  MWIOH.CreateDateTime >= '2025-03-01 10:00:00'
								   and  WarehouseInOutCode='I' 

			),
			getExportMaterialCode as(
				select  a1.materialcode, a1.materialName,a1.MMExtText03 as NameHQ,a1.MMExtText04 as CodeHQ,a1.MaterialUnit,
						(a6.FirstInventory ) as openninginventory,
						-- Tralaincc XuatTieuHuy ReturnVinatech Xuat khac  Xuat san xuat Xuat   'Nhap Lai Tu SanXuat' 'Nhap lai tu BG' XUAT_KHO_AO

						-- Tính toán số lượng đầu kỳ thường là tìm kiếm trước 2024-12-05 mới dùng đến
						 NhapDauKy,
						/*case when a3.outdate < @FromDate and typeOut = 'Tralaincc' then isnull(a3.OutQty,0) end as TralainccDauKy,
						case when a3.outdate < @FromDate and typeOut = 'XuatTieuHuy' then isnull(a3.OutQty,0) end as XuatTieuHuyDauKy,
						case when a3.outdate < @FromDate and typeOut = 'ReturnVinatech' then isnull(a3.OutQty,0) end as ReturnVinatechDAUKY,
						case when a3.outdate < @FromDate and typeOut = 'Xuat BG' then isnull(a3.OutQty,0) end as XuatBGDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuatDauKy,
						case when a3.outdate < @FromDate and typeOut = 'Nhap lai tu BG' then isnull(a3.OutQty,0) end as NhaplaiBGdauky,
						*/
						-- Các tính toán từ 2023-12-05 -> đến ngày bắt đầu tìm kiếm
						 NhapDauKy1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'Tralaincc' then isnull(a3.OutQty,0) end as Tralaincc1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten  and typeOut = 'XuatTieuHuy' then isnull(a3.OutQty,0) end as XuatTieuHuy1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten  and typeOut = 'ReturnVinatech' then isnull(a3.OutQty,0) end as ReturnVinatech1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten  and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as Xuat_khac1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'Xuat SLITTING' then isnull(a3.OutQty,0) end as XuatSLITTING1,
						--case when a3.outdate between '2023-12-03 10:00:00' and @daten  and typeOut = 'To_Holding' then isnull(a3.OutQty,0) end as To_Holding1,
						--case when a3.outdate between '2023-12-03 10:00:00' and @daten and typeOut = 'Holding_Back' then isnull(a3.OutQty,0) end as Holding_Back1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'Nhap Lai Tu SanXuat' then isnull(a3.OutQty,0) end as NhaplaiSX1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'Nhap lai tu SLITTING' then isnull(a3.OutQty,0) end as NhaplaiSLITTING1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO1,
						case when a3.outdate between '2025-03-01 10:00:00' and @daten and typeOut = 'XuatSai' then isnull(a3.OutQty,0) end as XuatSai1,
						-- Các tính toán trong kì tìm kiếm
						NhapTrongKy,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Tralaincc' then isnull(a3.OutQty,0) end as Tralaincc,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XuatTieuHuy' then isnull(a3.OutQty,0) end as XuatTieuHuy,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'ReturnVinatech' then isnull(a3.OutQty,0) end as ReturnVinatech,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as Xuat_khac,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat SLITTING' then isnull(a3.OutQty,0) end as XuatSLITTING,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Nhap Lai Tu SanXuat' then isnull(a3.OutQty,0) end as NhaplaiSX,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Nhap lai tu SLITTING' then isnull(a3.OutQty,0) end as NhaplaiSLITTING,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO,
						case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XuatSai' then isnull(a3.OutQty,0) end as XuatSai

				from STB_MaterialMaster a1 
				left join table1 a2 on a1.MaterialCode = a2.materialcode
				left join table2 a3 on a1.MaterialCode = a3.MaterialCode 
				left join InventoryMaterial A6 on a1.materialcode = A6.MaterialCode
							
			),
			CalculatorInventoryMaterial as (
			
				select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
				case  when @FromDate = '2025-03-01 10:00:00'  then COALESCE(max(openninginventory),0)
					  when  @FromDate > '2025-03-01 10:00:00'  
					  then 
						COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+COALESCE(sum(NhaplaiSLITTING1),0) +COALESCE(sum(NhaplaiSX1),0) 
						- COALESCE(sum(Tralaincc1),0) - COALESCE(sum(XuatTieuHuy1),0)  - COALESCE(sum(ReturnVinatech1),0) - COALESCE(sum(Xuat_khac1),0)  
						- COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(XuatSLITTING1),0)  - COALESCE(sum(XUAT_KHO_AO1),0)
					  else 
							N'2025-03-01'
					  end
					  as TonDauKy,
				-- Tổng số lượng trong kỳ tìm kiếm

				COALESCE(max(NhapTrongKy),0) as NhapTrongKy,
				COALESCE(sum(Tralaincc),0) as Tralaincc,
				COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
				COALESCE(sum(ReturnVinatech),0) as ReturnVinatech,
				COALESCE(sum(Xuat_khac),0) as Xuat_khac,
				COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
				COALESCE(sum(XuatSLITTING),0) as XuatSLITTING,
				COALESCE(sum(NhaplaiSX),0) as NhaplaiSX,
				COALESCE(sum(NhaplaiSLITTING),0) as NhaplaiSLITTING,
				COALESCE(sum(XUAT_KHO_AO),0) as XUAT_KHO_AO,

				--Tổng số lượng trước kỳ tính từ 2024-12-05

				COALESCE(max(NhapDauKy1),0) as NhapDauKy1,
				COALESCE(sum(Tralaincc1),0) as Tralaincc1,
				COALESCE(sum(XuatTieuHuy1),0) as XuatTieuHuy1,
				COALESCE(sum(ReturnVinatech1),0) as ReturnVinatech1,
				COALESCE(sum(Xuat_khac1),0) as Xuat_khac1,
				COALESCE(sum(XuatSanXuat1),0) as XuatSanXuat1,
				COALESCE(sum(XuatSLITTING1),0) as XuatSLITTING1,
				COALESCE(sum(NhaplaiSX1),0) as NhaplaiSX1,
				COALESCE(sum(NhaplaiSLITTING1),0) as NhaplaiSLITTING1,
				COALESCE(sum(XUAT_KHO_AO1),0) as XUAT_KHO_AO1,
 

				case  when @FromDate = '2025-03-01 10:00:00' then COALESCE(max(openninginventory),0) +COALESCE(max(NhapTrongKy),0) +COALESCE(sum(NhaplaiSLITTING),0)  +COALESCE(sum(NhaplaiSX),0) 
				-COALESCE(sum(XuatSLITTING),0) - COALESCE(sum(XuatSanXuat),0)
					  when  @FromDate > '2025-01-01 10:00:00'  then 
						COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+COALESCE(sum(NhaplaiSLITTING1),0) +COALESCE(sum(NhaplaiSX1),0) 
						+COALESCE(max(NhapTrongKy),0)+COALESCE(sum(NhaplaiSLITTING),0) +COALESCE(sum(NhaplaiSX),0) 
						- COALESCE(sum(Tralaincc1),0) - COALESCE(sum(XuatTieuHuy1),0)  - COALESCE(sum(ReturnVinatech1),0) - COALESCE(sum(Xuat_khac1),0)  
						- COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(XuatSLITTING1),0)  - COALESCE(sum(XUAT_KHO_AO1),0)
						- COALESCE(sum(Tralaincc),0) - COALESCE(sum(XuatTieuHuy),0)  - COALESCE(sum(ReturnVinatech),0) - COALESCE(sum(Xuat_khac),0)  
						- COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(XuatSLITTING),0)  - COALESCE(sum(XUAT_KHO_AO),0)
					  else 
						N'2025-03-01'
					  end
					  as TonCuoi 					 
				from getExportMaterialCode AA
							group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
						
			)

			select * from CalculatorInventoryMaterial BB
				where (TonDauKy > 0 or NhapTrongKy > 0  or xuatsanxuat > 0 or XuatSLITTING > 0 or NhaplaiSLITTING > 0 or TonCuoi>0  ) 

 


end

else



		begin 

			;with table1  as (
			select MaterialCode, --MaterialName, 
			NameHQ, CodeHQ , --MaterialUnit, 
			sum(NhapDauKy) as NhapDauKy, sum(NhapDauKy1) as NhapDauKy1, sum(NhapDauKy2) as NhapDauKy2, sum(NhapTrongKy) as NhapTrongKy from
			(

			select  (case when mli.materialcode<> mm.MaterialCode then mli.materialcode else mm.MaterialCode end) MaterialCode
			  , mm.materialName, mm.MMExtText03 as NameHQ, mm.MMExtText04 as CodeHQ ,  --mm.MaterialUnit,
			(case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
			then mli.CreateDateTime 
			else mdi.CreateDateTime 
			end) basicdate,

					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
			then mli.CreateDateTime
			else mdi.CreateDateTime 
			end)  < @FromDate  then StockQty  end as NhapDauKy,


					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
			then mli.CreateDateTime
			else mdi.CreateDateTime
			end)  between '2022-01-01 10:00:00' and @daten   then StockQty  end as NhapDauKy1,

			0 as NhapDauKy2,

					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
			then mli.CreateDateTime 
			else mdi.CreateDateTime 
			end)  between  @FromDate and @ToDate   then StockQty end as NhapTrongKy



					from STB_MaterialMaster  mm WITH(NOLOCK)
					left join STB_MaterialDocDetail mdt WITH(NOLOCK) ON mm.MaterialCode = mdt.MaterialCode
					left join STB_MaterialDocInfo mdi WITH(NOLOCK) ON  mdt.MaterialDocNo = mdi.MaterialDocNo
					left join STB_MaterialDocLotInfo mli WITH(NOLOCK) on  mdt.MaterialDocDetailNo = mli.MaterialDocDetailNo
					left join STB_MaterialLotInfo mli1 WITH(NOLOCK) on  mli.LotID = mli1.LotID
			where   mdi.TargetCompanyCode='VVT' --and mdi.TargetWorkCenterCode='VVT_F1' 
			and
					mdi.materialDocType='GR' and mdi.materialdoctypecode in ('GR_NORMAL','GR_RETURN_MATERIAL') and mdi.docstatus in ('FIX','FINISH','ARRIVAL')
	
					) 
					NN
					group by materialcode, --materialname, 
					namehq, codehq--, materialunit
					)
		
			, table2 as
			(
			SELECT						
										MaterialWarehouseInOutHistNo
									  ,WarehouseInOutCode
									  ,BC.Description                               AS WarehouseInOutName
									  ,SourceMaterialWarehouseCode
									  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
									  ,TargetMaterialWarehouseCode
									  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
									  ,MWIOH.LotID				  
									 , MM.MaterialCode						 
									  ,MM.MaterialName
									  ,MWIOH.WorkerCode
									  ,PWI.WorkerName
									  ,MWIOH.LineCode
									 ,LI.LineName, 
									 case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode='R-KR' then 'Tai Xuat'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode  in ('XCDMDSD','XTH') then 'Xuat chuyen doi, tieu huy'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode='XK' then 'Xuat khac'
										  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD') then'Xuat san xuat' 
										  when   MWIOH.SourceMaterialWarehouseCode='HOLDING_VN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH'  then 'Holding_Back'
										   when  MWIOH.SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode='HOLDING_VN_WH'  then 'To_Holding'
										  when  WarehouseInOutCode='I' and TargetMaterialWarehouseCode='ROH_VN_WH' /*and MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD' )*/ then 'Nhap Lai Tu SanXuat' 
							  
										  else  'XUAT_KHO_AO'
										  end as typeOut 
						
									  ,ProcessedLotID
									  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
									  ,MWIOH.CreateDateTime  AS RequestDateTime				 
									 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
									 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
									 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 									 , MDLI.CurrentQty              AS OutQty                                 -- 불출수량							   					
									 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
									 , MDLI.CurrentQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)		
						 
									 --, Case When datepart(hour,MWIOH.CreateDateTime)  < 10
										--	then Convert(Varchar(10), DateAdd(Day, -1,  MWIOH.CreateDateTime), 120)                
				   --                            Else   Convert(Varchar(10),    MWIOH.CreateDateTime,   120)  End  
									,MWIOH.CreateDateTime			   AS OutDate   
									, MM.BasicCostPrice AS BasicCostPrice       

			  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
										  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
										  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
										  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
														AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
										  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)
													 ON MWIOH.LotID = MDLI.LotID 
										  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
										  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
										  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
								 WHERE 1=1	   
								   And ( MWIOH.CompanyCode = 'VVT') 
								   And (MWIOH.WorkCenterCode = 'VVT_F1') 
								   and  (isnull(MWIOH.ProcessedLotID,'') <> '' or MWIOH.SourceMaterialWarehouseCode = 'HOLDING_VN_WH' or MWIOH.TargetMaterialWarehouseCode = 'HOLDING_VN_WH') 
					
			)


			select * from (
			select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
			case  when @FromDate = '2022-01-01 10:00:00'  then COALESCE(max(openninginventory),0)
				  when  @FromDate > '2022-01-01 10:00:00'  then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+ COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0)   - COALESCE(sum(TaiXuat1),0) /*- COALESCE(sum(XUAT_KHO_AO),0)*/
								 else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*- coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
								 end
								 as TonDauKy,

			COALESCE(max(NhapTrongKy),0) as TongNhap,
			COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
			COALESCE(sum(TaiXuat),0) as TaiXuat,
			COALESCE(sum(XUAT_KHO_AO),0) as XUAT_KHO_AO,
			COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
			COALESCE(sum(XuatKhac),0) as XuatKhac,
			COALESCE(sum(Holding_Back),0) as Holding_Back,
			COALESCE(sum(To_Holding),0) as To_Holding,



			COALESCE(sum(XuatTieuHuy1),0) as  XuatTieuHuy1,
			COALESCE(sum(XuatKhac1),0) as XuatKhac1,
			COALESCE(sum(XuatSanXuat1),0) as   XuatSanXuat1,
			COALESCE(sum(TaiXuat1),0) as TaiXuat1,
			COALESCE(sum(XUAT_KHO_AO1),0) as  XUAT_KHO_AO1,



			case  when @FromDate = '2022-01-01 10:00:00' then COALESCE(max(openninginventory),0) +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/ 
				  when  @FromDate > '2022-01-01 10:00:00'  then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0) + COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/	  +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
				  else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*-coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
								 +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0) */
								 end
								 as TonCuoi 					 
			from
			(select  a1.materialcode, a1.materialName,a1.MMExtText03 as NameHQ,a1.MMExtText04 as CodeHQ,a1.MaterialUnit,
					(a6.FirstInventory ) as openninginventory,
					 NhapDauKy,
		

					case when a3.outdate < @FromDate and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuyDauKy,
					case when a3.outdate < @FromDate and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhacDauKy,
					case when a3.outdate < @FromDate and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuatDauKy,
					case when a3.outdate < @FromDate and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuatDauKy,
					case when a3.outdate < @FromDate and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO_DAU_KY,
					 NhapDauKy1,
					 NhapDauKy2,
					 NhapTrongKy,
					case when a3.outdate between '2022-01-01 10:00:00' and @daten  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy1,
					case when a3.outdate between '2022-01-01 10:00:00' and @daten and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac1,
					case when a3.outdate between '2022-01-01 10:00:00' and @daten and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat1,
					case when a3.outdate between '2022-01-01 10:00:00' and @daten  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat1,
					case when a3.outdate between '2022-01-01 10:00:00' and @daten  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO1,
		
					0 as XuatTieuHuy2,
					0 as XuatKhac2,
					0 as XuatSanXuat2,
					0 as TaiXuat2,
					0 as XUAT_KHO_AO2,

					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'To_Holding'   then isnull(a3.OutQty,0) end as To_Holding,
					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Holding_Back' then isnull(a3.OutQty,0) end as Holding_Back,

					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy,
					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac,
					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat,
					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat,
					case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO
		
			from STB_MaterialMaster a1 
			left join table1 a2 on a1.MaterialCode = a2.materialcode
			left join table2 a3 on a1.MaterialCode = a3.MaterialCode 
			left join (
						select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock) where [Period]='2022-01-01'
						)
							A6 on a1.materialcode = A6.MaterialCode
							)AA
			
						group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
						) BB
			
						where (TonDauKy > 0 or TongNhap > 0 or XuatTieuHuy > 0 or xuatsanxuat > 0 or XuatKhac > 0 or XuatSanXuat > 0 or TaiXuat > 0 or XUAT_KHO_AO > 0 
						or Holding_Back > 0  ) 
						
	end


END

 -- exec usp_MaterialReportTK_new '2024-11-01','2024-11-30'
