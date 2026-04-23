CREATE PROC [dbo].[usp_VN_New_Printer] -- EXEC [usp_VN_New_Printer]'VEC5R4504QG-O', '0813'
@pProcessUserID VARCHAR(20) = NULL,
--@pPartNo NVARCHAR(100) = NULL,
--@pRating NVARCHAR(50) = NULL,
@pBarcode NVARCHAR(100) = NULL,
@pLabelQty INT = NULL
--@pLotQty NVARCHAR(50) = NULL,
--@pLine NVARCHAR(50) = NULL
AS
BEGIN

		
		
		--DECLARE @PartNo VARCHAR(100) = @pPartNo --CASE WHEN ISNULL(@pPartNo,'') = '' THEN '%' ELSE @pPartNo END
		--DECLARE @Rating VARCHAR(100) = @pRating --CASE WHEN ISNULL(@pRating,'') = '' THEN '%' ELSE @pRating END
			DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
			DECLARE @Barcode NVARCHAR(50) = @pBarcode
			DECLARE @LabelQty INT = @pLabelQty
			DECLARE @V NVARCHAR(100)
			DECLARE @F NVARCHAR(100)
			DECLARE @R NVARCHAR(100)
			DECLARE @P NVARCHAR(100)
			DECLARE @QTY INT
			DECLARE @PKID NVARCHAR(100)
			DECLARE @LOTNO NVARCHAR(50)
			DECLARE @MaterialCode NVARCHAR(50)
			DECLARE @MaterialName NVARCHAR(50)

		
		IF @pProcessUserID IN ('bangmay', 'dinhkhoi', 'daotrang', 'nguyenhuong', 'thuhien', 'DinhManh','duonghoa','nguyentha','HaiTrieu')  --DinhManh update 2025-04-02 following May's request
			BEGIN
		

					DECLARE @Month NVARCHAR(4)
					SET @Month = MONTH(GETDATE())
					DECLARE @NewCode NVARCHAR(50)
					DECLARE @Prefix NVARCHAR(30) = 'MVKQ' + @Month
					DECLARE @Id INT

					SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_VN_MASTERMODULES  WITH(NOLOCK)
					SELECT @NewCode = @Prefix + RIGHT('00' + CAST(@Id AS nvarchar(30)),30)

					--update STB_VN_MASTERMODULES
					--set PackingID = case when PackingID is null or PackingID='' then @NewCode else PackingID end
					--where LOTNO = @Barcode AND TOTALQTY IS NOT NULL AND ISUSED = '1' AND DIVIDETHENUMBER IS NOT NULL AND PARTNO IS NOT NULL AND VOL IS NOT NULL AND FWAR IS NOT NULL
	

					SELECT 

						@V = VOL,
						@F = FWAR,
						@R = SIZE,
						@P = PARTNO,
						@QTY = TOTALQTY,
						@PKID = PackingID,
						@LOTNO = LOTNO,
						@MaterialName = MARTERIALNAME,
						@MaterialCode = MATERIALCODE
		
				FROM
						STB_VN_MASTERMODULES  WITH(NOLOCK)
			
				WHERE
	
					LOTNO = @Barcode AND TOTALQTY IS NOT NULL AND ISUSED = '1' AND DIVIDETHENUMBER IS NOT NULL AND PARTNO IS NOT NULL AND VOL IS NOT NULL AND FWAR IS NOT NULL





				IF  @LOTNO IS NOT NULL AND @QTY IS NOT NULL

				BEGIN
	
						INSERT INTO STB_VN_NEW_PRINTER
						(MaterialCode,MaterialName,Barcode,LabelQty,LotQty,Voltage,Farad,Rating,PartNo,CreateDateTime,CreateUserID,PackingID)
						VALUES
						(@MaterialCode,@MaterialName,@LOTNO,@LabelQty,@QTY,@V,@F,@R,@P,DATEADD(HH, -2, GETDATE()),@ProcessUserID,@PKID)

						SELECT 
						TOP(1)
						PackingID,
						MaterialCode,
						MaterialName,
						Line,
						Barcode,
						LabelQty,
						LotQty,
						Voltage,
						Farad,
						Rating,
						PartNo,
						CreateUserID,
						CreateDateTime AS Dates,
						RIGHT(CreateDateTime,8) AS Times,
						'Report' AS CommandType
				FROM
						STB_VN_NEW_PRINTER WITH (NOLOCK)

						WHERE CreateUserID = @ProcessUserID

						ORDER BY CreateDateTime DESC

				END

				--IF @LOTNO IS  NULL AND @QTY IS  NULL
				--	BEGIN
				--			--raiserror('fds',16,1)
				--			--return
				--			DROP TABLE #T
				--	END



		
				SELECT 
						TOP(1)
						isnull(PackingID,@NewCode) PackingID,
						Line,
						Barcode,
						LabelQty,
						LotQty,
						Voltage,
						Farad,
						Rating,
						PartNo,
						CreateUserID,
						CreateDateTime AS Dates,
						RIGHT(CreateDateTime,8) AS Times,
						'Report' AS CommandType
				FROM
						STB_VN_NEW_PRINTER WITH (NOLOCK)

						WHERE 
						CreateUserID = @ProcessUserID and
			
						 Barcode = @Barcode

						ORDER BY CreateDateTime DESC

					--DELETE STB_VN_NEW_PRINTER
				--drop table #TblData
	 

				--	SELECT
				--		SI.MaterialCode,
				--		MM.MaterialName,
				--		SI.Barcode,
				--		'' AS LabelQty,
				--		'' AS LotQty,
				--		--REPLACE(SI.Barcode, 'VV', 'VJ') AS LotNo,
				--		MBI.MBIExtText04 AS Voltage,
				--		MBI.MBIExtText05 AS Farad,
				--		'(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')' AS Rating,
				--		RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))) + CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END AS PartNo,
				--		'Report' AS CommandType

				--FROM
				--		STB_SetInfo SI WITH(NOLOCK)
				--		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = SI.MaterialCode
				--		LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON SI.MaterialCode = MBI.ModelCode
				--WHERE 1=1
	
				--  AND  (SI.Barcode = @Barcode OR SI.Barcode = (SELECT NewBarcode 
				--														   FROM STB_LotChangeMaterialHistory 
				--														  WHERE OldBarcode = @Barcode)
				--		  )
		

		END

		ELSE 

			BEGIN
				RAISERROR(N'Bạn không có quyền sử dụng màn hình này', 16, 1)
				RETURN
			END

		--select * from STB_VN_NEW_PRINTER
		--alter table STB_VN_NEW_PRINTER
		--add  Line NVARCHAR(50) NULL
		--select * from STB_VN_NEW_PRINTER
END

-- select * from STB_VN_NEW_PRINTER

-- SELECT * FROM STB_VN_MASTERMODULES WHERE LOTNO = 'VVLL263R012622'