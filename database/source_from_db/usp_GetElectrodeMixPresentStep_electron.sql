CREATE PROC [dbo].[usp_GetElectrodeMixPresentStep_electron]
	@pBarcode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@ProdCode VARCHAR(20) 

	SELECT @ProdCode = MaterialCode
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	;WITH ElectrodeStep AS (
		 SELECT *, ROW_NUMBER() OVER(ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN 1
						  WHEN ES.ElectrodeStepCode = 'G' THEN 2
						  WHEN ES.ElectrodeStepCode = 'K' THEN 3
						  WHEN ES.ElectrodeStepCode = 'P' THEN 4
						  WHEN ES.ElectrodeStepCode = 'S' THEN 5
						  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
						  END , ES.seq) AS UniqueSeq
		   FROM STB_ElectrodeStep ES
		  WHERE ProdCode = @ProdCode
	)
	SELECT TOP 1 
	       ES.ElectrodeStepCode
	      ,ES.seq
		  ,MM.MaterialName
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
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN 1
						  WHEN ES.ElectrodeStepCode = 'G' THEN 2
						  WHEN ES.ElectrodeStepCode = 'K' THEN 3
						  WHEN ES.ElectrodeStepCode = 'P' THEN 4
						  WHEN ES.ElectrodeStepCode = 'S' THEN 5
						  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
						  END , ES.seq
END