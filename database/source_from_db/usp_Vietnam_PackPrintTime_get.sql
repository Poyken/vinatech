
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2020-08-19
-- Browsable : true
-- Modified: Mr.Tung         usp_Vietnam_PackPrintTime_get '','','','2026-03-21','2026-03-21','','','','','VVT_F1'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackPrintTime_get]
    @pProcessUserID VARCHAR(20)= NULL,
	@pProcessLanguage VARCHAR(20)= NULL,
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	SET NOCOUNT ON;

	/*

	/*IF @pWorkCenterCode = 'VVT_F1'

		BEGIN*/
update  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT]
set PackQty = -1*PackQty,EmpNo=EmpNo+'.'
where PackQty>0 
and PackingID in (
 SELECT b.PackingID
  FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] a with(nolock) 
  join  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] b  with(nolock) on a.LotNo = left(b.PackingID,14)
  where a.id>615234
  and b.id>615234
  and a.PackQty>0
  and b.PackQty>0 
  and a.LotNo<>b.LotNo 
  and a.isPrinted>0
  and b.isPrinted>0
)

;with tung as 
		(
	   		SELECT  id,
			(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
			,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty, isPrinted,PartNo,
			(RANK() over (partition by LotNo,isPrinted order by  PackQty desc,printtime desc) ) as RankPackQty,
			(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--,
			  --ISNULL(DRI.PackQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as Price
			FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

			where 1=1 
			 and  EmpNo not in ('test_worker','assy_packing' )
			and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
			and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
			and PackQty>1 --or MaterialName like '%356_%' and PackQty>120)
			and ( isPrinted = 0 or isPrinted = (case when @LotNo is not null and @LotNo<>'*' then 1 else 0 end)  )	
			---and LotNo='VVKQ153R050503'
		)

	 ,
	 tung22 as (
	SELECT  id,
	 newLotno,LotNo,PackingID,a.MaterialCode,MaterialName,EmpNo,PrintTime,
	 PackQty --* (select count(LotNo) from stb_materialLotinfo  WITH(NOLOCK) where LotNo =a.LotNo) as PackQty
	 ,isPrinted,PartNo
	 ,b.InputLineCode,c.ProdDateTime,b.ControlNo,
(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty2
	  FROM tung a WITH(NOLOCK) 
	  join STB_SetInfo b WITH(NOLOCK)  on  (a.LotNo=b.Barcode or a.newLotno=b.Barcode)
	  join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and
	  c.RouteCode= 
	  case 
	  when @pWorkCenterCode = 'VVT_F1'then'V-28'
	  when @pWorkCenterCode = 'VVT_F2'then'V-28_BG'
	  when @pWorkCenterCode = 'VVT_F3'then'VE10'
	  else ''
	  end
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing' )

		and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
		AND (@LineCode = '*' OR InputLineCode   = @LineCode)
		AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)

	 )
	SELECT   DRI.id,
	 newLotno,DRI.LotNo,
	 -- Mr.Triều thay dổi theo yêu cầu của Mr.Dương pả
	
	 --CASE 
	 --    WHEN DRI.LotNo='VVQK273R010628' then 'VVQK273R012628'
		-- WHEN DRI.LotNo='VVQK273R010629' then 'VVQK273R012629'
		-- WHEN DRI.LotNo='VVQK273R010630' then 'VVQK273R012630'
		-- WHEN DRI.LotNo='VVQK273R010631' then 'VVQK273R012631'
		-- WHEN DRI.LotNo='VVQK273R010632' then 'VVQK273R012632'
		-- WHEN DRI.LotNo='VVQK273R010634' then 'VVQK273R012634'
		-- WHEN DRI.LotNo='VVQK273R010635' then 'VVQK273R012635'
		-- else DRI.LotNo
		-- END as LotNo,
		 
	 PackingID,DRI.MaterialCode,
	  case
	   when DRI.MaterialCode='ECVT30-370' then 'HY-CAP VEC3R0387QG (3562-JIANGHAI)'
	  -- when MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' --Ms Phuong request update audit 2025-11-26
		else DRI.MaterialName
		end as MaterialName
	

	 --MaterialName
	 ,EmpNo,PrintTime,PackQty 
	 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
	 , DRI.PartNo
	 , InputLineCode,ProdDateTime,ControlNo,
	   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.PriceV28,0)) /** 1.05*/  as Price,
	   --case này mới đúng đang sửa cho hợp báo cáo bằng case dưới
	   	 --(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				--then     convert(varchar(10),PrintTime,120)    
				--else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
				--end )
			(case  
				when DRI.LotNo in (select * from stb_Changedate_B781_220924)  then '2024-09-05'   
				-- when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
				when   datepart(hour, PrintTime)>=10     -- Duy thay đổi đang lấy thời gian là 8h30 mới tính là ngày mới thì thay đổi là 8h
				then     convert(varchar(10),PrintTime,120)    
				else 
					case 
					when DRI.LotNo in ('VVNU212R750638')
					
					then
				   convert(varchar(10),dateadd(day, 0,  PrintTime),120)  
				   else
				   	convert(varchar(10),dateadd(day, -1,  PrintTime),120)
				   end       
				end )	
				    as  jobdate,
			
			-- Mr.Manh UPDATE 2025-12-19 
			SPQBL.SClass,
			SPQBL.AClass,
			SPQBL.BClass,
			SPQBL.CClass,
			SPQBL.DClass,
			SPQBL.CreateDateTime,
			SPQBL.CreateUserID,
			SPQBL.ChangeDateTime,
			SPQBL.ChangeUserID,
			T10.WorkCenterCode

	  FROM tung22  DRI WITH(NOLOCK) 
