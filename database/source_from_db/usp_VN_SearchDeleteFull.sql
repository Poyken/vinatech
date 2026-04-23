Create PROC usp_VN_SearchDeleteFull
@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT 
				IDCODE,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				CreatDatePacked,
				PartNo,
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				Statusout,
				Country,
				CreateDate,
				USERID,
				CreateDateChange,
				USERIDChange,
				PersonExport,
				DateExport,
				MethodActions,
				MethodActions1,
				Flag
		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
				LotNo = @LotNo AND Flag = 1
END


