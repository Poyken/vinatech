create PROC usp_VN_UpdateDelete -- exec usp_VN_SearchDelete 'VVKN223R050511','trantuan','2020-10-11'
@IDCODES NVARCHAR(50),
@Person NVARCHAR(50),
@DateTime DATETIME
AS
BEGIN
		DECLARE @IDCODE NVARCHAR(100)
		DECLARE @PackingID NVARCHAR(50)
		DECLARE @LotNos NVARCHAR(50)
		DECLARE @MaterialCode NVARCHAR(50)
		DECLARE @MaterialName NVARCHAR(50)
		DECLARE @PackQty INT 
		DECLARE @EmpNo NVARCHAR(50)
		DECLARE @CreatDatePacked NVARCHAR(50)
		DECLARE @PartNo NVARCHAR(50)
		DECLARE @PublicCode NVARCHAR(50)
		DECLARE @ProductionSize NVARCHAR(50)
		DECLARE @TypeProduction NVARCHAR(50)
		DECLARE @StatusSystem NVARCHAR(50)
		DECLARE @Statusout NVARCHAR(50)
		DECLARE @Country NVARCHAR(50)
		DECLARE @CreateDate DATETIME
		DECLARE @USERID NVARCHAR(50)
		DECLARE @CreateDateChange DATETIME
		DECLARE @USERIDChange NVARCHAR(50)
		DECLARE @PersonExport NVARCHAR(50)
		DECLARE @DateExport DATETIME
		DECLARE @MethodActions NVARCHAR(50)
		DECLARE @MethodActions1 NVARCHAR(50)
		DECLARE @Flag BIT

		SELECT
				@IDCODE = IDCODE,
				@PackingID = PackingID,
				@LotNos = LotNo,
				@MaterialCode = MaterialCode,
				@MaterialName = MaterialName,
				@PackQty = PackQty,
				@EmpNo = EmpNo,
				@CreatDatePacked = CreatDatePacked,
				@PartNo = PartNo,
				@PublicCode = @PublicCode,
				@ProductionSize = ProductionSize,
				@TypeProduction = TypeProduction,
				@StatusSystem = StatusSystem,
				@Statusout = Statusout,
				@Country = Country,
				@CreateDate = CreateDate,
				@USERID = USERID,
				@CreateDateChange = CreateDateChange,
				@USERIDChange = USERIDChange,
				@PersonExport = PersonExport,
				@DateExport = DateExport,
				@MethodActions = MethodActions,
				@MethodActions1 = MethodActions1,
				@Flag = Flag
		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
				IDCODE = @IDCODES

		UPDATE STB_VN_FINISHGOODS
		SET Flag = 0
		WHERE IDCODE = @IDCODES

		INSERT INTO STB_VN_FINISHGOODS_HISTORY
		(
	[IDCODE],
	[PackingID],
	[LotNo],
	[MaterialCode],
	[MaterialName],
	[PackQty],
	[EmpNo],
	[CreatDatePacked],
	[PartNo],
	[PublicCode],
	[ProductionSize],
	[TypeProduction],
	[StatusSystem],
	[Statusout],
	[Country],
	[CreateDate],
	[USERID],
	[CreateDateChange],
	[USERIDChange],
	[PersonExport],
	[DateExport],
	[MethodActions],
	[MethodActions1],
	[Flag],
	[PersonAction],
	[DateAction],
	[TypeAction]
		)
		VALUES
		(
		@IDCODE,@PackingID,@LotNos,@MaterialCode,@MaterialName,@PackQty,@EmpNo,@CreatDatePacked,@PartNo,@PublicCode,@ProductionSize,
		@TypeProduction,@StatusSystem,@Statusout,@Country,@CreateDate,@USERID,@CreateDateChange,@USERIDChange,@PersonExport,
		@DateExport,@MethodActions,@MethodActions1,@Flag,@Person,@DateTime,'Delete'
		)
END