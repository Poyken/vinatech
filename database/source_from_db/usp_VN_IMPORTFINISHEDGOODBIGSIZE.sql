CREATE PROC [dbo].[usp_VN_IMPORTFINISHEDGOODBIGSIZE]  -- EXEC usp_VN_IMPORTFINISHEDGOODBIGSIZE 'VVKQ273R036758'
@LotNo NVARCHAR(50)
AS
BEGIN

			CREATE TABLE #T4
			(
				--ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
				PackingID NVARCHAR(50) NULL, 
				LotNo NVARCHAR(50) NULL,
				MaterialName NVARCHAR(50) NULL,
				MaterialCode NVARCHAR(50) NULL,
				LotQty INT NULL,
				PartNo NVARCHAR(50) NULL,
				CreateUserID  NVARCHAR(50) NULL,
				CreateDateTime NVARCHAR(50) NULL,
				Times TIME NULL
			)


			CREATE TABLE #T5
			(
				--ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
				PackingID NVARCHAR(50) NULL, 
				LotNo NVARCHAR(50) NULL,
				MaterialName NVARCHAR(50) NULL,
				MaterialCode NVARCHAR(50) NULL,
				LotQty INT NULL,
				PartNo NVARCHAR(50) NULL,
				CreateUserID  NVARCHAR(50) NULL,
				CreateDateTime NVARCHAR(50) NULL,
				Times TIME NULL
			)

DECLARE @isPrinteds BIT

SELECT 
		@isPrinteds=isPrinted
FROM
		STB_SavePackingTime_VVT WITH(NOLOCK)
WHERE 
		 LotNo = @LotNo 

	
		SELECT
				    TOP(1)
					PackingID, 
					LotNo,
					MaterialName,
					MaterialCode,
					SUM(PackQty) AS LotQty,
				    PartNo,
					EmpNo AS CreateUserID,
					CONVERT(DATE,PrintTime) AS CreateDateTime,
					RIGHT(PrintTime,8) AS Times
					INTO #T1
				
		FROM
					STB_SavePackingTime_VVT WITH(NOLOCK)
		WHERE
					 LotNo = @LotNo AND isPrinted = 0
								
		GROUP BY
					PackingID, 
					LotNo,
					MaterialName,
					MaterialCode,
				    PartNo,
				    EmpNo,
				    PrintTime

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
			SELECT
					TOP(1)
					PackingID, 
					LotNo,
					MaterialName,
					MaterialCode,
					SUM(PackQty) AS LotQty,
				    PartNo,
					EmpNo AS CreateUserID,
					CONVERT(DATE,PrintTime,8) AS CreateDateTime,
					RIGHT(PrintTime,8) AS Times
					INTO #T2
				
		FROM
					STB_SavePackingTime_VVT WITH(NOLOCK)
		WHERE
					 isPrinted = 1 AND LotNo = @LotNo AND PackQty =(SELECT MAX(PackQty) FROM STB_SavePackingTime_VVT WITH(NOLOCK) WHERE LotNo=@LotNo) 
		GROUP BY
					PackingID, 
					LotNo,
					MaterialName,
					MaterialCode,
					EmpNo,
				    PartNo,
				    PrintTime
				   

	INSERT INTO #T4 SELECT * FROM  #T1
	INSERT INTO #T4  SELECT * FROM #T2
	

			SELECT
					TOP(1)
					PackingID,
					LotNo,
					MaterialName,
					MaterialCode,
					SUM(LotQty / 5 ) AS LotQty ,
					PartNo,
					CreateUserID,
					CreateDateTime,
					Times
					
			FROM
					#T4
		    WHERE

				 LotNo = @LotNo

			GROUP BY
					
					PackingID,
					LotNo,
					MaterialName,
					MaterialCode,
					PartNo,
					CreateUserID,
					CreateDateTime,
					Times
		
		--DECLARE @Counter INT

		--SET @Counter = 1

		--		WHILE (@Counter <= 5 )

		--		BEGIN
		--		DECLARE @Pid NVARCHAR(50)
		--		DECLARE @LotNos NVARCHAR(50)
		--		DECLARE @MaterialName NVARCHAR(50)
		--		DECLARE @MaterialCode NVARCHAR(50)
		--		DECLARE @LotQtys INT
		--		DECLARE @Part NVARCHAR(50)
		--		DECLARE @CreateUserID NVARCHAR(50)
		--		DECLARE @CreatUser NVARCHAR(50)
		--		DECLARE @CreateDateTime  NVARCHAR(50)
		--		DECLARE @Time  NVARCHAR(50)

		--				SELECT
		--						TOP(1)
		--						@Pid = PackingID,
		--						@LotNos = LotNo,
		--						@MaterialName = MaterialName,
		--						@MaterialCode = MaterialCode,
		--						@LotQtys = SUM(LotQty / 5) ,
		--						@Part =PartNo,
		--						@CreatUser = CreateUserID,
		--						@CreateDateTime = CreateDateTime,
		--						@Time = Times
								
		--				FROM
		--						#T4
		--			WHERE
		--					 LotNo = @LotNo

					
		--	GROUP BY
					
		--			PackingID,
		--			LotNo,
		--			LotQty,
		--			MaterialName,
		--			MaterialCode,
		--			PartNo,
		--			CreateUserID,
		--			CreateDateTime,
		--			Times

		--			SET @Counter = @Counter + 1

		--			INSERT INTO #T5 (PackingID,LotNo,MaterialName,MaterialCode,LotQty,PartNo,CreateUserID,CreateDateTime,Times) VALUES (@Pid,@LotNos,@MaterialName,@MaterialCode,@LotQtys,@Part,@CreatUser,@CreateDateTime,@Time)

		--		END


			--	SELECT
					
			--		PackingID,
			--		LotNo,
			--		MaterialName,
			--		MaterialCode,
			--	    LotQty ,
			--		PartNo,
			--		CreateUserID,
			--		CreateDateTime,
			--		Times
						
			--FROM
			--		#T5
		 --   WHERE

			--	 LotNo = @LotNo


		DROP TABLE #T1
		DROP TABLE #T2
		DROP TABLE #T4
		DROP TABLE #T5
END


--select * from STB_SavePackingTime_VVT