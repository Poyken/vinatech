CREATE PROC [dbo].[usp_VN_IMPORTFINISHEDGOOD]  --EXEC usp_VN_IMPORTFINISHEDGOOD
@LotNo NVARCHAR(50)
AS
BEGIN

			CREATE TABLE #T4
			(
				ID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
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
					MAX(PackQty) AS LotQty,
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
					MAX(PackQty) AS LotQty,
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
				   

-----------------------------------------------------------------------------Gọi theo hàng module-------------------------------------------------------------------------------------------------
		
			SELECT
					TOP(1)
			        PackingID, 
					Barcode AS LotNo,
					MaterialName,
					MaterialCode,
					MAX(LotQty) AS LotQty,
					PartNo,
					CreateUserID,
					CONVERT(DATE,CreateDateTime) AS CreateDateTime,
					RIGHT(CreateDateTime,8) AS Times
					INTO #T3
				
		FROM
					STB_VN_NEW_PRINTER WITH(NOLOCK)
		WHERE
					Barcode = @LotNo AND LotQty =(SELECT MAX(LotQty) AS Loqty FROM STB_VN_NEW_PRINTER WITH(NOLOCK) WHERE  Barcode =@LotNo) 

		GROUP BY
					PackingID, 
					Barcode,
					MaterialName,
					MaterialCode,
					PartNo,
					CreateUserID,
					CreateDateTime

		ORDER BY CreateDateTime DESC

------------------------------------------------------------------------------------------------Gọi hàng to----------------------------------------------------------------------------------

--PackQty <= 120 AND

--SELECT * FROM STB_SavePackingTime_VVT WITH(NOLOCK) WHERE  LotNo ='VVKR013R036721'



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO #T4 SELECT * FROM  #T1
	INSERT INTO #T4  SELECT * FROM #T2
	INSERT INTO #T4 SELECT * FROM  #T3

			SELECT
					TOP(1)
					PackingID,
					LotNo,
					MaterialName,
					MaterialCode,
					MAX(LotQty) AS LotQty,
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
		
		DROP TABLE #T1
		DROP TABLE #T2
		DROP TABLE #T3
		DROP TABLE #T4

END