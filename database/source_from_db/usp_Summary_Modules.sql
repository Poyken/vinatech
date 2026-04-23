CREATE PROC usp_Summary_Modules
@pFromdateinput DATE = NULL,
@pTodateinput DATE = NULL,
@pTypeInput NVARCHAR(50) = NULL,
@pFromdateExp DATE = NULL,
@pTodateExp DATE = NULL
AS
BEGIN

		DECLARE @FromDate DATE = @pFromdateinput
		DECLARE @ToDate DATE = @pTodateinput
		DECLARE @FromDateExp DATE = @pFromdateExp
		DECLARE @ToDateExp DATE = @pTodateExp
		DECLARE @Input NVARCHAR(50) = @pTypeInput

			IF @Input = N'Xuất'

				BEGIN
						SELECT
								GROUPID,
								LOTNO,
								QTY,
								VOL,
								FWAR,
								PARTNO,
								SIZE,
								TYPEACTION_EXPORT,
								COUNTRY,
								DESCRIPTIONS_EXPORT,
								CreateDateTime,
								CreateUserID

								INTO #T1
						FROM		
								STB_VN_MODULE_EXPORT_IMPORT WITH(NOLOCK)

						WHERE 1 = 1

						AND
							   Flag = 1
						 
						SELECT
								*
						FROM

							#T1

						WHERE
							
							(
							((@FromDateExp IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDateExp)
						AND
							((@ToDateExp IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDateExp)
						
							)
				END

		ELSE IF @Input = N'Nhập'

				BEGIN
						SELECT
								GROUPID,
								LOTNO,
								QTY,
								VOL,
								FWAR,
								PARTNO,
								SIZE,
								TYPEACTION_IMPORT,
								COUNTRY,
								DESCRIPTIONS_IMPORT,
								DATEIMPORT,
								CREATEUSERIDIMPORT

						 INTO #T2

						FROM		
								STB_VN_MODULE_EXPORT_IMPORT WITH(NOLOCK)

						WHERE 1 = 1

						AND Flag = 1 --AND TYPEACTION_IMPORT IS NOT NULL

						SELECT
								*
						FROM #T2

						WHERE
							
							(
							((@FromDateExp IS NULL) OR CONVERT(DATE,DATEIMPORT) >= @FromDate)
						AND
							((@ToDateExp IS NULL) OR CONVERT(DATE,DATEIMPORT) <= @ToDate)
						
							)
				END
		ELSE

			BEGIN
					SELECT
							 GROUPID
							,LOTNO
							,QTY
							,VOL
							,FWAR
							,PARTNO
							,SIZE
							--,EXPORT
							,TYPEACTION_EXPORT
							--,IMPORT
							,TYPEACTION_IMPORT
							,DESCRIPTIONS_EXPORT
							,DESCRIPTIONS_IMPORT
							,COUNTRY
							,CreateDateTime
							,CreateUserID
							,DATEIMPORT
							,CREATEUSERIDIMPORT
							
					FROM

						STB_VN_MODULE_EXPORT_IMPORT WITH(NOLOCK)

					WHERE

						Flag = 1 
			END
END