--left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode='V-28'
left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and 'V-28' like '%'+vwup.RouteV28+'%'

LEFT OUTER JOIN STB_SavePackingQtyByLevel_VVT SPQBL ON SPQBL.IDSPT = DRI.id
LEFT JOIN STB_ItemCode T10 
	    ON DRI.MaterialCode = T10.MaterialCode 
	  where 1=1 
	   and  EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		and PackQty>1
		and  SUBSTRING (DRI.LotNo, 1, 1) !='M'
		and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )
		
	  order by DRI.LotNo, PrintTime, EmpNo 

	  */

	  --Mr.Triều thay đổi code đê hiên thị tât cả các mã điện cực sử dụng cho con hàng
	    UPDATE [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT]
    SET PackQty = -1 * PackQty, EmpNo = EmpNo + '.'
    WHERE PackQty > 0 
    AND PackingID IN (
        SELECT b.PackingID
        FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] a WITH(NOLOCK) 
        JOIN [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] b WITH(NOLOCK) ON a.LotNo = LEFT(b.PackingID,14)
        WHERE a.id > 615234 AND b.id > 615234 AND a.PackQty > 0 AND b.PackQty > 0 
        AND a.LotNo <> b.LotNo AND a.isPrinted > 0 AND b.isPrinted > 0
    );
    ;WITH tung AS (
        SELECT id,
            (SELECT TOP 1 newbarcode FROM STB_LotChangeMaterialHistory WITH(NOLOCK) WHERE oldBarcode=LotNo) AS newLotno,
            LotNo, PackingID, MaterialCode, MaterialName, EmpNo, PrintTime, PackQty, isPrinted, PartNo,
            (RANK() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RankPackQty,
            (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty
        FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI WITH(NOLOCK) 
        WHERE EmpNo NOT IN ('test_worker','assy_packing')
          AND PrintTime BETWEEN (CASE WHEN @LotNo <> '*' THEN '2020-08-15 10:00:00' ELSE @FromDate END) 
          AND (CASE WHEN @LotNo <> '*' THEN CONVERT(VARCHAR(19), GETDATE(), 120) ELSE @ToDate END) 
          AND PackQty > 1
          AND (isPrinted = 0 OR isPrinted = (CASE WHEN @LotNo <> '*' THEN 1 ELSE 0 END))
    ),
    tung22 AS (
        SELECT a.*, b.InputLineCode, c.ProdDateTime, b.ControlNo,
            (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty2
        FROM tung a WITH(NOLOCK) 
        JOIN STB_SetInfo b WITH(NOLOCK) ON (a.LotNo = b.Barcode OR a.newLotno = b.Barcode)
        JOIN STB_ProdRouteHist c WITH(NOLOCK) ON b.ControlNo = c.ControlNo 
        AND c.RouteCode = CASE 
            WHEN @pWorkCenterCode = 'VVT_F1' THEN 'V-28'
            WHEN @pWorkCenterCode = 'VVT_F2' THEN 'V-28_BG'
            WHEN @pWorkCenterCode = 'VVT_F3' THEN 'VE10'
            ELSE '' END
        WHERE (@LineCode = '*' OR b.InputLineCode = @LineCode)
          AND (@LotNo = '*' OR a.LotNo = @LotNo OR a.newLotno = @LotNo)
          AND a.RowPackQty = 1
    ),
    RawMaterial AS (

        SELECT 
            vvt.LotNo,
            SUBSTRING(MAX(CASE WHEN RW.ProductGroupCode = 'ElectrodeM' THEN RW.RawMaterialBarcode END), 1, 14) AS ElectrodeM_Barcode_Short,
            SUBSTRING(MAX(CASE WHEN RW.ProductGroupCode = 'ElectrodeP' THEN RW.RawMaterialBarcode END), 1, 14) AS ElectrodeP_Barcode_Short
        FROM STB_SavePackingTime_VVT vvt
		LEFT JOIN STB_RawMaterialInputHist RW on vvt.LotNo=RW.Barcode
        WHERE vvt.PrintTime >= @FromDate AND vvt.PrintTime <= @ToDate  
          AND (@LotNo = '*' OR vvt.LotNo = @LotNo)
          AND RW.ProductGroupCode IN ('ElectrodeM', 'ElectrodeP') and PackQty>0
        GROUP BY vvt.LotNo
    ),
    MappedMaterials AS (
        SELECT 
            RM.*,
            SetM.MaterialCode AS ElectrodeM_Code,
            SetP.MaterialCode AS ElectrodeP_Code
        FROM RawMaterial RM
        LEFT JOIN STB_SetInfo SetM WITH(NOLOCK) ON RM.ElectrodeM_Barcode_Short = SetM.Barcode
        LEFT JOIN STB_SetInfo SetP WITH(NOLOCK) ON RM.ElectrodeP_Barcode_Short = SetP.Barcode
    )

    SELECT 
        DRI.id, DRI.newLotno, DRI.LotNo, DRI.PackingID, DRI.MaterialCode,
        CASE WHEN DRI.MaterialCode = 'ECVT30-370' THEN 'HY-CAP VEC3R0387QG (3562-JIANGHAI)' ELSE DRI.MaterialName END AS MaterialName,
        DRI.EmpNo, DRI.PrintTime, DRI.PackQty,
        CASE WHEN isPrinted IS NULL OR isPrinted = 0 THEN 'Hien(show)' ELSE 'An(hide)' END AS isPrinted,
        DRI.PartNo, DRI.InputLineCode, DRI.ProdDateTime, DRI.ControlNo,
        ISNULL(DRI.PackQty, 0) * CONVERT(NUMERIC(38,15), ISNULL(vwup.PriceV28,0)) AS Price,
        (CASE  
            WHEN DRI.LotNo IN (SELECT * FROM stb_Changedate_B781_220924) THEN '2024-09-05'  
            WHEN DATEPART(HOUR, PrintTime) >= 10 THEN CONVERT(VARCHAR(10), PrintTime, 120)
            ELSE CASE WHEN DRI.LotNo IN ('VVNU212R750638') THEN CONVERT(VARCHAR(10), PrintTime, 120)
                 ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, PrintTime), 120) END
        END) AS jobdate,
        SPQBL.SClass, SPQBL.AClass, SPQBL.BClass, SPQBL.CClass, SPQBL.DClass,T12.WorkCenterCode,
		T10.ElectrodeM_Barcode_Short AS ElectrodeM_Code,
        T3.MaterialName AS ElectrodeM_Name,
		T10.ElectrodeP_Barcode_Short ASElectrodeP_Code,
        T4.MaterialName AS ElectrodeP_Name
	
	  
    FROM tung22 DRI
    LEFT OUTER JOIN STB_VVT_StagePrices vwup ON vwup.model = DRI.MaterialCode AND 'V-28' LIKE '%' + vwup.RouteV28 + '%'
    LEFT OUTER JOIN STB_SavePackingQtyByLevel_VVT SPQBL ON SPQBL.IDSPT = DRI.id
	LEFT  OUTER JOIN STB_ItemCode T12 ON DRI.MaterialCode = T12.MaterialCode
    LEFT JOIN MappedMaterials T10 ON DRI.LotNo = T10.LotNo 
    LEFT JOIN STB_MaterialMaster T3 WITH(NOLOCK) ON T10.ElectrodeM_Code = T3.MaterialCode
    LEFT JOIN STB_MaterialMaster T4 WITH(NOLOCK) ON T10.ElectrodeP_Code = T4.MaterialCode

    WHERE DRI.EmpNo NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker')
      AND (RowPackQty2 = 1 OR RowPackQty2 < (CASE WHEN @LotNo <> '*' THEN 50 ELSE 2 END))
    ORDER BY DRI.LotNo, DRI.PrintTime, DRI.EmpNo
		END








		/*
	IF @pWorkCenterCode = 'VVT_F2'
		BEGIN

				update  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT]
				set PackQty = -1*PackQty,EmpNo=EmpNo+'.'
				where PackQty>0 
				and PackingID in (
				 SELECT b.PackingID
				  FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] a with(nolock) 
				  join  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] b  with(nolock) on a.LotNo = left(b.PackingID,14)
				  where a.id>615234
				  and b.id>615234
				  and a.PackQty>0
				  and b.PackQty>0 
				  and a.LotNo<>b.LotNo 
				  and a.isPrinted=0
				  and b.isPrinted=0
				)

				;with tung as 
						(
	   						SELECT  id,
							(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
							,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty, isPrinted,PartNo,
							(RANK() over (partition by LotNo,isPrinted order by  PackQty desc,printtime desc) ) as RankPackQty,
							(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--,
							  --ISNULL(DRI.PackQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as Price
							FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

							where 1=1 
							 and  EmpNo not in ('test_worker','assy_packing','vvt_worker' )
							and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
							and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
							and PackQty>1 --or MaterialName like '%356_%' and PackQty>120)
							and ( isPrinted = 0 or isPrinted = (case when @LotNo is not null and @LotNo<>'*' then 1 else 0 end)  )	
							---and LotNo='VVKQ153R050503'
						)

					 ,
					 tung22 as (
					SELECT  id,
					 newLotno,LotNo,PackingID,a.MaterialCode,MaterialName,EmpNo,PrintTime,
					 PackQty --* (select count(LotNo) from stb_materialLotinfo  WITH(NOLOCK) where LotNo =a.LotNo) as PackQty
					 ,isPrinted,PartNo
					 ,b.InputLineCode,c.ProdDateTime,b.ControlNo,
				(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty2
					  FROM tung a WITH(NOLOCK) 
					  join STB_SetInfo b WITH(NOLOCK)  on  (a.LotNo=b.Barcode or a.newLotno=b.Barcode)
					  join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode='V-28_BG'
					  where 1=1 
					   and  EmpNo not in ('test_worker','assy_packing')

						and (RowPackQty=1 /*or RankPackQty in (1,2) and MaterialName like '%35_2%'*/)
						AND (@LineCode = '*' OR InputLineCode   = @LineCode)
						AND (@LotNo = '*' OR LotNo       = @LotNo or newlotno=@LotNo)

					 )
					SELECT   id,
					 newLotno,LotNo,PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty 
					 , (case when isPrinted is null or isPrinted=0 then 'Hien(show)' else 'An(hide)' end) as isPrinted
					 , PartNo
					 , InputLineCode,ProdDateTime,ControlNo,
					   ISNULL(DRI.PackQty, 0) *  convert(numeric(38,15),ISNULL(vwup.PriceV28,0)) /** 1.05*/  as Price,
					   --case này mới đúng đang sửa cho hợp báo cáo bằng case dưới
	   					 --(case  when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
								--then     convert(varchar(10),PrintTime,120)    
								--else    convert(varchar(10),dateadd(day, -1,  PrintTime),120)       
								--end )
							(case  
								--when LotNo in (select * from stb_Changedate_B781_220924)  then '2024-07-19'   
								--when LotNo in ('MVVOR056R015504')  then '2024-09-11'   
								when   (datepart(hour, PrintTime)>10)     or    (datepart(hour, PrintTime)=10 and datepart(minute, PrintTime)>30)     
								then     convert(varchar(10),PrintTime,120)    
								else 
									case 
									when LotNo='VVNU212R750638'
									then
								   convert(varchar(10),dateadd(day, 0,  PrintTime),120)  
								   else
				   					convert(varchar(10),dateadd(day, -1,  PrintTime),120)
								   end       
								end )	
									as  jobdate
					  FROM tung22  DRI WITH(NOLOCK) 
				--left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode='V-28_BG'
				left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and 'V-28_BG' like '%'+vwup.RouteV28+'%'
					  where 1=1 
					   and  EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
						and PackQty>1
						and  SUBSTRING (LotNo, 1, 1) !='M'
						and (RowPackQty2=1 or RowPackQty2 < (case when @LotNo is not null and @LotNo<>'*' then 50 else 2 end) )
		
					  order by LotNo, PrintTime, EmpNo 
						END

	

