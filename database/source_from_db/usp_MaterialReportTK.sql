-- =============================================
-- Author:		<Ngo Thi Loan>
-- Create date: <2021/05/19>
-- Description:	<Report material Custom>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialReportTK] --exec usp_MaterialReportTK '2022-05-01','2022-05-31'
	-- Add the parameters for the stored procedure here
	@pFromDate date=NULL,
	@pToDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
				--select AL.MaterialCode, AL.MaterialName, AL.MaterialUnit, AL.NameHQ, AL.CodeHQ, sum(TonDauKy) as TonDauKy, Sum(TongNhap) as TongNhap, sum(XuatTieuHuy) as XuatTieuHuy, sum(TaiXuat) as TaiXuat, sum(XuatSanXuat) as XuatSanXuat, sum(NhapKhac) as XuatKhac, sum(TonCuoi) as TonCuoi, '' as Description
				--from
				--(
				--select  A1.MaterialCode,A1.MaterialName,A1.MaterialUnit,A1.NameHQ,A1.CodeHQ,COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) as TonDauKy,COALESCE(A1.input,0) as TongNhap, COALESCE(A3.qtyOut,0) as XuatTieuHuy,COALESCE(A3.QtyOutAgain,0) as TaiXuat,
				--COALESCE(A3.QtyOutLine,0) as XuatSanXuat,COALESCE(A3.QtyOther,0) as NhapKhac, COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) + COALESCE(A1.input,0) -COALESCE(A3.qtyOut,0) - COALESCE(A3.QtyOutAgain,0) - COALESCE(A3.QtyOutLine,0) - COALESCE(A3.QtyOther,0)  as TonCuoi
				--from
				--(select E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ, sum(suminput) as input

				--from VW_InTypeE1  E1 WITH(NOLOCK)
				--where E1.basicdate between @pFromDate and @pToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1
				--left join 

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode)

				--A3 
				--ON A1.MaterialCode = A3.MaterialCode
				--left join (select materialcode, sum(suminput) as input
				--from VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @pFromDate
				--group by materialcode) A4
				--ON A1.MaterialCode = A4.MaterialCode
				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @pFromDate group by materialcode)
				--A5 ON A1.materialcode = A5.MaterialCode

				--UNION

				--select  A4.MaterialCode,A4.MaterialName,A4.MaterialUnit,A4.NameHQ,A4.CodeHQ,COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) as TonDauKy,COALESCE(A1.input,0) as TongNhap, COALESCE(A3.qtyOut,0) as XuatTieuHuy,COALESCE(A3.QtyOutAgain,0) as TaiXuat,
				--COALESCE(A3.QtyOutLine,0) as XuatSanXuat,COALESCE(A3.QtyOther,0) as NhapKhac, COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) + COALESCE(A1.input,0) -COALESCE(A3.qtyOut,0) - COALESCE(A3.QtyOutAgain,0) - COALESCE(A3.QtyOutLine,0) - COALESCE(A3.QtyOther,0)  as TonCuoi
				--from
				-- (select materialcode, materialName,MaterialUnit,NameHQ,CodeHQ, sum(suminput) as input
				--from	VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @pFromDate
				--group by materialcode, materialName,MaterialUnit,NameHQ,CodeHQ) A4

				--left join
				--(select E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ, sum(suminput) as input

				--from VW_InTypeE1  E1 WITH(NOLOCK)
				--where E1.basicdate between @pFromDate and @pToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1 ON A4.MaterialCode = A1.MaterialCode
				--left join 

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode)

				--A3
				--ON A4.MaterialCode = A3.MaterialCode

				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @pFromDate group by materialcode)
				--A5  ON A4.materialcode = A5.MaterialCode


				--UNION
				--select  A4.MaterialCode,A4.MaterialName,A4.MaterialUnit,A4.NameHQ,A4.CodeHQ,COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) as TonDauKy,COALESCE(A1.input,0) as TongNhap, COALESCE(A3.qtyOut,0) as XuatTieuHuy,COALESCE(A3.QtyOutAgain,0) as TaiXuat,
				--COALESCE(A3.QtyOutLine,0) as XuatSanXuat,COALESCE(A3.QtyOther,0) as NhapKhac, COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) + COALESCE(A1.input,0) -COALESCE(A3.qtyOut,0) - COALESCE(A3.QtyOutAgain,0) - COALESCE(A3.QtyOutLine,0) - COALESCE(A3.QtyOther,0)  as TonCuoi
				--from

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @pFromDate and @pToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode) A3

				--left join 
				--(select E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ, sum(suminput) as input

				--from VW_InTypeE1  E1 WITH(NOLOCK)
				--where E1.basicdate between @pFromDate and @pToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1 ON A3.MaterialCode = A1.MaterialCode
				--left join
				--(select materialcode, materialName,MaterialUnit,NameHQ,CodeHQ, sum(suminput) as input
				--from	VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @pFromDate
				--group by materialcode, materialName,MaterialUnit,NameHQ,CodeHQ) A4 ON A4.MaterialCode = A3.MaterialCode
				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @pFromDate group by materialcode)
				--A5  ON A3.materialcode = A5.MaterialCode

				--) AL
				--where AL.MaterialCode is not null
				--group by AL.MaterialCode, AL.MaterialName, AL.MaterialUnit, AL.NameHQ, AL.CodeHQ	

