
	CREATE PROC usp_VN_DetialScrapNew
	AS
	BEGIN
			SELECT
					ID,
					CODESCRAPLOT,
					LOTNO,
					NVLTPBTP,
					MODEL,
					PRODUCTIONNAME,
					UNIT,
					QtyActual,
					QtyMove,
					StausWait,
					[StatusCancel],
					[ReasonCancel],
					[CreateDateTime],
					RIGHT(CreateDateTime,8) AS CreateTime,
					[CreateUserID],
					[ChangeDateTime],
					RIGHT(ChangeDateTime,8) AS ChangeTime,
					[ChangeUserID]
			FROM
					STB_VN_SCRAPLOT WITH(NOLOCK)
	END