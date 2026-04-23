CREATE PROC [dbo].[usp_VN_ShowAllFinishGood]
--@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				PartNo,
				TypeProduction,
				StatusSystem,
				StatusOut,
				CONVERT(DATE,CreateDate) AS CreateDateIn,
				RIGHT(CreateDate,8) AS TimeIn,
				USERID AS PersonIn,
				CONVERT(DATE,CreateDateChange) AS CreateDateOut,
				RIGHT(CreateDateChange,8) AS TimeOuts,
				USERIDChange AS PersonOut

		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		--WHERE
		--		LotNo = @LotNo

		select * from STB_VN_FINISHGOODS

END