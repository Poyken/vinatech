Create proc usp_VN_CheckExport
@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				PartNo,
				TypeProduction,
				StatusSystem,
				Statusout,
				CONVERT(DATE,CreateDate) AS CreateDateIn,
				RIGHT(CreateDate,8) AS TimeIn,
				USERID AS PersonIn,
				CONVERT(DATE, CreateDateChange) AS CreateDateOut,
				RIGHT(CreateDateChange,8) AS TimeOuts,
				USERIDChange AS PersonOut
		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
				LotNo = @LotNo AND Statusout IS NOT NULL
END