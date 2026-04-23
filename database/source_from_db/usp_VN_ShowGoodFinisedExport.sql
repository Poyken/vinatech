CREATE proc [dbo].[usp_VN_ShowGoodFinisedExport] -- exec usp_VN_ShowGoodFinisedExport 'VVKQ123R010519'
@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT 
				TOP(1)
				IDCODE,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				PartNo,
				TypeProduction,
				StatusSystem,
				CONVERT(DATE,CreateDate) AS CreateDate,
				USERID,
				Statusout

		FROM
				 STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE

			LotNo	= @LotNo AND Statusout IS NULL

		ORDER BY CreateDate ASC
				
END