END
*/


-- exec usp_Vietnam_PackPrintTime_get  'nguyentung','Vietnamese','','2020-08-24','2020-08-24','','','VVKR032R733509',''
-- select * from STB_SavePackingTime_VVT where LotNo= 'VVOJ203R018653'
--SELECT * FROM STB_ProdRouteHist WHERE CREATEUSERID = 'VVTWORKER_BG' 
--SELECT * FROM STB_SetInfo


-- select * from STB_SavePackingTime_VVT WHERE LotNo = 'VVOM103R033519'


--update STB_SavePackingTime_VVT SET PrintTime = '2024-04-09 23:35:04.290' WHERE   LotNo IN
--(
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM092R718614',
--'VVOM092R718615',
--'VVOM092R718616',
--'VVOM092R718617',
--'VVOM092R718618',
--'VVOM092R718619',
--'VVOM092R718620',
--'VVOM092R718621',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718622',
--'VVOM082R718621',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM082R718615',
--'VVOM082R718616',
--'VVOM082R718617',
--'VVOM082R718618',
--'VVOM082R718619',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM082R718622',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM093R018617',
--'VVOM093R018618',
--'VVOM093R018620',
--'VVOM093R018621',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM083R018611',
--'VVOM083R018612',
--'VVOM083R018613',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018616',
--'VVOM083R018617',
--'VVOM083R018618',
--'VVOM083R018619',
--'VVOM083R018620',
--'VVOM092R740614',
--'VVOM092R740615',
--'VVOM092R740616',
--'VVOM092R740617',
--'VVOM092R740618',
--'VVOM092R740619',
--'VVOM092R740620',
--'VVOM092R750626',
--'VVOM092R750636',
--'VVOM092R750637',
--'VVOM092R750638',
--'VVOM092R750639',
--'VVOM092R750640',
--'VVOM093R025627',
--'VVOM093R025628',
--'VVOM093R025630',
--'VVOM093R025631',
--'VVOM093R025633',
--'VVOM093R025634',
--'VVOM093R025635',
--'VVOM093R025636',
--'VVOM082R718614',
--'VVOM082R718615',
--'VVOM082R718617',
--'VVOM082R718620',
--'VVOM082R718621',
--'VVOM083R018612',
--'VVOM083R018614',
--'VVOM083R018615',
--'VVOM083R018618',
--'VVOM093R018601',
--'VVOM032R740641',
--'VVOM042R740612',
--'VVOM042R740630',
--'VVOM042R740631',
--'VVOM052R740615',
--'VVOM052R740620',
--'VVOM072R750626',
--'VVOM072R750628',
--'VVOM082R750602',
--'VVOM082R750604',
--'VVOM082R750605',
--'VVOM082R750606',
--'VVOM082R750607',
--'VVOM082R750609',
--'VVOM082R750611',
--'VVOM082R750613',
--'VVOM083R025601',
--'VVOM083R025604',
--'VVOM083R025608',
--'VVOM083R025609',
--'VVOM083R025614',
--'VVOM083R025616'
--)