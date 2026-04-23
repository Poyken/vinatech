
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-13
-- =============================================

--exec usp_Vietnam_GetModuleInspectHistQC '','','','2021-09-01','2021-09-30',''

CREATE PROCEDURE [dbo].[usp_Vietnam_GetModuleInspectHistQC]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pPartNumber  VARCHAR(100)=null,
						@pFromDate  Datetime = null,
						@pToDate  Datetime = null,
						@pLotNo  VARCHAR(20) = null
AS
BEGIN

	SET NOCOUNT ON;

	--[LotNo], [고객사] ,[S_JARVIS] ,[S_Quality_Outsourcing_] ,[E_JARVIS] ,[E_Quality_Outsourcing_] ,[E_Quality_VN_] ,[SD_Quality_VN_] ,[SD_QTY]

select
	isnull(svmi.partno,sqlm.partno) as PartNumber, isnull(svmi.LotNo,sqlm.LotNo) as LotNo, 
	isnull(svmi.size,sqlm.size) as "Size_Cell_", isnull(svfg.packqty,isnull(svmi.lotqty,sqlm.lotqty)) as Quantity,
	isnull(svmi.Module_Prod_Date,sqlm.CreateDateTimePackge) as "Module_Prod_Date", 고객사,
	S_JARVIS,  "S_Quality_Outsourcing_", E_JARVIS,  "E_Quality_Outsourcing_",  
	isnull("E_Quality_VN_",0) as "E_Quality_VN_",  "SD_Quality_VN_",  isnull(SD_QTY,0) as SD_QTY,
	isnull(Result,(case when S_JARVIS is not null 
	and "S_Quality_Outsourcing_"  is not null 
	and  E_JARVIS is not null 
	and "E_Quality_Outsourcing_"  is not null 
	and  "SD_Quality_VN_" is not null then 'PASS' else '' end ))  as Result
	,isnull(CreateDate,CreatDatePacked) as "Warehouse"
	,(select top 1 workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = S_EMP) as S_EMP
	,isnull(S_NG_QTY	,0)as S_NG_QTY
	,(select top 1  workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = E_EMP) as E_EMP
	,isnull(E_NG_QTY	,0)as E_NG_QTY
	,(select top 1  workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = SD_EMP) as SD_EMP
	,isnull(SD_NG_QTY	,0)as SD_NG_QTY
from
	 STB_QC_LOTNO_MODULE  sqlm  with(nolock) 
	 full outer join [STB_Vietnam_Module_InpectionHist]  svmi  with(nolock) on sqlm.lotno = svmi.LotNo
	 left outer join STB_VN_FINISHGOODS svfg   with(nolock) on svmi.LotNo=svfg.LotNo	 
where 
		(@pLotNo='' or @pLotNo is null or sqlm.lotno=@pLotNo or svmi.LotNo=@pLotNo)
		and (sqlm.lotno is not null or svmi.lotno is not null)
		and (sqlm.partno is not null or svmi.lotno is not null)
		and (sqlm.partno = @pPartNumber or @pPartNumber is null or @pPartNumber = '')
		and isnull(isnull(sqlm.CreateDateTimePackge,svmi.Module_Prod_Date),sqlm.CreateDateTime) between @pFromDate and @pToDate

--order by  isnull(sqlm.partno,svmi.partno) , isnull(isnull(sqlm.CreateDateTimePackge,svmi.Module_Prod_Date),sqlm.CreateDateTime)

UNION 
select        RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12)))	+ case  WHEN  CHARINDEX('-O', b.MaterialName) > 0 then '-O'
					  WHEN  CHARINDEX('-IL', b.MaterialName) > 0 then '-IL'
					  WHEN CHARINDEX('-I', b.MaterialName) > 0 then '-I'
					  WHEN  CHARINDEX('-H', b.MaterialName) > 0 then '-H'
					  WHEN  CHARINDEX('-WCI(25mm)', b.MaterialName) > 0 then '-WCI(25MM)'
					  WHEN  CHARINDEX('-WCI(35mm)', b.MaterialName) > 0 then '-WCI(35MM)'
					  WHEN  CHARINDEX('HY-CAP VEM12R0126QG', b.MaterialName) > 0 then 'G'
					  

					  ELSE '' END as PartNumber , a.Barcode as Lotno,
CASE WHEN c.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, c.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, c.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), c.MBISizeD) END + CASE WHEN CHARINDEX('-L', c.ModelName) > 0 THEN 'L' ELSE '' END AS "Size_Cell_", isnull(svfg.packqty,a.ProdQty) as Quantity,
	isnull(d.Module_Prod_Date,a.CreateDateTime) as "Module_Prod_Date", 고객사,
	S_JARVIS,  "S_Quality_Outsourcing_", E_JARVIS,  "E_Quality_Outsourcing_",  
	isnull("E_Quality_VN_",0) as "E_Quality_VN_",  "SD_Quality_VN_",  isnull(SD_QTY,0) as SD_QTY,
	isnull(Result,(case when S_JARVIS is not null 
	and "S_Quality_Outsourcing_"  is not null 
	and  E_JARVIS is not null 
	and "E_Quality_Outsourcing_"  is not null 
	and  "SD_Quality_VN_" is not null then 'PASS' else '' end ))  as Result
	,isnull(CreateDate,CreatDatePacked) as "Warehouse"
	,(select top 1 workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = S_EMP) as S_EMP
	,isnull(S_NG_QTY	,0)as S_NG_QTY
	,(select top 1  workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = E_EMP) as E_EMP
	,isnull(E_NG_QTY	,0)as E_NG_QTY
	,(select top 1  workerName from dbo.[STB_ProdWorkerInfo]   with(nolock) where workercode = SD_EMP) as SD_EMP
	,isnull(SD_NG_QTY	,0)as SD_NG_QTY
from STB_SetInfo a left join STB_MaterialMaster b on a.MaterialCode = b.MaterialCode
left join STB_ModelBasicInfo c on b.MaterialCode = c.ModelCode
left join STB_Vietnam_Module_InpectionHist d on  a.Barcode = d.LotNo
 left outer join STB_VN_FINISHGOODS svfg   with(nolock) on a.Barcode=svfg.LotNo	
where a.Barcode like 'M%'
		and (b.MaterialName like '%'+@pPartNumber+'%' or @pPartNumber is null or b.MaterialName = '')
		and isnull(a.CreateDateTime,d.Module_Prod_Date) between @pFromDate and @pToDate
		

END
