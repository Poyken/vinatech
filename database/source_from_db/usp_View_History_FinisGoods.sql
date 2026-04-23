CREATE PROC usp_View_History_FinisGoods
@pFrom DATETIME = NULL,
@pTo DATETIME = NULL
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
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				Statusout,
				Country,
				MethodActions
		FROM
				STB_VN_FINISHGOODS_CAPTURE WITH(NOLOCK)
		WHERE
				 CONVERT(DATE,DateCapture) BETWEEN @pFrom AND @pTo
END