-- =============================================
-- Author:		<Ngo Thi Loan>
-- Create date: <2021/05/19>
-- Description:	<Report material Custom>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialReportTK_new_TEST] -- exec usp_MaterialReportTK_new '2023-01-01','2024-01-30'
	---- Add the parameters for the stored procedure here
	@pFromDate date = NULL,
	@pToDate   date = NULL
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
				--where E1.basicdate between @FromDate and @ToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1
				--left join 

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode)

				--A3 
				--ON A1.MaterialCode = A3.MaterialCode
				--left join (select materialcode, sum(suminput) as input
				--from VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @FromDate
				--group by materialcode) A4
				--ON A1.MaterialCode = A4.MaterialCode
				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @FromDate group by materialcode)
				--A5 ON A1.materialcode = A5.MaterialCode

				--UNION

				--select  A4.MaterialCode,A4.MaterialName,A4.MaterialUnit,A4.NameHQ,A4.CodeHQ,COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) as TonDauKy,COALESCE(A1.input,0) as TongNhap, COALESCE(A3.qtyOut,0) as XuatTieuHuy,COALESCE(A3.QtyOutAgain,0) as TaiXuat,
				--COALESCE(A3.QtyOutLine,0) as XuatSanXuat,COALESCE(A3.QtyOther,0) as NhapKhac, COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) + COALESCE(A1.input,0) -COALESCE(A3.qtyOut,0) - COALESCE(A3.QtyOutAgain,0) - COALESCE(A3.QtyOutLine,0) - COALESCE(A3.QtyOther,0)  as TonCuoi
				--from
				-- (select materialcode, materialName,MaterialUnit,NameHQ,CodeHQ, sum(suminput) as input
				--from	VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @FromDate
				--group by materialcode, materialName,MaterialUnit,NameHQ,CodeHQ) A4

				--left join
				--(select E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ, sum(suminput) as input

				--from VW_InTypeE1  E1 WITH(NOLOCK)
				--where E1.basicdate between @FromDate and @ToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1 ON A4.MaterialCode = A1.MaterialCode
				--left join 

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode)

				--A3
				--ON A4.MaterialCode = A3.MaterialCode

				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @FromDate group by materialcode)
				--A5  ON A4.materialcode = A5.MaterialCode


				--UNION
				--select  A4.MaterialCode,A4.MaterialName,A4.MaterialUnit,A4.NameHQ,A4.CodeHQ,COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) as TonDauKy,COALESCE(A1.input,0) as TongNhap, COALESCE(A3.qtyOut,0) as XuatTieuHuy,COALESCE(A3.QtyOutAgain,0) as TaiXuat,
				--COALESCE(A3.QtyOutLine,0) as XuatSanXuat,COALESCE(A3.QtyOther,0) as NhapKhac, COALESCE(A4.input,0) - COALESCE(A5.OutQty,0) + COALESCE(A1.input,0) -COALESCE(A3.qtyOut,0) - COALESCE(A3.QtyOutAgain,0) - COALESCE(A3.QtyOutLine,0) - COALESCE(A3.QtyOther,0)  as TonCuoi
				--from

				--(select materialcode,sum(qtyout) as qtyout, sum(QtyOther) as QtyOther, sum(QtyOutLine) as QtyOutLine, sum(QtyOutAgain) as QtyOutAgain from  ( select materialcode,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut = 'Xuat chuyen doi, tieu huy' then (olh.OutQty) end as qtyout,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut='Xuat khac' then (olh.OutQty) end as QtyOther,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Xuat san xuat' then (olh.OutQty)end as QtyOutLine,
				--case when OLH.outdate between @FromDate and @ToDate and olh.typeOut ='Tai Xuat' then (olh.OutQty)end as QtyOutAgain
				--from VW_OutLineHistory OLH WITH(NOLOCK)
				--)  A2 group by A2.materialcode) A3

				--left join 
				--(select E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ, sum(suminput) as input

				--from VW_InTypeE1  E1 WITH(NOLOCK)
				--where E1.basicdate between @FromDate and @ToDate
				--group by E1.materialcode, E1.materialName,E1.MaterialUnit,E1.NameHQ,E1.CodeHQ) A1 ON A3.MaterialCode = A1.MaterialCode
				--left join
				--(select materialcode, materialName,MaterialUnit,NameHQ,CodeHQ, sum(suminput) as input
				--from	VW_InTypeE1  WITH(NOLOCK)
				--where basicdate < @FromDate
				--group by materialcode, materialName,MaterialUnit,NameHQ,CodeHQ) A4 ON A4.MaterialCode = A3.MaterialCode
				--left join 
				--(select materialcode,sum(OutQty) as OutQty
				--from VW_OutLineHistory OLH WITH(NOLOCK) where  OLH.outdate < @FromDate group by materialcode)
				--A5  ON A3.materialcode = A5.MaterialCode

				--) AL
				--where AL.MaterialCode is not null
				--group by AL.MaterialCode, AL.MaterialName, AL.MaterialUnit, AL.NameHQ, AL.CodeHQ	
							   

