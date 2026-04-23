	CREATE PROC usp_VN_ScrapNew
	@pProcessUserID VARCHAR(20)
	AS
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	SELECT
			ID,
			LOTNO,
			NVLTPBTP,
			MODEL,
			PRODUCTIONNAME,
			UNIT,
			QtyActual,
			QtyMove,
			StausWait,
			StatusCancel,
			ReasonCancel
	FROM
			STB_VN_SCRAPLOT WITH(NOLOCK)
	WHERE
			CreateUserID = @ProcessUserID
			