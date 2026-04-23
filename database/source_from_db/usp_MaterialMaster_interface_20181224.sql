CREATE proc [dbo].[usp_MaterialMaster_interface_20181224] 
 @pMaterialCode VARCHAR(50)
,@p@IUD_FLAG VARCHAR(10)
AS
BEGIN
	DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @MaterialName VARCHAR(200)
	DECLARE @MaterialTypeCode VARCHAR(20)
	DECLARE @MaterialUnit VARCHAR(10)
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeUserID VARCHAR(20)

	SET @IUD_FLAG = @p@IUD_FLAG
	SET @MaterialCode = @p@IUD_FLAG

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
    
	IF @IUD_FLAG = 'INSERT'
	BEGIN
		INSERT INTO erpsvr.erpdb.dbo.product (PRODCD, PRODNM, ACTGBN, PUNIT, 적용일, USEGBN, PNO, 입력일시, 입력자, 수정일시, 수정자)
			SELECT @MaterialCode, @MaterialName, @MaterialTypeCode, @MaterialUnit, getdate(), 'Y', @MaterialName, getdate(), LEFT(@CreateUserID, 12), getdate(), LEFT(@ChangeUserID, 12)
	END

	IF @IUD_FLAG = 'UPDATE'
	BEGIN
		UPDATE erpsvr.erpdb.dbo.product 
		   SET PRODNM = @MaterialName
			  ,ACTGBN = @MaterialTypeCode
			  ,PUNIT = @MaterialUnit
			  ,PNO = @MaterialName
			  ,수정일시 = getdate()
			  ,수정자 = LEFT(@ChangeUserID, 12)
		 WHERE PRODCD = @MaterialCode
	END

	IF @IUD_FLAG = 'DELETE'
	BEGIN
		UPDATE erpsvr.erpdb.dbo.product 
		   SET USEGBN = 'N'
			  ,수정일시 = getdate()
			  ,수정자 = LEFT(@ChangeUserID, 12)
		 WHERE PRODCD = @MaterialCode
	END
END
