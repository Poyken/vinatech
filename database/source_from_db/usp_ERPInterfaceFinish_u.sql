CREATE PROC usp_ERPInterfaceFinish_u @idx BIGINT
AS
BEGIN 
	-- Interface 결과 업데이트
	UPDATE STB_ERP_INTERFACE 
		SET InterfaceFinYn = 'Y'
			,InterfaceDateTime = getdate()
		WHERE IDX = @Idx
END