CREATE PROC [dbo].[usp_ElectrodeStep_VVT_powerBi_get]
	@pFromDate datetime =null,
	@pToDate datetime = NULL,
	@pBarcode VARCHAR(20)=NULL
AS
BEGIN
-- usp_ElectrodeStep_VVT_powerBi_get '2022-04-01','2022-04-09','VV'
	select @pFromDate = convert(varchar(10),isnull(@pFromDate,'2022-03-01'),120) +' 08:00:00'
	select @pToDate = convert(varchar(10),isnull(dateadd(day,1,@pToDate),'2022-04-09'),120) +' 08:00:00'

	set @pBarcode=isnull(@pBarcode,'%')	

	SELECT si.barcode as ElectrodeLot
		,mm1.materialcode as ElectrodeCode
		,MM1.MaterialName AS ElectrodeName
		  ,ES.seq
		  ,ES.ElectrodeStepCode
		  ,mm2.materialcode 
		  ,MM2.MaterialName 
		  ,ISNULL(ES.StdMinVal, 0)  AS StdMinVal
		  ,ISNULL(ES.StdMaxVal, 100)  AS StdMaxVal		  
		  ,ISNULL(EMI.InputQty1, 0) + ISNULL(EMI.InputQty2, 0) AS ValWeight
		  --,ISNULL(EMI.InputQty2, 0) AS InputQty2
		  ,ISNULL(ES.WorkTime, 0) AS WorkTime
		  ,ISNULL(ES.Remark, '') AS Remark
		  --,case when EMI.ChangeDateTime is null and EMI.ChangeUserID is null and EMI.CreateUserID='eai' then '1' else '' end as reprint
		  ,convert(varchar(19),EMI.CreateDateTime,120) CreateDateTime
		  ,case when EMI.CreateUserID ='eai' then 'SOFTWARE' when EMI.CreateUserID is null then null else 'MANUAL' end as InputBy
	  FROM STB_ElectrodeStep ES
	  LEFT OUTER JOIN STB_SetInfo SI
		ON ES.ProdCode = SI.MaterialCode
	  LEFT OUTER JOIN STB_MaterialMaster MM1
		ON MM1.MaterialCode = ES.ProdCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
		ON MM2.MaterialCode = ES.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMI
	    ON EMI.ElectrodeLotNumber = si.Barcode
	   AND EMI.ElectrodeStep = ES.ElectrodeStepCode
	   AND EMI.Seq = ES.seq
	 WHERE SI.CreateDateTime between @pFromDate and @pToDate and   ES.ElectrodeStepCode <> 'DA'
	 and si.barcode like @pBarcode+'%'
	 ORDER BY si.barcode,mm1.materialcode,CASE WHEN ES.ElectrodeStepCode = 'D' THEN  1
					  WHEN ES.ElectrodeStepCode = 'G' THEN 2
					  WHEN ES.ElectrodeStepCode = 'K' THEN 3
					  WHEN ES.ElectrodeStepCode = 'P' THEN 4
					  WHEN ES.ElectrodeStepCode = 'S' THEN 5
					  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
					  END , ES.seq
END
