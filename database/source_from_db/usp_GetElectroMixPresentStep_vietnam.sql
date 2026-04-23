---   usp_GetElectroMixPresentStep_vietnam 'VVMM0720001E14','ad'
CREATE  PROC  [dbo].[usp_GetElectroMixPresentStep_vietnam]
	@pBarcode VARCHAR(20),
	@pOrder VARCHAR(10) = NULL
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@ProdCode VARCHAR(20) 

	SELECT @ProdCode = MaterialCode
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	;WITH ElectrodeStep AS (
		 SELECT *, ROW_NUMBER() OVER(ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN case when @pOrder is not null and @pOrder<>''  then 2 else 1 end
						  WHEN ES.ElectrodeStepCode = 'G' THEN case when @pOrder is not null and @pOrder<>'' then 1 else 2 end
						  WHEN ES.ElectrodeStepCode = 'K' THEN 3
						  WHEN ES.ElectrodeStepCode = 'P' THEN 4
						  WHEN ES.ElectrodeStepCode = 'S' THEN 5
						  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
						  END , ES.seq) AS UniqueSeq
		   FROM (
			select ProdCode, seq, ElectrodeStepCode, 
			--case when MaterialCode='GAJSCB-001' then 'GAADCB-001' else MaterialCode end as 
			MaterialCode, 
			StdMinVal, StdMaxVal, WorkTime, HighSpeedSpin, 
				LowSpeedSpin, Remark, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			from 
			STB_ElectrodeStep			
	  ) ES
		  WHERE ProdCode = @ProdCode
	)
	SELECT TOP 1 * from (
	select
	       ES.ElectrodeStepCode
	      ,ES.seq
		  ,MM.MaterialName+'^'+MM.MaterialCode as MaterialName
		  ,ISNULL(ES.StdMinVal, 0) AS StdMinVal
		  ,ISNULL(ES.StdMaxVal, 100) AS StdMaxVal
		  ,ES.UniqueSeq
	  FROM ElectrodeStep ES 
	  LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI
	    ON ES.ElectrodeStepCode = EMSI.ElectrodeStep
	   AND ES.seq = EMSI.seq
	   AND EMSI.ElectrodeLotNumber = @Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = ES.MaterialCode
	 WHERE EMSI.ElectrodeLotNumber IS NULL
	 	 union
	 select 	'' ElectrodeStepCode,null seq,'slurry'	MaterialName,0.1	StdMinVal,	3 StdMaxVal,null UniqueSeq	
	 where (select count(*) from  STB_ElectrodeMixStepInfo where ElectrodeLotNumber=@Barcode and ElectrodeMaterialCode='slurry')=0
	 ) newtable
	 ORDER BY CASE WHEN ElectrodeStepCode = 'D' THEN case when @pOrder is not null and @pOrder<>''  then 2 else 1 end
						  WHEN ElectrodeStepCode = 'G' THEN case when @pOrder is not null and @pOrder<>'' then 1 else 2 end
						  WHEN ElectrodeStepCode = 'K' THEN 3
						  WHEN ElectrodeStepCode = 'P' THEN 4
						  WHEN ElectrodeStepCode = 'S' THEN 5
						  WHEN ElectrodeStepCode = 'DA' THEN 6
						  else 7
						  END , seq
END