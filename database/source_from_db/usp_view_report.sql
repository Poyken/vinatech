CREATE PROC [dbo].[usp_view_report]	 -- EXEC usp_view_report '2021-03-19','2021-03-19','','','trantuan',N'Nhập'
@pProcessUserID VARCHAR(20) = null,
@pFrdate DATE = NULL,
@pTodate DATE = NULL,
@pFdateexp DATE = NULL,
@pTdateexp DATE = NULL,
@pUser NVARCHAR(50) = NULL,
@pType NVARCHAR(50) = NULL
AS
BEGIN

	DECLARE @Puserid NVARCHAR(50) = @pProcessUserID
	DECLARE @KeyID NVARCHAR(10)
	DECLARE @Year NVARCHAR(10)
	DECLARE @Moth NVARCHAR(5)
	DECLARE @Day NVARCHAR(5)
	DECLARE @Hour NVARCHAR(50)
	DECLARE @Minutes NVARCHAR(50)
	DECLARE @Second NVARCHAR(5)
	DECLARE @Publiccode NVARCHAR(50)
	SELECT @Hour = LEFT(GETDATE(),4)
	SELECT @Minutes = DATEPART(MINUTE,GETDATE())
	
	SET @KeyID = 'VN'
	SET @Year= YEAR(GETDATE())
	SET @Moth = MONTH(GETDATE())
	SET @Hour = LEFT(GETDATE(),4)
	SET @Minutes = DATEPART(MINUTE,GETDATE())
	SET @Second = DATEPART(SECOND,GETDATE())
	SET @Day = DAY(GETDATE())

	

	SET @Publiccode = REPLACE(@KeyID + @Year + @Moth + @Day + @Hour + @Minutes + @Second,' ', '')

		DECLARE @FromDate DATE = @pFrdate
		DECLARE @ToDate DATE = @pTodate
		DECLARE @FrDateExp DATE = @pFdateexp
		DECLARE @TodateExp DATE = @pTdateexp
		DECLARE @Input NVARCHAR(50) = @pType
	    DECLARE @Users NVARCHAR(50) =  @pUser

		DECLARE @PublicCodeS NVARCHAR(50)
		DECLARE @PartNoS NVARCHAR(50)
		DECLARE @PackQtyS INT
		DECLARE @StatussS NVARCHAR(20)
		DECLARE @Dates DATETIME
		DECLARE @UsersS NVARCHAR(50)
		DECLARE @GROUPIDS NVARCHAR(50)
		DECLARE @UnitS NVARCHAR(5)
		DECLARE @TYPEREPORT NVARCHAR(50)
		DECLARE @CreateDates DATETIME

		IF @Input = N'Nhập'

		BEGIN

		DECLARE Cusproduction CURSOR FOR

					SELECT
								
							
								'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
								'' + replace(PartNo, ' ', '') + '' AS PartNo,
								SUM(PackQty) AS PackQty,
								StatusSystem AS Statuss,
								CONVERT(DATE,CreateDate) as Dates,
								USERID as Users,
								@Publiccode AS Pubcode,
								'PCS' AS Unit,
								'Report' AS CommandType,
								GETDATE(),
								@FromDate,
								@ToDate,
								@Puserid
					
					FROM
							    STB_VN_FINISHGOODS  WITH(NOLOCK)
					
						WHERE
								(
										((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
									AND
										((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
								)

								AND  USERID = @Users AND StatusSystem IS NOT NULL AND Flag = 1

								GROUP BY PublicCode,PartNo,StatusSystem,CONVERT(DATE,CreateDate),USERID


		
		OPEN Cusproduction

		FETCH NEXT FROM Cusproduction
		 
		 INTO @PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FromDate,@ToDate,@Puserid

		 WHILE @@FETCH_STATUS = 0
			BEGIN
					INSERT INTO STB_VN_IssueReceipt(PUBLICCODE,PARTNO,PACKQTY,STATUSISSUERECEIPT,DATEEXPORT_IMPORT,USERCRATE,GROUPID,UNIT,TYPEREPORT,CREATEDATE,FROMDATE,TODATE,CREATEUSERID) VALUES (@PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FromDate,@ToDate,@Puserid)
					
					FETCH NEXT FROM Cusproduction
					INTO @PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FromDate,@ToDate,@Puserid
			END

				CLOSE Cusproduction              
			   DEALLOCATE Cusproduction   


			   	SELECT
								
							
								'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
								'' + replace(PartNo, ' ', '') + '' AS PartNo,
								SUM(PackQty) AS PackQty,
								StatusSystem AS Statuss,
								CONVERT(DATE,CreateDate) as Dates,
								USERID as Users,
								@Publiccode AS Pubcode,
								'PCS' AS Unit,
								'Report' AS CommandType,
								GETDATE(),
								@FromDate,
								@ToDate,
								@Puserid
					
					FROM
							    STB_VN_FINISHGOODS  WITH(NOLOCK)
					
						WHERE
								(
										((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
									AND
										((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
								)

								AND  USERID = @Users AND StatusSystem IS NOT NULL AND Flag = 1

								GROUP BY PublicCode,PartNo,StatusSystem,CONVERT(DATE,CreateDate),USERID
		END

	ELSE IF @Input = N'Xuất'

			BEGIN

					DECLARE Cusproductions CURSOR FOR

	SELECT
								'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
								'' + replace(PartNo, ' ', '') + '' AS PartNo,
								SUM(PackQty) AS PackQty,
								Statusout AS Statuss,
								CONVERT(DATE,DateExport) as Dates, 
								PersonExport as Users,
								@Publiccode AS Pubcode,
								'PCS' AS Unit,
								'Report' AS CommandType,
								GETDATE(),
								@FrDateExp,
								@TodateExp,
								@Puserid
					
					FROM
							    STB_VN_FINISHGOODS  WITH(NOLOCK)
					WHERE
								(
										((@FrDateExp IS NULL) OR CONVERT(DATE,DateExport) >= @FrDateExp)
									AND
										((@TodateExp IS NULL) OR CONVERT(DATE,DateExport) <= @TodateExp)
								)

								AND  USERID = @Users AND Statusout IS NOT NULL AND Flag = 1

					GROUP BY PublicCode,PartNo,Statusout,CONVERT(DATE,DateExport),PersonExport

		OPEN Cusproductions

		FETCH NEXT FROM Cusproductions
		 
		 INTO @PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FrDateExp,@TodateExp,@Puserid

		 WHILE @@FETCH_STATUS = 0
			BEGIN
					INSERT INTO STB_VN_IssueReceipt(PUBLICCODE,PARTNO,PACKQTY,STATUSISSUERECEIPT,DATEEXPORT,USERCRATE,GROUPID,UNIT,TYPEREPORT,CREATEDATE,FROMDATE,TODATE,CREATEUSERID) VALUES (@PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FrDateExp,@TodateExp,@Puserid)
					
					FETCH NEXT FROM Cusproductions
					INTO @PublicCodeS,@PartNoS,@PackQtyS,@StatussS,@Dates,@UsersS,@GROUPIDS,@UnitS,@TYPEREPORT,@CreateDates,@FrDateExp,@TodateExp,@Puserid
			END

				CLOSE Cusproductions 
			   DEALLOCATE Cusproductions  


			   SELECT
								'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
								'' + replace(PartNo, ' ', '') + '' AS PartNo,
								SUM(PackQty) AS PackQty,
								Statusout AS Statuss,
								CONVERT(DATE,DateExport) as Dates, 
								PersonExport as Users,
								@Publiccode AS Pubcode,
								'PCS' AS Unit,
								'Report' AS CommandType,
								GETDATE(),
								@FrDateExp,
								@TodateExp,
								@Puserid
							
					
					FROM
							    STB_VN_FINISHGOODS  WITH(NOLOCK)
					WHERE
								(
										((@FrDateExp IS NULL) OR CONVERT(DATE,DateExport) >= @FrDateExp)
									AND
										((@TodateExp IS NULL) OR CONVERT(DATE,DateExport) <= @TodateExp)
								)

								AND  USERID = @Users AND Statusout IS NOT NULL AND Flag = 1

					GROUP BY PublicCode,PartNo,Statusout,CONVERT(DATE,DateExport),PersonExport

			END
			
			--ELSE 
			--	BEGIN
			--			SELECT
							
							
			--					'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
			--					'' + replace(PartNo, ' ', '') + '' AS PartNo,
			--					PackQty,
			--					Statusout AS Statuss,
			--					DateExport as Dates, 
			--					PersonExport as Users,
			--						@Publiccode AS Pubcode,
			--						'PCS' AS Unit,
			--					'Report' AS CommandType,
			--					GETDATE(),
			--					@FrDateExp,
			--					@TodateExp,
			--					@Puserid
			--			FROM
			--				    STB_VN_FINISHGOODS  WITH(NOLOCK)
						
			--	END
END


--ALTER TABLE STB_VN_IssueReceipt
--ADD
--		USERCRATE NVARCHAR(50) NULL DELETE STB_VN_IssueReceipt