declare @FromDate varchar(19) =   convert(varchar(10),@pFromDate,120)               + ' 10:00:00'

declare @ToDate  varchar(19)  =   convert(varchar(10),dateadd(day,1,@pToDate),120)  + ' 10:00:00'

DECLARE @pMaterialWarehouseCode VARCHAR(50) = 'ROH_VN_WH'
DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END

declare @daten varchar(19) = @FromDate

if(@FromDate>='2023-01-01') begin
	
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
end)  between '2023-01-01 10:00:00' and @daten   then StockQty  end as NhapDauKy1,

--		case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
--then convert(varchar(10),mli.CreateDateTime,120)
--else basicdate 
--end)  between '2023-01-01' and @daten   then StockQty  end as NhapDauKy2,

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
						 case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and MWIOH.linecode='R-KR' then 'Tai Xuat'
							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode  in ('XCDMDSD','XTH') then 'Xuat chuyen doi, tieu huy'
							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode='XK' then 'Xuat khac'
						      when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD') then'Xuat san xuat' 
							  when   MWIOH.SourceMaterialWarehouseCode='HOLDING_VN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH'  then 'Holding_Back'
							   when  MWIOH.SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode='HOLDING_VN_WH'  then 'To_Holding'
							  when  WarehouseInOutCode='I' and TargetMaterialWarehouseCode='ROH_VN_WH' /*and MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD' )*/ then 'Nhap Lai Tu SanXuat' 
							  
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
						 
						 --, Case When datepart(hour,MWIOH.CreateDateTime)  < 10
							--	then Convert(Varchar(10), DateAdd(Day, -1,  MWIOH.CreateDateTime), 120)                
       --                            Else   Convert(Varchar(10),    MWIOH.CreateDateTime,   120)  End  
						,MWIOH.CreateDateTime		   AS OutDate   
						, MM.BasicCostPrice AS BasicCostPrice       

  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
											AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)  --( 
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

															--SELECT LotID
														 --	  ,MaterialCode
															--  ,isnull((select max(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID ),MAX(smdli.StockQty)) StockQty   --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														 -- FROM STB_MaterialDocLotInfo  smdli with(nolock)  
														 -- GROUP BY LotID, MaterialCode

														 --UNION ALL

														 --SELECT LotNo
														 --	   ,MAX(smdli.MaterialCode) AS MaterialCode
															--   ,isnull((select MAX(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty  --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														 --FROM STB_MaterialDocLotInfo  smdli with(nolock)  
														 --where LotNo IS NOT NULL  AND LotNo <> ''
														 --GROUP BY LotNo,LotID
														 
														--UNION ALL  

														--SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
														--	,MaterialCode 
														--	,CurrentQty 
														--FROM STB_MaterialLotInfo  with(nolock)  
														--where  MaterialWarehouseCode='HOLDING_VN_WH' 														
														--GROUP BY LotID, MaterialCode, CurrentQty 

														--UNION 

														--	SELECT LotID                    --2022.05.26 add lot detach
														--	,MaterialCode 
														--	,CurrentQty  as StockQty
														--FROM STB_MaterialLotInfo  with(nolock)  
														----where LotID like 'SP%'											
														--GROUP BY LotID, MaterialCode, CurrentQty 

													 --) MDLI 
										 ON MWIOH.LotID = MDLI.LotID 
							  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
					 WHERE 1=1	   
					   And ( MWIOH.CompanyCode = 'VVT') 
					   And (MWIOH.WorkCenterCode = 'VVT_F1') 
					   and  (isnull(MWIOH.ProcessedLotID,'') <> '' or MWIOH.SourceMaterialWarehouseCode = 'HOLDING_VN_WH' or MWIOH.TargetMaterialWarehouseCode = 'HOLDING_VN_WH') 
					   --and  MWIOH.CreateDateTime between @FromDate and @ToDate
					   --And MWIOH.LotID NOT IN ( 
								--							   SELECT LotID 
								--								FROM STB_MaterialDocLotInfo 
								--							   WHERE MaterialLocationCode LIKE 'ROUTE_%' 
								--						    ) 
)


select * from (
select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
case  when @FromDate = '2023-01-01 10:00:00' /*or @FromDate = '2023-01-01'*/ then COALESCE(max(openninginventory),0)
      when  @FromDate > '2023-01-01 10:00:00' /*or @FromDate > '2023-01-01'*/ then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0)+ COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0)  /*- COALESCE(sum(XUAT_KHO_AO),0)*/
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


COALESCE(sum(TaiXuatDauKy),0) as  TaiXuatDauKy,
--COALESCE(sum(TaiXuatDauKy1),0) as  TaiXuatDauKy1,
COALESCE(sum(XuatTieuHuy1),0) as  XuatTieuHuy1,
COALESCE(sum(XuatKhac1),0) as XuatKhac1,
COALESCE(sum(XuatSanXuat1),0) as   XuatSanXuat1,
COALESCE(sum(TaiXuat1),0) as TaiXuat1,
COALESCE(sum(XUAT_KHO_AO1),0) as  XUAT_KHO_AO1,

 

case  when @FromDate = '2023-01-01 10:00:00' then COALESCE(max(openninginventory),0) +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
      when  @FromDate > '2023-01-01 10:00:00'  then COALESCE(max(openninginventory),0) + COALESCE(max(NhapDauKy1),0) + COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/	  +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
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
		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy1,
		case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac1,
		case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat1,
		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat1,
		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO1,

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
			select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock) where [Period]='2023-01-01'
		  )
				A6 on a1.materialcode = A6.MaterialCode
				)AA
			group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
			) BB
			
			where (TonDauKy > 0 or TongNhap > 0 or XuatTieuHuy > 0 or xuatsanxuat > 0 or XuatKhac > 0 or XuatSanXuat > 0 or TaiXuat > 0 or XUAT_KHO_AO > 0 
			or Holding_Back > 0  ) 


