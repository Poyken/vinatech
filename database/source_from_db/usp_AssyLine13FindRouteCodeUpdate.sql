CREATE PROC usp_AssyLine13FindRouteCodeUpdate
AS
BEGIN
	UPDATE STB_DefectRepairInfo
	   SET FindRouteCode = LEFT(DefectCode, 4)
	 WHERE FindRouteCode <> LEFT(DefectCode, 4)
	   AND CompanyCode = 'VNT'
	   AND FindLineCode = 'ASSYLINE-13'
	   AND DefectCode LIKE 'E%'
	   AND MaterialCode = 'ECVT30-258'
	   AND FindJobdate > DATEADD(day, -2, GETDATE())
END