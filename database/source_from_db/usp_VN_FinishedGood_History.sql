-- SELECT PackingID,Lotno FROM STB_MaterialLotInfo where Lotno = 'VVKT283R018611'
-- SELECT PackingID,Lotno FROM STB_MaterialLotInfo where Lotno = 'VVKU012R710602'

---- SELECT * FROM STB_MaterialLotInfo where Lotno = 'VVKU012R710605'

-- SELECT * FROM STB_MaterialLotInfo where PackingID = 'PKKU0200142'

-- SELECT PackingID,Lotno FROM STB_MaterialLotInfo where Lotno = 'VVKU012R710602'


--SELECT *  FROM  SmartFactoryIncubator.dbo.RCV_ASN WHERE PACK_ID = 'PKKU0200141'
--SELECT *  FROM  SmartFactoryIncubator.dbo.RCV_ASN WHERE PACK_ID = 'PKKU0200118'
--SELECT *  FROM  SmartFactoryIncubator.dbo.RCV_ASN WHERE PACK_ID = 'PKKU0200142'
--SELECT *  FROM  SmartFactoryIncubator.dbo.RCV_ASN WHERE PACK_ID = 'PKKU0200118'

--SELECT *  FROM  SmartFactoryIncubator.dbo.RCV_ASN WHERE PACK_ID = 'PKKU0200142'

CREATE PROC [dbo].[usp_VN_FinishedGood_History] -- EXEC usp_VN_FinishedGood_History '2020-12-01','2021-01-01'
@pFromDate DATE = NULL,
@pTodate DATE = NULL
AS
BEGIN
			  DECLARE @FromDate DATE = @pFromDate
			  DECLARE @ToDate DATE = @pTodate

			SELECT
				IDCODE,
				PublicCode,
				Country,
			    PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				ProductionSize,
				PackQty,
				EmpNo,
				CreatDatePacked AS PackedDate,
				RIGHT(CreatDatePacked,8) AS TimePacked,
				PartNo,
				TypeProduction,
				StatusSystem,
				Statusout,
				CreateDate AS CreateDateIn,
				RIGHT(CreateDate,8) AS TimeIn,
				USERID AS PersonIn,
				PersonExport,
				DateExport AS DateExports,
				RIGHT(DateExport,8) AS TimeOute,
				CreateDateChange AS CreateDateOut,
				RIGHT(CreateDateChange,8) AS TimeOuts,
				USERIDChange AS PersonOut,
				DateCapture,
				Descrption,
					CASE 
								WHEN Country = N'QA' THEN N'Nội Bộ'
								WHEN Country = N'Module' THEN N'Nội Bộ'
								WHEN Country = N'Đóng gói (Packing)' THEN N'Nội Bộ'
								WHEN Country = N'Sản Xuất (Production)' THEN N'Nội Bộ'
								WHEN Country = N'Mỹ (America)' THEN N'Xuất Bán'
								WHEN Country = N'Trung Quốc (China)' THEN N'Xuất Bán'
								WHEN Country = N'Pháp (France)' THEN N'Xuất Bán'
								WHEN Country = N'Đài loan (Taiwan)' THEN N'Xuất Bán'
								WHEN Country = N'Hàn Quốc (Korea)' THEN N'Xuất Bán'
								WHEN Country = N'Nga (Russia)' THEN N'Xuất Bán'
								WHEN Country = N'Bỉ (Belgium)' THEN N'Xuất Bán'
								WHEN Country = N'Hongkong' THEN N'Xuất Bán'
								WHEN Country = N'Ấn Độ (India)' THEN N'Xuất Bán'
								WHEN Country = N'Anh Quốc (English)' THEN N'Xuất Bán'
								WHEN Country = N'Thái Lan (Thalan)' THEN N'Xuất Bán'
								WHEN Country = N'Đức (Germany)' THEN N'Xuất Bán'
								WHEN Country = N'Singapore' THEN N'Xuất Bán'
								WHEN Country = N'SATCO(Sweden)' THEN N'Xuất Bán'
								WHEN Country = N'Hà lan (Netherlands)' THEN N'Xuất Bán'
								WHEN Country = N'Special IND(Italy)' THEN N'Xuất Bán'
								
						ELSE Country
						END AS Contrys

					INTO #T1
		FROM
				STB_VN_FINISHGOODS_CAPTURE  WITH(NOLOCK)
	    WHERE 
				Flag = 1

				SELECT
						IDCODE,
						PublicCode,
						Country,
						PackingID,
						LotNo,
						MaterialCode,
						MaterialName,
						ProductionSize,
						PackQty,
						EmpNo,
						PackedDate AS PackedDate,
						RIGHT(PackedDate,8) AS TimePacked,
						PartNo,
						TypeProduction,
						StatusSystem,
						Statusout,
						CreateDateIn,
						TimeIn,
						PersonIn,
						PersonExport,
						DateExports,
						TimeOute,
						CreateDateOut,
						TimeOuts,
						PersonOut,
						Descrption,
						DateCapture,
						Contrys
				FROM 
						#T1
				WHERE
						CONVERT(DATE,DateCapture) BETWEEN @FromDate AND @ToDate

						drop table #T1
												
END

-- SELECT * FROM STB_VN_FINISHGOODS_CAPTURE WHERE DateCapture >