-------------------------------------------------------

--;with table1  as (
--select MaterialCode, --MaterialName, 
--NameHQ, CodeHQ , --MaterialUnit, 
--sum(NhapDauKy) as NhapDauKy, sum(NhapDauKy1) as NhapDauKy1, sum(NhapDauKy2) as NhapDauKy2, 
----sum(NhapTrongKy) as NhapTrongKy from
--sum(NhapTrongKy1) as NhapTrongKy from
--(

--SELECT MaterialCode,materialName,NameHQ, CodeHQ,basicdate,NhapDauKy,NhapDauKy1,NhapDauKy2,NhapTrongKy1 FROM (
--		select 
--			DISTINCT mdli.LotID as lotID,
--			(case when mli.materialcode<> mm.MaterialCode then mli.materialcode else mm.MaterialCode end) MaterialCode
--			  , mm.materialName, mm.MMExtText03 as NameHQ, mm.MMExtText04 as CodeHQ ,  --mm.MaterialUnit,
--			(case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
--			then mli.CreateDateTime 
--			else mdi.CreateDateTime 
--			end) basicdate,

--					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
--			then mli.CreateDateTime
--			else mdi.CreateDateTime 
--			end)  < @FromDate  then isnull(MLI.CurrentQty,mdli.StockQty)  end as NhapDauKy,


--					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
--			then mli.CreateDateTime
--			else mdi.CreateDateTime
--			end)  between '2023-01-01 10:00:00' and @daten   then isnull(MLI.CurrentQty,mdli.StockQty)  end as NhapDauKy1,


--			0 as NhapDauKy2,

--					case when (case when mli.LotID is not null and  substring(mli.LotID,3,8) <> replace(convert(varchar(10),mli.CreateDateTime,120),'-','') 
--			then mli.CreateDateTime 
--			else mdi.CreateDateTime 
--			end)  between  @FromDate and @ToDate   then isnull(MLI.CurrentQty,mdli.StockQty) end as NhapTrongKy,
--			isnull(MLI.CurrentQty,mdli.StockQty) as NhapTrongKy1
	
--				from
--				(
--				select  MaterialDocDetailNo,MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,StockQty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
--				from STB_MaterialdocLotInfo  WITH(NOLOCK) 
--				where MaterialLocationCode LIKE @MaterialWarehouseCode+'%'
		
--				union all 
--				select '',MaterialLotNo,lotno,LotID,MaterialLocationCode,MaterialCode,currentqty,LotAttr09,replace(replace(replace(ltrim(rtrim(isnull(LotAttr10,''))),'--','-' ),'--','-' ),' ','' )as LotAttr10
--				from STB_MaterialLotInfo  WITH(NOLOCK) 
--				where lotid like 'SP%' and MaterialWarehouseCode LIKE @MaterialWarehouseCode
--				or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH') then @MaterialWarehouseCode else '' end
		
--				) mdli --with(nolock) 
--				left outer join STB_MaterialLotInfo mli  with(nolock) on   mli.LotID=mdli.LotID
--				left outer join STB_MaterialDocDetail mdd  with(nolock) on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
--				left outer join STB_MaterialDocInfo mdi with(nolock)  on mdd.MaterialDocNo = mdi.MaterialDocNo
--				--left outer join tabletest on mdli.LotID = tabletest.LotID
--				left outer join (
--					select a1.LotID--a1.materialcode as mat,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute, sum(stockqty) as stock,isnull(MDI.SourceCustomerCode,MaterialDocTypeCode) as SourceCustomerCode,cI2.CustomerName
--					from	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)
--					LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 
--					LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo
--					--			left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 

--					 where  
--					 (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and MaterialLocationCode not like 'PROD%'    and  MaterialLocationCode  not like 'ROUTE%'
--									 or MaterialLocationCode like @MaterialWarehouseCode+'%'
--							)
--					and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) where LotID=a1.lotid and materiallotno is not null ) = 0
--					and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0 
--					and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0  
--					and lotid>'ML20191120' and lotid not in ('ML20210630000413','ML20210630000414','ML20220110000007','ML20220110000008','ML20220110000009','ML20220110000010','ML20220110000011','ML20220110000012','ML20211020000127')
--					--group by a1.MaterialCode,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute,MDI.SourceCustomerCode,cI2.CustomerName,MaterialDocTypeCode
--					union all 
--					select lotid from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) 
--					where LotID like 'SP%' and MaterialWarehouseCode=@MaterialWarehouseCode
--					or MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH') then @MaterialWarehouseCode else '' end
--				)tabletest on mdli.LotID = tabletest.LotID

