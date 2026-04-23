CREATE PROC [dbo].[usp_VN_CheckImportFinishedGood]
@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT
				TypeProduction,
				StatusSystem,
				CONVERT(DATE,CreateDate) DateIm,
				RIGHT(CreateDate,8) TimeIm,
				USERID,
				PackQty

		FROM
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE		
				LotNo = @LotNo AND Statusout IS NOT NULL
				
END