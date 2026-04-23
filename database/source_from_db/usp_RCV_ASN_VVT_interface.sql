CREATE PROC [dbo].[usp_RCV_ASN_VVT_interface]
AS
BEGIN
	Declare @RcvOrderNo VARCHAR(20)
	       ,@PackingID VARCHAR(20)
		   ,@RcvType VARCHAR(20)
		   ,@MaterialCode VARCHAR(20)
		   ,@MaterialName VARCHAR(200)
		   ,@PackingQty BIGINT
		   ,@Status VARCHAR(10)
		   ,@CreateDateTime DATETIME

	DECLARE cur CURSOR FOR

		SELECT TOP 10 PACK_ID, RCV_TYPE, ITM_CD, ITM_NM, ITM_QTY
			  ,STATUS, CRT_DT
		  FROM SmartFactoryIncubator.dbo.RCV_ASN
		 WHERE ITM_CD IN (SELECT MaterialCode FROM STB_MaterialMaster)
		   AND CRT_DT >= DATEADD(day, -1, GETDATE())
		   AND PACK_ID NOT IN (SELECT PACK_ID FROM RCV_ASN)
		ORDER BY CRT_DT

	OPEN cur

	FETCH NEXT FROM cur INTO  @PackingID
							 ,@RcvType
							 ,@MaterialCode
							 ,@MaterialName
							 ,@PackingQty
							 ,@Status
							 ,@CreateDateTime

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 신규 채번
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'RCV_ASN',@RcvOrderNo OUTPUT
		-- 입력
		INSERT INTO RCV_ASN (RCV_ORD_NO
                            ,PACK_ID
                            ,RCV_TYPE
                            ,ITM_CD
                            ,ITM_NM
                            ,ITM_QTY
                            ,STATUS
                            ,CRT_DT)
			              VALUES (@RcvOrderNo
								 ,@PackingID
								 ,@RcvType
								 ,@MaterialCode
								 ,REPLACE(@MaterialName, ',', '_')
								 ,@PackingQty
								 ,0
								 ,GETDATE())
	
		FETCH NEXT FROM cur INTO  @PackingID
								 ,@RcvType
								 ,@MaterialCode
								 ,@MaterialName
								 ,@PackingQty
								 ,@Status
								 ,@CreateDateTime
	END

	CLOSE cur
	DEALLOCATE cur
END