--				left outer join STB_MaterialMaster  mm WITH(NOLOCK)			ON	MdLI.MaterialCode = MM.MaterialCode
--				left join STB_MaterialDocLotInfo mdli1 WITH(NOLOCK) on  mdd.MaterialDocDetailNo = mdli1.MaterialDocDetailNo

--		where  	(MLI.CompanyCode = 'VVT') 		

--				and (@pMaterialWarehouseCode='TOTAL_MATERIALS'    and isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) not like 'PROD%'    and  isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode)  not like 'ROUTE%'
--				or isnull(MLI.MaterialWarehouseCode,mdli.MaterialLocationCode) LIKE @MaterialWarehouseCode+'%') 			
							   
--				and (MaterialDocType<>'GI' or MaterialDocType is null)  
--				or
--				mdli.LotID =  tabletest.LotID  
--				and
--				mdi.materialDocType='GR' and mdi.materialdoctypecode in ('GR_NORMAL','GR_RETURN_MATERIAL') and mdi.docstatus in ('FIX','FINISH','ARRIVAL')
		
		
--		)SS

--				)NN
--		group by  materialcode, --materialname, 
--		namehq, codehq--, materialunit
--		)
-- ,table2 as
--(
--SELECT					



--							MaterialWarehouseInOutHistNo
--						  ,WarehouseInOutCode
--						  ,BC.Description                               AS WarehouseInOutName
--						  ,SourceMaterialWarehouseCode
--						  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
--						  ,TargetMaterialWarehouseCode
--						  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
--						  ,MWIOH.LotID				  
--						 , MM.MaterialCode						 
--						  ,MM.MaterialName
--						  ,MWIOH.WorkerCode
--						  ,PWI.WorkerName
--						  ,MWIOH.LineCode
--						 ,LI.LineName, 
--						 case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and MWIOH.linecode='R-KR' then 'Tai Xuat'
--							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode  in ('XCDMDSD','XTH') then 'Xuat chuyen doi, tieu huy'
--							  when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode='XK' then 'Xuat khac'
--						      when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and  MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD') then'Xuat san xuat' 
--							  when   MWIOH.SourceMaterialWarehouseCode='HOLDING_VN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH'  then 'Holding_Back'
--							   when  MWIOH.SourceMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode='HOLDING_VN_WH'  then 'To_Holding'
--							  when  WarehouseInOutCode='I' and TargetMaterialWarehouseCode='ROH_VN_WH' /*and MWIOH.linecode not in ('R-KR','XCDMDSD','XTH','XK','KVHD' )*/ then 'Nhap Lai Tu SanXuat' 
							  
--							  when  SourceMaterialWarehouseCode<>TargetMaterialWarehouseCode then 'XUAT_KHO_AO'
--							  end as typeOut 
						
--						  ,ProcessedLotID
--						  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
--						  ,MWIOH.CreateDateTime  AS RequestDateTime				 
--						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
--						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
--						 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
-- 						 , MDLI.CurrentQty              AS OutQty                                 -- 불출수량							   					
--						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
--						 , MDLI.CurrentQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)		
						 
