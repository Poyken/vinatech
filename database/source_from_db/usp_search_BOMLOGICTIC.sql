CREATE PROC usp_search_BOMLOGICTIC
@pTYPEBOM NVARCHAR(50) = NULL
AS
BEGIN
		IF @pTYPEBOM IS NULL

			BEGIN
					SELECT
							ID,
							PRODUCTIONNAME,
							ONCELLSIZE,
							PRODUCTIONCODE
							PART,
							MATERIALNAME,
							MATERIALCODE,
							USAGE,
							UNIT,
							TYPEBOM,
							NOTES,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							STB_VN_BOM_LOGITIC WITH(NOLOCK)
			END

		ELSE
			BEGIN
						SELECT
								ID,
								PRODUCTIONNAME,
								ONCELLSIZE,
								PRODUCTIONCODE
								PART,
								MATERIALNAME,
								MATERIALCODE,
								USAGE,
								UNIT,
								TYPEBOM,
								NOTES,
								IsUsed,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								STB_VN_BOM_LOGITIC WITH(NOLOCK)

						WHERE
								TYPEBOM = @pTYPEBOM
			END
END