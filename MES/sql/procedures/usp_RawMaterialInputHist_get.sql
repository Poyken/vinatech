-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-10-30
-- Description : 생산관리 > 실적등록 > 자주검사/원자재투입 > 원자재투입이력
-- Modified :
-- 실행 :exec usp_RawMaterialInputHist_get '','','B164181C1261400001'
-- 2021-06-14 : Mr.Tung  adding LotID columns
-- =============================================
ALTER PROCEDURE [dbo].[usp_RawMaterialInputHist_get]
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pBarcode VARCHAR(20)=null
AS

BEGIN

	SET NOCOUNT ON;

	Declare @Barcode                  VARCHAR(20) = @pBarcode
			 , @RawMaterialInputHist INT 
			 , @SizeCode                 VARCHAR(20) 

			 , @MaterialCode            VARCHAR(50)    -- 추가
			 , @ChildMaterialName     VARCHAR(80)    -- 추가
			 , @MaterialType             VARCHAR(10)    -- 추가
			 , @Count                      INT                -- 추가
			 , @WorkCenterCode VARCHAR(20) --추가 2023.07.23


	 IF EXISTS (SELECT 1 FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode) BEGIN
		declare @NewBarcode     VARCHAR(20)
		select @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode

		  SELECT @Barcode = CASE 
                          WHEN @NewBarcode LIKE 'VJOQ%'   THEN (SELECT OldBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode)  --- Ha add 2025/01/03  điều kiện này do chị Hoa sửa 1 số mã lot thành VJOQ để xuất hàng
                          ELSE (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode)
                      END;


	

	 END

	 		SELECT @MaterialCode = MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode
	 
	-- Mr.duy licensed column MBIExtText07 for the Ha Nam factory product type on screen A230
	
	  SELECT @SizeCode = CASE	WHEN MBIExtText07='Nordex' THEN 'Nordex' -- Mr.Manh add for Bac Giang 2 (2026-04-09)
								WHEN MaterialTypeCode = 'MDL' THEN 'Module'	  --and ISNULL(MBIExtText07,'') <> 'Nordex' THEN 'Module'
								WHEN MBIExtText07 = 'CHIP_HN' THEN 'CHIP_HN'
								WHEN MBIExtText07 = 'NORMAL_HN' THEN 'NORMAL_HN'
								WHEN MBIExtText07 = 'TAPPING_HN' THEN 'TAPPING_HN'
								WHEN MBIExtText07='3562-JIANGHAI' THEN '3562-JIANGHAI' -- Mr.Trieu add conditon with history show RawMaterial with Model 3562-JIANGHAI (2025-10-27)
								WHEN MBIExtText07='PCBA' THEN 'PCBA' -- Mr.Manh add for Bac Giang 2 (2026-02-20)
								WHEN MBIExtText07='SCM' THEN 'SCM' -- Mr.Manh add for Bac Giang 2 (2026-03-24)
								WHEN MBIExtText07='SL7' THEN 'SL7' -- Mr.Manh add for Bac Giang 2 (2026-03-24)
								
										WHEN MBISizeW IN (6, 8, 10) THEN 'Small' --add 6 by Mr.tung on 2022-07-15
										WHEN MBISizeW IN (13, 16, 18) THEN 'Middle'
										WHEN MBISizeW IN (22, 25, 27, 30, 35) and ModelCode not in('ECVT30-370') THEN 'Large' -- Mr.Trieu Add condition ignore if it is 3562-JIANGHAI(2025-10-27)
										
										ELSE NULL END
	  FROM STB_ModelBasicInfo with(nolock) 
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  WHERE Barcode  =@Barcode )
	  --RAISERROR(@Barcode,16,1)
	
	-- 본사 P/S사업부의 경우 VNT_F3로 작업장이 분리되므로 입력 받은 Barcode의 일일작업지시 정보가 VNT_F3이면, @SizeCode를 ModuleF3로 고정함.(베트남의 모듈 정보와 구분하기 위함. 2023.07.23 By Jackaroe
	SELECT @WorkCenterCode = WorkCenterCode
	  FROM STB_DayProdPlan DPP
	 WHERE DayPlanNo = (SELECT DayPlanNo FROM STB_SetInfo WHERE Barcode = @Barcode)

	IF @WorkCenterCode = 'VNT_F3' BEGIN
		SET @SizeCode = 'ModuleF3'
	END

	-- 2026-01-07 Mr.Manh thêm các lot điện cực đã bắn thành công
	-- 2026-06-04 Updated by Agent: Include Case for multiple barcodes
	SELECT 
		Main.ProductGroupCode,
		STUFF((
			SELECT '; ' + Sub.RawMaterialBarcode
			FROM STB_InputMaterialHistory Sub
			WHERE Sub.ProductGroupCode = Main.ProductGroupCode
			and sub.Barcode = @Barcode 
			FOR XML PATH('')
		), 1, 2, '') AS RawBacodeList 
	INTO #RawElectrodeMaterialHist
	FROM STB_InputMaterialHistory Main
	WHERE Main.ProductGroupCode IN ('ELECTRODEP', 'ELECTRODEM', 'Case')
	GROUP BY  Main.ProductGroupCode;


	
	SELECT @RawMaterialInputHist = COUNT(*)
	  FROM STB_RawMaterialInputHist with(nolock) 
	 WHERE Barcode = @Barcode
	 


	IF @RawMaterialInputHist = 0 
	
	BEGIN
		IF @WorkCenterCode = 'VVT_F4' AND @MaterialCode = 'EDVTSY-001' BEGIN -- SL-7의 경우 BOM을 한단계 더 조회해야하므로 분리하여 처리
			exec usp_DoMakeRawMaterialInputHistBE @Barcode
		END ELSE BEGIN
			exec usp_DoMakeRawMaterialInputHist @Barcode, @SizeCode
		END
	END

	if(@WorkCenterCode NOT IN ('VVT_F3','VVT_F4'))
		Begin
			SELECT RMIH.RawMaterialInputHistNo as RawMaterialInputHistNo
					 , RMBI.SizeCode
					 , @Barcode AS Barcode
					 , RMIH.ProductGroupCode
					 --,  RMBI.ProductGroupName
					 ,(CASE
						 WHEN @WorkCenterCode = 'VNT_F4'
						 THEN (SELECT mm.MaterialName FROM STB_MaterialMaster mm where mm.MaterialCode = RMIH.MaterialCode)
						 ELSE RMBI.ProductGroupName	
					 END) AS ProductGroupName -- 2025.10.31 완주2공장의 경우 자재그룹명이 아닌 BOM 품목명을 가져온다.
					 --, RMIH.RawMaterialBarcode      -- original before adding LotID
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%' 
								then SUBSTRING(RMIH.RawMaterialBarcode,18,len(RMIH.RawMaterialBarcode)-17) --- get string behind of ~
							else RMIH.RawMaterialBarcode end
					  as RawMaterialBarcode
					 ,GoodQtyLength 
					 ,  SlittingWidth
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%'
								then SUBSTRING(RMIH.RawMaterialBarcode,1,16)                               --- get string front of ~
							else '' end
					  as LotID_Warehouse_Created			  
					 , RMIH.CreateUserID
					 , RMIH.CreateDateTime AS ChangeDateTime
					 , RMIH.ChangeUserID
					 , RMIH.ChangeDateTime AS CreateDateTime
					 , RMBI.ProductGroupName_VVT                  -- 2020.02.14 추가 (베트남법인)
					  ,RMIH.MaterialCode,
					  MDI.LevelJIANGHAI, -- Mr.Trieu add Level JIANGHAI
					  MDD.ManufacturerCode, -- Mr.Trieu change for request Mrs.Ha BG2
					  CI.CustomerName AS ManufacturerName,
					  MDD.Weekcode,	
					  MDD.RevisionsVer
					  ,tmp.RawBacodeList
					  ,'' AS MaterialName
			  FROM STB_RawMaterialInputHist RMIH with(nolock) 
						LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode
						LEFT outer join STB_ElectrodeSlittingResult esr  with(nolock) on (esr.Barcode=RMIH.RawMaterialBarcode or esr.ElectrodeLotNumber=RMIH.RawMaterialBarcode)
						LEFT outer join STB_MaterialDocLotInfo MDI with(nolock) on MDI.LotID=RMIH.RawMaterialBarcode
						LEFT outer join STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDI.MaterialDocDetailNo
						--LEFT outer join STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
						LEFT outer join STB_CustomerInfo CI WITH(NOLOCK) ON CI.CustomerCode = MDD.ManufacturerCode
						LEFT OUTER JOIN #RawElectrodeMaterialHist tmp ON RMIH.ProductGroupCode = tmp.ProductGroupCode
			 WHERE RMIH.Barcode =@Barcode
			 ORDER BY RMBI.DisplayIndex, RMIH.RawMaterialInputHistNo

		 --	 select * from STB_RawMaterialBaiscInfo where sizecode='TAPPING_HN' and DisplayIndex=1 order by displayindex desc  bảng này là bảng để thiết lập default các nguyên vật liệu cho con hàng
	--	 end
	--ELSE IF @WorkCenterCode = 'VVT_F4'  BEGIN
	--	-- 기준이 존재하는지 확인하여 없으면 기준을 먼저 만든다. 

		
	--	SELECT '
	END ELSE IF @WorkCenterCode = 'VVT_F4' BEGIN
		SELECT   
			RMIH.RawMaterialInputHistNo as RawMaterialInputHistNo
					 , RMBI.SizeCode
					 , @Barcode AS Barcode
					 , RMIH.ProductGroupCode
					 , (SELECT MaterialSpecL FROM STB_MaterialMaster WHERE MaterialCode = RMIH.MaterialCode) AS ProductGroupName
					 --, RMIH.RawMaterialBarcode      -- original before adding LotID
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%' 
								then SUBSTRING(RMIH.RawMaterialBarcode,18,len(RMIH.RawMaterialBarcode)-17) --- get string behind of ~
							else RMIH.RawMaterialBarcode end
					  as RawMaterialBarcode
					 ,GoodQtyLength 
					 ,  SlittingWidth
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%'
								then SUBSTRING(RMIH.RawMaterialBarcode,1,16)                               --- get string front of ~
							else '' end
					  as LotID_Warehouse_Created			  
					 , RMIH.CreateUserID
					 , RMIH.CreateDateTime AS ChangeDateTime
					 , RMIH.ChangeUserID
					 , RMIH.ChangeDateTime AS CreateDateTime
					 ,  RMBI.ProductGroupName_VVT
					-- ,RMBI.ProductGroupName
					 ,RMIH.MaterialCode,
					  MDI.LevelJIANGHAI, -- Mr.Trieu add Level JIANGHAI
					 MDD.ManufacturerCode,-- Mr.Trieu change for request Mrs.Ha BG2
					 CI.CustomerName AS ManufacturerName,
					  MDD.Weekcode,	
					  MDD.RevisionsVer
					  ,tmp.RawBacodeList
					  ,--(SELECT MaterialName FROM STB_MaterialMaster WHERE MaterialCode = RMIH.MaterialCode) AS MaterialName,
					  COALESCE((SELECT MaterialName FROM STB_MaterialMaster WHERE MaterialCode = RMIH.MaterialCode), RMBI.ProductGroupName) as MaterialName, --update 2026-05-04

					  -- 소병운 26-05-07 대체자재 투입 조회
					  DLOG.OrgMaterialCode,
					  DLOG.OrgMaterialRevision
					  

			  FROM		
					 
						 STB_RawMaterialInputHist RMIH with(nolock) 
						LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode
						left outer join STB_ElectrodeSlittingResult esr  with(nolock) on (esr.Barcode=RMIH.RawMaterialBarcode or esr.ElectrodeLotNumber=RMIH.RawMaterialBarcode)
							left outer join STB_MaterialDocLotInfo MDI with(nolock) on MDI.LotID=RMIH.RawMaterialBarcode
					    left outer join STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDI.MaterialDocDetailNo
						--left outer join STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
						LEFT outer join STB_CustomerInfo CI WITH(NOLOCK) ON CI.CustomerCode = MDD.ManufacturerCode
						/*left join STB_SetInfo si     on si.barcode=RMIH.Barcode	
						left join  STB_BomDetail bd   on si.MaterialCode=bd.MaterialCode   and bd.BomVersion='99'
						 join STB_MaterialMaster mm on mm.MaterialCode = bd.ChildMaterialCode and RMIH.ProductGroupCode=mm.ProductGroupCode */
						 LEFT OUTER JOIN #RawElectrodeMaterialHist tmp ON RMIH.ProductGroupCode = tmp.ProductGroupCode
						 LEFT OUTER JOIN STB_DelegateMaterialInputLog DLOG WITH(NOLOCK) ON DLOG.ProductionLotNo = RMIH.Barcode AND DLOG.DelegateMaterialLotNo = RMIH.RawMaterialBarcode
			 WHERE RMIH.Barcode =@Barcode 
			 ORDER BY RMBI.DisplayIndex
	END ELSE
		BEGIN

			SELECT   
			RMIH.RawMaterialInputHistNo as RawMaterialInputHistNo
					 , RMBI.SizeCode
					 , @Barcode AS Barcode
					 , RMIH.ProductGroupCode
					 ,  RMBI.ProductGroupName
					 --, RMIH.RawMaterialBarcode      -- original before adding LotID
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%' 
								then SUBSTRING(RMIH.RawMaterialBarcode,18,len(RMIH.RawMaterialBarcode)-17) --- get string behind of ~
							else RMIH.RawMaterialBarcode end
					  as RawMaterialBarcode
					 ,GoodQtyLength 
					 ,  SlittingWidth
					 , case when RMIH.RawMaterialBarcode like 'ML%' and RMIH.RawMaterialBarcode like '%~%'
								then SUBSTRING(RMIH.RawMaterialBarcode,1,16)                               --- get string front of ~
							else '' end
					  as LotID_Warehouse_Created			  
					 , RMIH.CreateUserID
					 , RMIH.CreateDateTime AS ChangeDateTime
					 , RMIH.ChangeUserID
					 , RMIH.ChangeDateTime AS CreateDateTime
					 ,  RMBI.ProductGroupName_VVT
					-- ,RMBI.ProductGroupName
					 ,RMIH.MaterialCode,
					  MDI.LevelJIANGHAI, -- Mr.Trieu add Level JIANGHAI
					 MDD.ManufacturerCode,-- Mr.Trieu change for request Mrs.Ha BG2
					 CI.CustomerName AS ManufacturerName,
					  MDD.Weekcode,	
					  MDD.RevisionsVer
					  ,tmp.RawBacodeList
					  ,'' AS MaterialName
			  FROM		
					 
						 STB_RawMaterialInputHist RMIH with(nolock) 
						LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode
						left outer join STB_ElectrodeSlittingResult esr  with(nolock) on (esr.Barcode=RMIH.RawMaterialBarcode or esr.ElectrodeLotNumber=RMIH.RawMaterialBarcode)
							left outer join STB_MaterialDocLotInfo MDI with(nolock) on MDI.LotID=RMIH.RawMaterialBarcode
					    left outer join STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo=MDI.MaterialDocDetailNo
						--left outer join STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo=MDD.MaterialIqcNo
						LEFT outer join STB_CustomerInfo CI WITH(NOLOCK) ON CI.CustomerCode = MDD.ManufacturerCode
						/*left join STB_SetInfo si     on si.barcode=RMIH.Barcode	
						left join  STB_BomDetail bd   on si.MaterialCode=bd.MaterialCode   and bd.BomVersion='99'
						 join STB_MaterialMaster mm on mm.MaterialCode = bd.ChildMaterialCode and RMIH.ProductGroupCode=mm.ProductGroupCode */
						 LEFT OUTER JOIN #RawElectrodeMaterialHist tmp ON RMIH.ProductGroupCode = tmp.ProductGroupCode
			 WHERE RMIH.Barcode =@Barcode 
			
		ORDER BY RMBI.DisplayIndex, RMIH.RawMaterialInputHistNo
		END
END

--           usp_RawMaterialInputHist_get '','','VE241231-001'


--;with data1 as (
-- select barcode,convert(varchar(17),createdatetime,120) as t1,count(*) as t2
-- from   STB_RawMaterialInputHist  with(nolock)
-- where  createdatetime>'2022-09-01'
-- group by barcode,convert(varchar(17),createdatetime,120)
-- having count(*)<7
-- )
-- select rm.* from stb_setinfo rm with(nolock)
-- join data1 on rm.barcode =data1.barcode or rm.barcode =replace(data1.barcode,'VJ','VV')
-- where materialcode='ECVT27-369'




-- select barcode,convert(varchar(17),createdatetime,120) as t1,count(*) as t2
-- from STB_RawMaterialInputHist
-- where barcode in (
--'VJMR272R750601',
--'VJMR152R750647',
--'VJMR192R750647',
--'VJMR272R750601',
--'VJMR122R750615',
--'VJMR272R750630',
--'VJMR192R750617',
--'VJMR242R750623',
--'VJMR092R750667',
--'VJMR262R750673',
--'VJMR152R750637',
--'VJMR272R750630',
--'VJMR152R750647',
--'VJMR262R750673',
--'VJMR092R750667',
--'VJMR092R750616',
--'VJMR192R750647'
--) or barcode in (
--'VVMR272R750601',
--'VVMR152R750647',
--'VVMR192R750647',
--'VVMR272R750601',
--'VVMR122R750615',
--'VVMR272R750630',
--'VVMR192R750617',
--'VVMR242R750623',
--'VVMR092R750667',
--'VVMR262R750673',
--'VVMR152R750637',
--'VVMR272R750630',
--'VVMR152R750647',
--'VVMR262R750673',
--'VVMR092R750667',
--'VVMR092R750616',
--'VVMR192R750647'
--)
-- group by barcode,convert(varchar(17),createdatetime,120)
-- having count(*)<7

--delete STB_RawMaterialInputHist
-- where barcode in (
--'VJMR262R750673',
--'VJMR272R750601',
--'VJMR272R750630'
--)




--select*from STB_RawMaterialInputHist
-- where barcode in (
--'VJMR272R750602'
--) 

-- order by barcode


-- Case	GBAKAC-063#B2216016J20163
--Electrolyte	GBCP00-001SPECIFICATION:ELECTROLYTE  3.0V (DLC3702)LOT NO:H222061641QUANTITY:150kgVENDOR NAME:Shenzhen CAPCHEM Technology Co.Ltd
--RubberPad	GBSN00-003#12SR06-2402
--Sleeve	GCMDPT-199  2.7 50 2205251303


--insert into STB_RawMaterialInputHist (RawMaterialInputHistNo,Barcode,	ProductGroupCode,	RawMaterialBarcode,	CreateDateTime,	CreateUserID)
--select 
--RawMaterialInputHistNo+'0','VVMR272R750602',	ProductGroupCode,	RawMaterialBarcode,	CreateDateTime,	CreateUserID--,	ChangeDateTime,	ChangeUserID
--from STB_RawMaterialInputHist
-- where barcode in (
--'VVMR272R750630'
--) and ProductGroupCode in ('Case','Electrolyte','RubberPad','Sleeve')




--select*from STB_RawMaterialInputHist a
--join STB_RawMaterialInputHist a1 on a.Barcode=a1.Barcode and a.ProductGroupCode=a1.ProductGroupCode
--and isnull(a.RawMaterialBarcode,'')<> isnull(a1.RawMaterialBarcode,'')
--where a.CreateDateTime>'2022-09-25'


--,
--'',
--'',
--''


--select*from STB_RawMaterialInputHist where barcode in(
--'VVMR272R750601'
--) and ProductGroupCode in ('Case','Electrolyte','RubberPad','Sleeve')



--delete STB_RawMaterialInputHist where barcode in(
--'VVMR272R750601'
--) and ProductGroupCode in ('Case','Electrolyte','RubberPad','Sleeve')
--and RawMaterialInputHistNo in (
--'20220928001830',
--'20220928001833',
--'20220928001835',
--'20220928001837')
--and RawMaterialBarcode is null

