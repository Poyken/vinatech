Text
----
-- =============================================

-- Author : Jackaroe(yjyu@vina.co.kr)

-- Group : ????

-- Browsable : true

-- Create date : 2019-10-30

-- Description : ???? > ???? > ????/????? > ???????

-- Modified :

-- ?? :exec usp_RawMaterialInputHist_get '','','vvpr013r015601'

-- 2021-06-14 : Mr.Tung  adding LotID columns

-- =============================================

CREATE PROCEDURE [dbo].[usp_RawMaterialInputHist_popup]

	@pProcessUserID VARCHAR(20)=null,

	@pProcessLanguage VARCHAR(20)=null,

	@pBarcode VARCHAR(20)=null

AS



BEGIN



	SET NOCOUNT ON;



	Declare @Barcode                  VARCHAR(20) = @pBarcode

			 , @RawMaterialInputHist INT 

			 , @SizeCode                 VARCHAR(20) 



			 , @MaterialCode            VARCHAR(50)    -- ??

			 , @ChildMaterialName     VARCHAR(80)    -- ??

			 , @MaterialType             VARCHAR(10)    -- ??

			 , @Count                      INT                -- ??

			 , @WorkCenterCode VARCHAR(20) --?? 2023.07.23





	 IF EXISTS (SELECT 1 FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode) BEGIN

		declare @NewBarcode     VARCHAR(20)

		select @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode



		  SELECT @Barcode = CASE 

                          WHEN @NewBarcode LIKE 'VJOQ%'   THEN (SELECT OldBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode)  --- Ha add 2025/01/03  di?u ki?n này do ch? Hoa s?a 1 s? mã lot thành VJOQ d? xu?t hàng

                          ELSE (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode)

                      END;





	



	 END



	 		SELECT @MaterialCode = MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode

	 

	-- Mr.duy licensed column MBIExtText07 for the Ha Nam factory product type on screen A230

	

	  SELECT @SizeCode = CASE	WHEN MaterialTypeCode = 'MDL' THEN 'Module'	

								WHEN MaterialTypeCode = 'MEA' THEN 'MEA'

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

	

	-- ?? P/S???? ?? VNT_F3? ???? ????? ?? ?? Barcode? ?????? ??? VNT_F3??, @SizeCode? ModuleF3? ???.(???? ?? ??? ???? ??. 2023.07.23 By Jackaroe

	SELECT @WorkCenterCode = WorkCenterCode

	  FROM STB_DayProdPlan DPP

	 WHERE DayPlanNo = (SELECT DayPlanNo FROM STB_SetInfo WHERE Barcode = @Barcode)



	IF @WorkCenterCode = 'VNT_F3' BEGIN

		SET @SizeCode = 'ModuleF3'

	END



	-- 2026-01-07 Mr.Manh thêm các lot di?n c?c dã b?n thành công

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

	GROUP BY  Main.ProductGroupCode;





	

	SELECT @RawMaterialInputHist = COUNT(*)

	  FROM STB_RawMaterialInputHist with(nolock) 

	 WHERE Barcode = @Barcode







	IF @RawMaterialInputHist = 0 

	

	BEGIN

		exec usp_DoMakeRawMaterialInputHist @Barcode, @SizeCode

	END

	if(@WorkCenterCode NOT IN ('VVT_F3'))

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

					 END) AS ProductGroupName -- 2025.10.31 ??2??? ?? ?????? ?? BOM ???? ????.

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

					 , RMBI.ProductGroupName_VVT                  -- 2020.02.14 ?? (?????)

					  ,RMIH.MaterialCode,

					  MDLI.LevelJIANGHAI -- Mr.Trieu add Level JIANGHAI

					  ,tmp.RawBacodeList

					  ,ISNULL(MDLI.LotNo, MLI.LotNo) AS LotNo

					  ,ISNULL(MDLI.LotAttr10, MLI.LotAttr10) AS LotAttr10

					  ,ISNULL(MDLI.StockQty, MLI.CurrentQty) AS StocckQty

					  ,MDD.MaterialIqcNo

					  ,MDD.InspectionType

					  ,MQI.DecisionResult

					  ,MDI.SourceCustomerCode

					  ,CI.CustomerName

					  ,RMIH.LotMaterialCode

			  FROM STB_RawMaterialInputHist RMIH with(nolock) 

						LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode

						left outer join STB_ElectrodeSlittingResult esr  with(nolock) on (esr.Barcode=RMIH.RawMaterialBarcode or esr.ElectrodeLotNumber=RMIH.RawMaterialBarcode)

						left outer join STB_MaterialDocLotInfo MDLI with(nolock) on MDLI.LotID=RMIH.RawMaterialBarcode

						LEFT OUTER JOIN #RawElectrodeMaterialHist tmp ON RMIH.ProductGroupCode = tmp.ProductGroupCode

						LEFT OUTER JOIN STB_MaterialDocDetail MDD

						  ON MDD.MaterialDocDetailNo = MDLI.MaterialDocDetailNo

						LEFT OUTER JOIN STB_MaterialQcInfo MQI

						  ON MQI.MaterialQcNo = MDD.MaterialIqcNo

						LEFT OUTER JOIN STB_MaterialDocInfo MDI

						  ON MDI.MaterialDocNo = MDD.MaterialDocNo

						LEFT OUTER JOIN STB_CustomerInfo CI

						  ON CI.CustomerCode = MDI.SourceCustomerCode

						LEFT OUTER JOIN STB_MaterialLotInfo MLI

						  ON MLI.LotID = RMIH.RawMaterialBarcode

			 WHERE RMIH.Barcode =@Barcode

			 ORDER BY RMBI.DisplayIndex, RMIH.RawMaterialInputHistNo



		 --	 select * from STB_RawMaterialBaiscInfo where sizecode='TAPPING_HN' and DisplayIndex=1 order by displayindex desc  b?ng này là b?ng d? thi?t l?p default các nguyên v?t li?u cho con hàng

	--	 end

	--ELSE IF @WorkCenterCode = 'VVT_F4'  BEGIN

	--	-- ??? ????? ???? ??? ??? ?? ???. 



		

	--	SELECT ''

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

					  MDI.LevelJIANGHAI -- Mr.Trieu add Level JIANGHAI

					  ,tmp.RawBacodeList

					  ,'' AS LotNo

					  ,'' AS LotAttr10

					  ,NULL AS StockQty

					  ,'' AS MaterialIqcNo

					  ,'' AS InspectionType

					  ,'' AS DecisionResult

					  ,'' AS SourceCustomerCode

					  ,'' AS CustomerName

					  ,RMIH.LotMaterialCode

			  FROM		

					 

						 STB_RawMaterialInputHist RMIH with(nolock) 

						LEFT OUTER JOIN STB_RawMaterialBaiscInfo  RMBI	 with(nolock)     ON RMIH.ProductGroupCode = RMBI.ProductGroupCode	   AND RMBI.SizeCode = @SizeCode

						left outer join STB_ElectrodeSlittingResult esr  with(nolock) on (esr.Barcode=RMIH.RawMaterialBarcode or esr.ElectrodeLotNumber=RMIH.RawMaterialBarcode)

							left outer join STB_MaterialDocLotInfo MDI with(nolock) on MDI.LotID=RMIH.LotMaterialCode

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





