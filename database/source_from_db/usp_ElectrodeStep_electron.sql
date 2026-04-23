--exec usp_ElectrodeStep_electron 'VVOL0812001E23'
CREATE PROC [dbo].[usp_ElectrodeStep_electron]
	@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode

	SELECT MM1.MaterialName AS ProdName
		  ,ES.seq
		  ,ES.ElectrodeStepCode
		  ,MM2.MaterialName
		  ,CASE WHEN MM2.MaterialName = '증류수' THEN 0 ELSE ISNULL(ES.StdMinVal, 0) END AS StdMinVal
		  ,CASE WHEN MM2.MaterialName = '증류수' THEN 100 ELSE ISNULL(ES.StdMaxVal, 100) END AS StdMaxVal
		  ,ISNULL(ES.WorkTime, 0) AS WorkTime
		  ,ISNULL(EMI.InputQty1, 0) AS InputQty1
		  ,ISNULL(EMI.InputQty2, 0) AS InputQty2
		  ,ISNULL(ES.Remark, '') AS Remark
	  FROM STB_ElectrodeStep ES
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
	 WHERE SI.Barcode = @Barcode
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN 1
					  WHEN ES.ElectrodeStepCode = 'G' THEN 2
					  WHEN ES.ElectrodeStepCode = 'K' THEN 3
					  WHEN ES.ElectrodeStepCode = 'P' THEN 4
					 WHEN ES.ElectrodeStepCode = 'S1' THEN 6
				  WHEN ES.ElectrodeStepCode = 'S2' THEN 7
				  WHEN ES.ElectrodeStepCode = 'S3' THEN 8
				  WHEN ES.ElectrodeStepCode = 'S4' THEN 9
				  WHEN ES.ElectrodeStepCode = 'S5' THEN 10
				  WHEN ES.ElectrodeStepCode = 'DA' THEN 11
				  ELSE 100
					  END , ES.seq
END