declare @daten date = DATEADD(day,-1,@pFromDate)






;with table1  as (
select MaterialCode, MaterialName, NameHQ, CodeHQ , MaterialUnit, sum(NhapDauKy) as NhapDauKy, sum(NhapDauKy1) as NhapDauKy1, sum(NhapTrongKy) as NhapTrongKy from
(
select  mm.materialcode, mm.materialName,mm.MMExtText03 as NameHQ,mm.MMExtText04 as CodeHQ,mm.MaterialUnit,basicdate,
		case when  convert(date,basicdate)  < @pFromDate  then (StockQty) end as NhapDauKy,
		case when convert(date,basicdate)  between '2022-01-01' and @daten   then (StockQty) end as NhapDauKy1,
		case when convert(date,basicdate)  between  @pFromDate and @pToDate   then (StockQty) end as NhapTrongKy
		from STB_MaterialMaster  mm WITH(NOLOCK)
		left join STB_MaterialDocDetail mdt WITH(NOLOCK) ON mm.MaterialCode = mdt.MaterialCode
		left join STB_MaterialDocInfo mdi WITH(NOLOCK) ON  mdt.MaterialDocNo = mdi.MaterialDocNo
		left join STB_MaterialDocLotInfo mli WITH(NOLOCK) on  mdt.MaterialDocDetailNo = mli.MaterialDocDetailNo
where   mdi.TargetCompanyCode='VVT' and mdi.TargetWorkCenterCode='VVT_F1' and
		mdi.materialDocType='GR' and mdi.materialdoctypecode in ('GR_NORMAL','GR_RETURN_MATERIAL') and mdi.docstatus in ('FIX','FINISH','ARRIVAL')
	
		) 
		NN
		group by materialcode, materialname, namehq, codehq, materialunit
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
						  case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.linecode='R-KR' then 'Tai Xuat'
							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and  MWIOH.linecode  in ('XCDMDSD','XTH') then 'Xuat chuyen doi, tieu huy'
							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and  MWIOH.linecode='XK' then 'Xuat khac'
						      when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH' and  MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD') then'Xuat san xuat' 
							  when  WarehouseInOutCode='I' and TargetMaterialWarehouseCode='ROH_VN_WH' and MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD' ) then 'Nhap Lai Tu SanXuat' 
							  end as typeOut
						
						
						  ,ProcessedLotID
						  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
						  ,MWIOH.CreateDateTime  AS RequestDateTime				 
						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
						 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 						 , MDLI.StockQty              AS OutQty                                 -- 불출수량							   					
						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
						 , MDLI.StockQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)					  
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '10:00:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                
                                   Else                                                                                Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   
						, MM.BasicCostPrice AS BasicCostPrice       

  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN ( 
														--SELECT LotID
														-- 	  ,MaterialCode
														--	  ,StockQty
														--  FROM STB_MaterialDocLotInfo
														-- GROUP BY LotID, MaterialCode, StockQty
														-- UNION ALL

														-- SELECT LotNo
														-- 	   ,MAX(MaterialCode) AS MaterialCode
														--	   ,MAX(StockQty) AS StockQty
														-- FROM STB_MaterialDocLotInfo
														-- WHERE LotNo IS NOT NULL 
														-- AND LotNo <> ''
														-- GROUP BY LotNo

														-- UNION
														--	SELECT LotID                    --2022.05.26 add lot detach
														--	,MaterialCode 
														--	,CurrentQty 
														--FROM STB_MaterialLotInfo 
														--where LotID like 'SP%'											
														--GROUP BY LotID, MaterialCode, CurrentQty 

															SELECT LotID
														 	  ,MaterialCode
															  ,isnull((select max(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID ),MAX(smdli.StockQty)) StockQty   --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														  FROM STB_MaterialDocLotInfo  smdli with(nolock)  
														  GROUP BY LotID, MaterialCode

														 UNION ALL

														 SELECT LotNo
														 	   ,MAX(smdli.MaterialCode) AS MaterialCode
															   ,isnull((select MAX(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty  --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														 FROM STB_MaterialDocLotInfo  smdli with(nolock)  
														 where LotNo IS NOT NULL  AND LotNo <> ''
														 GROUP BY LotNo,LotID
														 
														--UNION ALL  

														--SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
														--	,MaterialCode 
														--	,CurrentQty 
														--FROM STB_MaterialLotInfo  with(nolock)  
														--where  MaterialWarehouseCode='HOLDING_VN_WH' 														
														--GROUP BY LotID, MaterialCode, CurrentQty 

														UNION 

															SELECT LotID                    --2022.05.26 add lot detach
															,MaterialCode 
															,CurrentQty 
														FROM STB_MaterialLotInfo  with(nolock)  
														where LotID like 'SP%'											
														GROUP BY LotID, MaterialCode, CurrentQty 


													 ) MDLI ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
					 WHERE 1=1	   
					   And ( MWIOH.CompanyCode = 'VVT')
					   And (MWIOH.WorkCenterCode = 'VVT_F1')
					   And MWIOH.LotID NOT IN ( 
															   SELECT LotID 
																FROM STB_MaterialDocLotInfo 
															   WHERE MaterialLocationCode LIKE 'ROUTE_%'
														    )
)

select * from (
select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
case  when @pFromDate = '2022-01-01' then COALESCE(max(openninginventory),0)
      when  @pFromDate > '2022-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat),0)
					 else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) end
					 as TonDauKy,

COALESCE(max(NhapTrongKy),0) as TongNhap,
COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
COALESCE(sum(TaiXuat),0) as TaiXuat,
COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
COALESCE(sum(XuatKhac),0) as XuatKhac,


case  when @pFromDate = '2022-01-01' then COALESCE(max(openninginventory),0) +COALESCE(max(NhapTrongKy),0) -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0)
      when  @pFromDate > '2022-01-01'  then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat),0) +COALESCE(max(NhapTrongKy),0) -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0)
					 else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) +COALESCE(max(NhapTrongKy),0) -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) end
					 as TonCuoi


