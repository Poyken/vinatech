CREATE PROC [dbo].[usp_VN_Display_FinishedGoods] --EXEC usp_VN_Display_FinishedGoods 'VVKQ133R010514'
@LotNo NVARCHAR(50)
AS
BEGIN

DECLARE @isPrinteds BIT

SELECT 
		@isPrinteds=isPrinted
FROM
		STB_SavePackingTime_VVT WITH(NOLOCK)
WHERE 
		 LotNo = @LotNo 

		
	IF (@isPrinteds ='False')

		BEGIN

		SELECT
				    TOP(1)
					LotNo,
					MaterialName,
					MaterialCode,
					MAX(PackQty) AS LotQty,
				    PartNo,
					EmpNo AS CreateUserID,
					CONVERT(DATE,PrintTime) AS CreateDateTime,
					RIGHT(PrintTime,8) AS Times,
					isPrinted

				
		FROM
					STB_SavePackingTime_VVT WITH(NOLOCK)
		WHERE
					 LotNo = @LotNo --AND isPrinted = @isPrinteds
								
		GROUP BY
					LotNo,
					MaterialName,
					MaterialCode,
				   PartNo,
				   EmpNo,
				   PrintTime,
				   isPrinted

		--ORDER BY     CreateDateTime ASC
		END

		ELSE IF (@isPrinteds ='True')
			BEGIN
					SELECT
					TOP(1)
					LotNo,
					MaterialName,
					MaterialCode,
					MAX(PackQty) AS LotQty,
				    PartNo,
					EmpNo AS CreateUserID,
					CONVERT(DATE,PrintTime,8) AS CreateDateTime,
					RIGHT(PrintTime,8) AS Times,
					isPrinted

				
		FROM
					STB_SavePackingTime_VVT WITH(NOLOCK)
		WHERE
					 LotNo = @LotNo AND PackQty =(SELECT MAX(PackQty) FROM STB_SavePackingTime_VVT WITH(NOLOCK) WHERE LotNo=@LotNo)
		GROUP BY
					LotNo,
					MaterialName,
					MaterialCode,
					EmpNo,
				    PartNo,
				    PrintTime,
				    isPrinted
		--ORDER BY  
		--			 CreateDateTime ASC
		END
END				
				
