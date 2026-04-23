

-- select top(5000)* from STB_ProductsReceiptHist where codeid is not null

----alter table STB_ProductsReceiptHist
----add
----		CODEID NVARCHAR(100) NULL


--select * from STB_VN_FINISHGOODS_BG

CREATE PROC [dbo].[usp_vn_Transfer_FG00_To_C560] -- EXEC usp_vn_Transfer_FG00_To_C560
WITH RECOMPILE
as
begin
		DECLARE @IDCODE NVARCHAR(50)
		DECLARE @LOTNO NVARCHAR(50)
		DECLARE @MATERIALCODE NVARCHAR(50)
		DECLARE @PARTNO NVARCHAR(50)
		DECLARE @PACKQTY NVARCHAR(20)
		DECLARE @CUSTOMERNAME NVARCHAR(50)
		DECLARE @Country NVARCHAR(50)
		DECLARE @TransportationMethodCode NVARCHAR(50)
		DECLARE @SoInVoice NVARCHAR(50)
		DECLARE @PersonExport NVARCHAR(50)
		DECLARE @DateExport NVARCHAR(50)
		DECLARE @CreateDateOut  NVARCHAR(50)
		DECLARE @WorkCenterCode NVARCHAR(20) = 'VVT_F2'
		DECLARE @CNT INT

		--DECLARE Cusproduction CURSOR FOR

		--SELECT
		--		IDCODE,
		--		LotNo,
		--		MaterialCode,
		--		PartNo,
		--		PackQty,
		--		CUSTOMERNAME,
		--		Country,

		--		CASE

		--			WHEN TRANSPORT = 'AIR' THEN  '01'
		--			WHEN TRANSPORT = 'Etc' THEN  '03'
		--			WHEN TRANSPORT = 'Ship' THEN  '02'
		--			WHEN TRANSPORT = 'SEA' THEN  '04'

		--	   ELSE ''

		--	   END AS 'TransportationMethodCode',

		--		SoInVoice,
		--		PersonExport,
		--		DateExport,
		--		CONVERT(DATE,CreatDatePacked) as 'CreatDatePacked',
		--		@WorkCenterCode
				
		--FROM 
		--		STB_VN_FINISHGOODS_BG  WITH(NOLOCK)

		--WHERE
		--		TYPEEXPORT = 'XB'


		--OPEN Cusproduction

		--FETCH NEXT FROM Cusproduction

		--INTO  @IDCODE,@LOTNO,@MATERIALCODE,@PARTNO,@PACKQTY,@CUSTOMERNAME,@Country,@TransportationMethodCode,@SoInVoice,@PersonExport, @DateExport, @CreateDateOut,@WorkCenterCode

		--WHILE @@FETCH_STATUS = 0

		--BEGIN

		--		SELECT @CNT = COUNT(*) FROM STB_ProductsReceiptHist WHERE CODEID = @IDCODE

		--			IF @CNT = 0
						
		--				BEGIN
		--						INSERT INTO STB_ProductsReceiptHist (CODEID,Barcode,MaterialCode,VNNameProduct,ProdQty,Customer,Nation,TransportationMethodCode,InvoiceNo,PackingDate,CreateUserID,CreateDateTime,WorkCenterCode) 
		--							VALUES (@IDCODE,@LOTNO,@MATERIALCODE,@PARTNO,@PACKQTY,@CUSTOMERNAME,@Country,@TransportationMethodCode,@SoInVoice,@DateExport,@PersonExport,@CreateDateOut,@WorkCenterCode)
		--				END

		--			ELSE

		--				BEGIN
		--						UPDATE STB_ProductsReceiptHist

		--						SET
		--								Customer = @CUSTOMERNAME,
		--								Nation = @Country,
		--								TransportationMethodCode = @TransportationMethodCode,
		--								InvoiceNo = @SoInVoice,
		--								WorkCenterCode = @WorkCenterCode

		--						WHERE 
		--								CODEID = @IDCODE
		--				END

		--				FETCH NEXT FROM Cusproduction
		--				INTO  @IDCODE,@LOTNO,@MATERIALCODE,@PARTNO,@PACKQTY,@CUSTOMERNAME,@Country,@TransportationMethodCode,@SoInVoice,@DateExport,@PersonExport,@CreateDateOut,@WorkCenterCode
		--END

		--CLOSE Cusproduction              
		--DEALLOCATE Cusproduction   

		-- change query from cursor to merge into #240613 By Jackaroe
		MERGE INTO STB_ProductsReceiptHist A
		USING (
				SELECT
						IDCODE,
						LotNo,
						MaterialCode,
						PartNo,
						PackQty,
						CUSTOMERNAME,
						Country,

						CASE

							WHEN TRANSPORT = 'AIR' THEN  '01'
							WHEN TRANSPORT = 'Etc' THEN  '03'
							WHEN TRANSPORT = 'Ship' THEN  '02'
							WHEN TRANSPORT = 'SEA' THEN  '04'

					   ELSE ''

					   END AS 'TransportationMethodCode',

						SoInVoice,
						PersonExport,
						DateExport,
						CONVERT(DATE, ISNULL(CreatDatePacked, GETDATE())) as 'CreatDatePacked',
						@WorkCenterCode AS WorkCenterCode
				
				FROM 
						STB_VN_FINISHGOODS_BG  WITH(NOLOCK)

				WHERE
						TYPEEXPORT = 'XB'
		) B
		ON A.CODEID = B.IDCODE
		WHEN MATCHED THEN
			UPDATE SET
						A.Customer = B.CUSTOMERNAME,
						A.Nation = B.Country,
						A.TransportationMethodCode = B.TransportationMethodCode,
						A.InvoiceNo = B.SoInVoice,
						A.WorkCenterCode = B.WorkCenterCode
		WHEN NOT MATCHED THEN
			INSERT (CODEID,Barcode,MaterialCode,VNNameProduct,ProdQty
			       ,Customer,Nation,TransportationMethodCode,InvoiceNo,PackingDate
				   ,CreateUserID,CreateDateTime,WorkCenterCode)
			 VALUES (B.IDCODE, B.LotNo, B.MaterialCode, B.PartNo, B.PackQty
			        ,B.CUSTOMERNAME, B.Country, B.TransportationMethodCode, B.SoInVoice, B.DateExport
					,B.PersonExport, B.CreatDatePacked, B.WorkCenterCode)
		;
END