from
(select  a1.materialcode, a1.materialName,a1.MMExtText03 as NameHQ,a1.MMExtText04 as CodeHQ,a1.MaterialUnit,
		(a6.FirstInventory) as openninginventory,
		 NhapDauKy,
		case when a3.outdate < @pFromDate and typeOut = 'Xuat chuyen doi, tieu huy' then (a3.OutQty) end as XuatTieuHuyDauKy,
		case when a3.outdate < @pFromDate and typeOut = 'Xuat khac' then (a3.OutQty) end as XuatKhacDauKy,
		case when a3.outdate < @pFromDate and typeOut = 'Xuat san xuat' then (a3.OutQty) end as XuatSanXuatDauKy,
		case when a3.outdate < @pFromDate and typeOut = 'Tai Xuat' then (a3.OutQty) end as TaiXuatDauKy,
		 NhapDauKy1,
		 NhapTrongKy,
		case when a3.outdate between '2022-01-01' and @daten  and typeOut = 'Xuat chuyen doi, tieu huy' then (a3.OutQty) end as XuatTieuHuy1,
		case when a3.outdate between '2022-01-01' and @daten and typeOut = 'Xuat khac' then (a3.OutQty) end as XuatKhac1,
		case when a3.outdate between '2022-01-01' and @daten and typeOut = 'Xuat san xuat' then (a3.OutQty) end as XuatSanXuat1,
		case when a3.outdate between '2022-01-01' and @daten  and typeOut = 'Tai Xuat' then (a3.OutQty) end as TaiXuat1,


		case when a3.outdate between @pFromDate and @pToDate  and typeOut = 'Xuat chuyen doi, tieu huy' then (a3.OutQty) end as XuatTieuHuy,
		case when a3.outdate between @pFromDate and @pToDate and typeOut = 'Xuat khac' then (a3.OutQty) end as XuatKhac,
		case when a3.outdate between @pFromDate and @pToDate and typeOut = 'Xuat san xuat' then (a3.OutQty) end as XuatSanXuat,
		case when a3.outdate between @pFromDate and @pToDate  and typeOut = 'Tai Xuat' then (a3.OutQty) end as TaiXuat


from STB_MaterialMaster a1 left join table1 a2 on a1.MaterialCode = a2.materialcode
left join table2 a3 on a1.MaterialCode = a3.MaterialCode 
left join (select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock))
				A6 on a1.materialcode = A6.MaterialCode
				)AA
			group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
			) BB
			
			where (TonDauKy > 0 or TongNhap > 0 or XuatTieuHuy > 0 or xuatsanxuat > 0 or XuatKhac > 0 or XuatSanXuat > 0 or TaiXuat > 0  ) 
				




END
