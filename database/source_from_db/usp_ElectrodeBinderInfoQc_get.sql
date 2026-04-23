CREATE PROC usp_ElectrodeBinderInfoQc_get
AS
BEGIN
	SELECT EMSI.ElectrodeLotNumber
		  ,EMSI.ElectrodeMaterialCode
		  ,MM.MaterialName
	  FROM STB_ElectrodeMixStepInfo EMSI
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON EMSI.ElectrodeMaterialCode = MM.MaterialCode
	 WHERE 1 = 1
	   AND MM.ProductGroupCode = 'BINDER'
	 ORDER BY EMSI.ElectrodeLotNumber
END