--						 --, Case When datepart(hour,MWIOH.CreateDateTime)  < 10
--							--	then Convert(Varchar(10), DateAdd(Day, -1,  MWIOH.CreateDateTime), 120)                
--       --                            Else   Convert(Varchar(10),    MWIOH.CreateDateTime,   120)  End  
--						,MWIOH.CreateDateTime		   AS OutDate   
--						, MM.BasicCostPrice AS BasicCostPrice,
--						MWIOH.SourceMaterialWarehouseCode as check1,
--						 MWIOH.TargetMaterialWarehouseCode as check2,
--						 MW1.MaterialWarehouseCode as check3,
--						 MW2.MaterialWarehouseCode as check4
							    

--  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
--							  LEFT OUTER JOIN STB_MaterialWarehouse MW1	with(nolock)  	         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
--							  LEFT OUTER JOIN STB_MaterialWarehouse MW2	with(nolock)  	         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
--							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	with(nolock)  	                 ON MWIOH.WorkerCode = PWI.WorkerCode
--							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC with(nolock)  	 ON BC.ItemCode = WarehouseInOutCode	
--											AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
--							  LEFT OUTER JOIN  STB_MaterialLotInfo  MDLI  with(nolock)  --( 
--														--SELECT LotID
--														-- 	  ,MaterialCode
--														--	  ,StockQty
--														--  FROM STB_MaterialDocLotInfo
--														-- GROUP BY LotID, MaterialCode, StockQty
--														-- UNION ALL

--														-- SELECT LotNo
--														-- 	   ,MAX(MaterialCode) AS MaterialCode
--														--	   ,MAX(StockQty) AS StockQty
--														-- FROM STB_MaterialDocLotInfo
--														-- WHERE LotNo IS NOT NULL 
--														-- AND LotNo <> ''
--														-- GROUP BY LotNo

--														-- UNION
--														--	SELECT LotID                    --2022.05.26 add lot detach
--														--	,MaterialCode 
--														--	,CurrentQty 
--														--FROM STB_MaterialLotInfo 
--														--where LotID like 'SP%'											
--														--GROUP BY LotID, MaterialCode, CurrentQty 

--															--SELECT LotID
--														 --	  ,MaterialCode
--															--  ,isnull((select max(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID ),MAX(smdli.StockQty)) StockQty   --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
--														 -- FROM STB_MaterialDocLotInfo  smdli with(nolock)  
--														 -- GROUP BY LotID, MaterialCode

--														 --UNION ALL

--														 --SELECT LotNo
--														 --	   ,MAX(smdli.MaterialCode) AS MaterialCode
--															--   ,isnull((select MAX(CurrentQty) from STB_MaterialLotInfo where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty  --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
--														 --FROM STB_MaterialDocLotInfo  smdli with(nolock)  
--														 --where LotNo IS NOT NULL  AND LotNo <> ''
--														 --GROUP BY LotNo,LotID
														 
--														--UNION ALL  

--														--SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
--														--	,MaterialCode 
--														--	,CurrentQty 
--														--FROM STB_MaterialLotInfo  with(nolock)  
--														--where  MaterialWarehouseCode='HOLDING_VN_WH' 														
--														--GROUP BY LotID, MaterialCode, CurrentQty 

--														--UNION 

--														--	SELECT LotID                    --2022.05.26 add lot detach
--														--	,MaterialCode 
--														--	,CurrentQty  as StockQty
--														--FROM STB_MaterialLotInfo  with(nolock)  
--														----where LotID like 'SP%'											
--														--GROUP BY LotID, MaterialCode, CurrentQty 

--													 --) MDLI 
--										 ON MWIOH.LotID = MDLI.LotID 
--							  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
--							  LEFT OUTER JOIN STB_LineInfo LI with(nolock)   ON LI.LineCode = MWIOH.LineCode 
--							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                    
--					 WHERE 1=1
						 	   
--					   And ( MWIOH.CompanyCode = 'VVT') 
--					   And (MWIOH.WorkCenterCode = 'VVT_F1') 
--					   and  (isnull(MWIOH.ProcessedLotID,'') <> '' or MWIOH.SourceMaterialWarehouseCode = 'HOLDING_VN_WH' or MWIOH.TargetMaterialWarehouseCode = 'HOLDING_VN_WH') 
--					   and MDLI.lotid like 'SP%' and MDLI.MaterialWarehouseCode LIKE @MaterialWarehouseCode 
--		--or				MaterialWarehouseCode= case when @MaterialWarehouseCode not in ('ROH_VN_WH','ROUTE_VN_WH') then @MaterialWarehouseCode else '' end
					   
--					   --and  MWIOH.CreateDateTime between @FromDate and @ToDate
--					   --And MWIOH.LotID NOT IN ( 
--								--							   SELECT LotID 
--								--								FROM STB_MaterialDocLotInfo 
--								--							   WHERE MaterialLocationCode LIKE 'ROUTE_%' 
--								--						    ) 

--								--and (SourceMaterialWarehouseCode like ROH)
--)

----select * from table1 a1  

----left outer join table2 a2 on a1.MaterialCode = 		a2.MaterialCode where a1.MaterialCode= 'GBAKAC-054'

--select * from (
--select AA.MaterialCode, AA.MaterialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit,
--case  when @FromDate = '2023-01-01 10:00: 00' /*or @FromDate = '2023-01-01'*/ then COALESCE(max(openninginventory),0)
--      when  @FromDate > '2023-01-01 10:00:00' /*or @FromDate > '2023-01-01'*/ then 
--	  COALESCE(max(openninginventory),0) + 
--	  COALESCE(max(NhapDauKy1),0)+ COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0)  /*- COALESCE(sum(XUAT_KHO_AO),0)*/
--					 else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*- coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
--					 end
--					 as TonDauKy,

--COALESCE(max(NhapTrongKy),0) as TongNhap,
--COALESCE(sum(XuatTieuHuy),0) as XuatTieuHuy,
--COALESCE(sum(TaiXuat),0) as TaiXuat,
--COALESCE(sum(XUAT_KHO_AO),0) as XUAT_KHO_AO,
--COALESCE(sum(XuatSanXuat),0) as XuatSanXuat,
--COALESCE(sum(XuatKhac),0) as XuatKhac,
--COALESCE(sum(Holding_Back),0) as Holding_Back,
--COALESCE(sum(To_Holding),0) as To_Holding,


--COALESCE(sum(TaiXuatDauKy),0) as  TaiXuatDauKy,
----COALESCE(sum(TaiXuatDauKy1),0) as  TaiXuatDauKy1,
--COALESCE(sum(XuatTieuHuy1),0) as  XuatTieuHuy1,
--COALESCE(sum(XuatKhac1),0) as XuatKhac1,
--COALESCE(sum(XuatSanXuat1),0) as   XuatSanXuat1,
--COALESCE(sum(TaiXuat1),0) as TaiXuat1,
--COALESCE(sum(XUAT_KHO_AO1),0) as  XUAT_KHO_AO1,

 

--case  when @FromDate = '2023-01-01 10:00:00' then 
----COALESCE(max(openninginventory),0) +
--COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
--      when  @FromDate > '2023-01-01 10:00:00'  then 
--	  --COALESCE(max(openninginventory),0) +
--	   COALESCE(max(NhapDauKy1),0) + COALESCE(max(NhapDauKy2),0) - COALESCE(sum(XuatTieuHuy1),0) - COALESCE(sum(XuatKhac1),0) - COALESCE(sum(XuatSanXuat1),0) - COALESCE(sum(TaiXuat1),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/	  +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0)*/
--					 else COALESCE(max(NhapDauKy),0) - COALESCE(sum(XuatTieuHuyDauKy),0) - COALESCE(sum(XuatKhacDauKy),0) - COALESCE(sum(XuatSanXuatDauKy),0) - COALESCE(sum(TaiXuatDauKy),0) /*-coalesce(sum(XUAT_KHO_AO_DAU_KY),0) */
--					 +COALESCE(max(NhapTrongKy),0) /*+ COALESCE(sum(Holding_Back),0) - COALESCE(sum(To_Holding),0)*/ -COALESCE(sum(XuatTieuHuy),0) -COALESCE(sum(XuatKhac),0) - COALESCE(sum(XuatSanXuat),0) - COALESCE(sum(TaiXuat),0) /*-  COALESCE(sum(XUAT_KHO_AO),0) */
--					 end
--					 as TonCuoi 					 
--from
--(select  a1.materialcode, a1.materialName,a1.MMExtText03 as NameHQ,a1.MMExtText04 as CodeHQ,a1.MaterialUnit,
--		(a6.FirstInventory ) as openninginventory,
--		 NhapDauKy,
		

--		case when a3.outdate < @FromDate and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuyDauKy,
--		case when a3.outdate < @FromDate and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhacDauKy,
--		case when a3.outdate < @FromDate and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuatDauKy,
--		case when a3.outdate < @FromDate and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuatDauKy,
--		case when a3.outdate < @FromDate and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO_DAU_KY,
--		 NhapDauKy1,
--		 NhapDauKy2,
--		 NhapTrongKy,
--		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy1,
--		case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac1,
--		case when a3.outdate between '2023-01-01 10:00:00' and @daten and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat1,
--		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat1,
--		case when a3.outdate between '2023-01-01 10:00:00' and @daten  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO1,

--		0 as XuatTieuHuy2,
--		0 as XuatKhac2,
--		0 as XuatSanXuat2,
--		0 as TaiXuat2,
--		0 as XUAT_KHO_AO2,

--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'To_Holding'   then isnull(a3.OutQty,0) end as To_Holding,
--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Holding_Back' then isnull(a3.OutQty,0) end as Holding_Back,

--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat chuyen doi, tieu huy' then isnull(a3.OutQty,0) end as XuatTieuHuy,
--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat khac' then isnull(a3.OutQty,0) end as XuatKhac,
--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Xuat san xuat' then isnull(a3.OutQty,0) end as XuatSanXuat,
--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'Tai Xuat' then isnull(a3.OutQty,0) end as TaiXuat,
--		case when a3.outdate between @FromDate and @ToDate  and typeOut = 'XUAT_KHO_AO' then isnull(a3.OutQty,0) end as XUAT_KHO_AO
		
--from STB_MaterialMaster a1 
--left join table1 a2 on a1.MaterialCode = a2.materialcode
--left join table2 a3 on a1.MaterialCode = a3.MaterialCode 
--left join (
--			select materialcode, firstinventory from Stb_InventoryMaterialLiquidation FIM with (nolock) where [Period]='2023-01-01'
--		  )
--				A6 on a1.materialcode = A6.MaterialCode
--				)AA
--			group by AA.materialcode, AA.materialName,AA.NameHQ,AA.CodeHQ,AA.MaterialUnit
--			) BB
			
--			where 
--			Toncuoi>0 and  
--			(TonDauKy > 0 or TongNhap > 0 or XuatTieuHuy > 0 or xuatsanxuat > 0 or XuatKhac > 0 or XuatSanXuat > 0 or TaiXuat > 0 or XUAT_KHO_AO > 0 
--			or Holding_Back > 0  ) 

----------------------------------------------------------------------
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
						 case when WarehouseInOutCode='O' and SourceMaterialWarehouseCode='ROH_VN_WH'  and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' and MWIOH.linecode='R-KR' then 'Tai Xuat'
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

 -- exec usp_MaterialReportTK_new '2023-02-01','2023-03-31'
