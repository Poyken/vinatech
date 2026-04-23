CREATE proc [dbo].[usp_MaterialMaster_interface] 
 @pMaterialCode VARCHAR(50)
,@pIUD_FLAG VARCHAR(10)
AS
BEGIN
	DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @MaterialName VARCHAR(200)
	DECLARE @MaterialTypeCode VARCHAR(20)
	DECLARE @MaterialUnit VARCHAR(10)
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeUserID VARCHAR(20)

	SET @IUD_FLAG = @pIUD_FLAG
	SET @MaterialCode = @pMaterialCode

	SELECT @MaterialName = MaterialName
	      ,@MaterialTypeCode = MaterialTypeCode
		  ,@MaterialUnit = MaterialUnit
		  ,@CreateUserID = CreateUserID
		  ,@ChangeUserID = ChangeUserID
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = @MaterialCode

	SET @MaterialTypeCode = CASE @MaterialTypeCode WHEN 'FERT' THEN 1 
	                                               WHEN 'HALB' THEN 4
												   WHEN 'HAWA' THEN 2
												   WHEN 'MODULE' THEN 1
												   WHEN 'ROH' THEN 3
												   ELSE 6
												   END
    
	INSERT INTO STB_ERP_INTERFACE (InterfaceName, IUD_FLAG, EIInfText01, EIInfText02, EIInfText03
		                             , EIInfText04, EIInfDate01, EIInfText05, EIInfText06, EIInfDate02
									 , EIInfText07, EIInfDate03, EIInfText08)
			SELECT 'MaterialMaster', @IUD_FLAG, @MaterialCode, @MaterialName, @MaterialTypeCode
			     , @MaterialUnit, getdate(), 'Y', @MaterialName, getdate()
				 , LEFT(@CreateUserID, 12), getdate(), LEFT(@ChangeUserID, 12)
END
