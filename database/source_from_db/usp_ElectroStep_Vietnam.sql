CREATE PROC [dbo].[usp_ElectroStep_Vietnam] --'VVMR2620001E05'
	@pBarcode VARCHAR(20),
	@pOrder VARCHAR(10) = NULL
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	select * from
	(SELECT MM1.MaterialName AS ProdName
		  ,ES.seq
		  ,ES.ElectrodeStepCode
		  ,MM2.MaterialName
		  ,ISNULL(ES.StdMinVal, 0)  AS StdMinVal
		  ,ISNULL(ES.StdMaxVal, 100)  AS StdMaxVal
		  ,ISNULL(ES.WorkTime, 0) AS WorkTime
		  ,ISNULL(EMI.InputQty1, 0) AS InputQty1
		  ,ISNULL(EMI.InputQty2, 0) AS InputQty2
		  ,ISNULL(ES.Remark, '') AS Remark
		  ,case when EMI.ChangeDateTime is null and EMI.ChangeUserID is null and EMI.CreateUserID like 'eai%' then '1' else '' end as reprint
		  ,convert(varchar(19),EMI.CreateDateTime,120) CreateDateTime
		  ,case when EMI.CreateUserID like 'eai%' then 'eai' else EMI.CreateUserID end as CreateUserID
	  FROM (
			select ProdCode, seq, ElectrodeStepCode, 
			--case when MaterialCode='GAJSCB-001' then 'GAADCB-001' else MaterialCode end as 
			MaterialCode, 
			StdMinVal, StdMaxVal, WorkTime, HighSpeedSpin, 
				LowSpeedSpin, Remark, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			from 
			STB_ElectrodeStep			
	  )ES
	  LEFT OUTER JOIN STB_SetInfo SI
		ON ES.ProdCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_MaterialMaster MM1
		ON MM1.MaterialCode = ES.ProdCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
		ON MM2.MaterialCode = ES.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMI
	    ON EMI.ElectrodeLotNumber = @Barcode
	   AND EMI.ElectrodeStep = ES.ElectrodeStepCode
	   AND EMI.Seq = ES.seq
	 WHERE SI.Barcode = @Barcode and    ES.ElectrodeStepCode <> 'DA' 
	 union
	 select 'slurry' as ProdName,	1 seq,	'' ElectrodeStepCode,'slurry'	MaterialName,0.001	StdMinVal,	3 StdMaxVal,0	WorkTime,0	InputQty1,0	InputQty2,''	Remark,null	reprint,null	CreateDateTime,''	CreateUserID
	 where (select count(*) from  STB_ElectrodeMixStepInfo where ElectrodeLotNumber=@Barcode and ElectrodeMaterialCode='slurry')=0
	 ) newtable
	 ORDER BY CASE   
	                  WHEN ElectrodeStepCode = 'D' THEN case when @pOrder is not null and @pOrder<>''  then 2 else 1 end
					  WHEN ElectrodeStepCode = 'G' THEN case when @pOrder is not null and @pOrder<>'' then 1 else 2 end
					  WHEN ElectrodeStepCode = 'K' THEN 3
					  WHEN ElectrodeStepCode = 'P' THEN 4
					  WHEN ElectrodeStepCode LIKE 'S%' THEN 5
					  WHEN ElectrodeStepCode = 'DA' THEN 6
					 -- WHEN ElectrodeStepCode IS NULL OR ElectrodeStepCode = '' THEN 99
					  ELSE 7
					  END ,
					  CASE 
           WHEN ElectrodeStepCode LIKE 'S%' 
            THEN TRY_CAST(SUBSTRING(ElectrodeStepCode, 2, LEN(ElectrodeStepCode)) AS INT) 
         END,  --updated 2025/09/11
					  seq,
					  MaterialName desc

--	select top 1000* from STB_ElectrodeMixStepInfo
--where ElectrodeMaterialCode='GAADCB-001'--'GAJSCB-001'
--select*from STB_ElectrodeStep

END

