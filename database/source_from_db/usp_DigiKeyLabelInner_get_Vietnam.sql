-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DigiKeyLabelInner_get_Vietnam]  -- usp_DigiKeyLabelInner_get_Vietnam '', '', 'VVPO213R060608'
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pLotNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE	@LotNo VARCHAR(50) = @pLotNo
			,@IsProdFinish BIT
			,@CheckMPN VARCHAR(30)
			,@SN VARCHAR(20)
			,@RowCnt INT
	DECLARE @ProdDate VARCHAR(8) = CONVERT(VARCHAR, dbo.fnPharseLotNo(@LotNo, 'D'), 112)

	DECLARE @rDC VARCHAR(4) = NULL
	SET @rDC = dbo.fnGetWeekNumber(CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112))

	DECLARE @rPN  VARCHAR(50),
			--@LotNo1 VARCHAR(50) = 'VVPO213R060608',
			@Barcode NVARCHAR(max)


	SELECT @rPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) 
	+ CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' 
		WHEN CHARINDEX('-I', MM.MaterialName) > 0 THEN '-I'
	ELSE '' END
	FROM
					STB_MaterialLotInfo MLI WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
					--LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
					LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				WHERE
						SI.Barcode = @LotNo
	--print @rPN
		
	SELECT @IsProdFinish = IsProdFinish,
			@CheckMPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) 	
			+ CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' 
		WHEN CHARINDEX('-I', MM.MaterialName) > 0 THEN '-I'
	ELSE '' END
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo



	IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	--IF @pTypeBoxCode IS NULL or @pTypeBoxCode = '' BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Hãy chọn loại thùng để in tem'
	--	RETURN
	--END

	IF @IsProdFinish IS NULL BEGIN 
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Mã Lotno này không tồn tại trên hệ thống.!'
		RETURN
	END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Kiểm tra màn hình B523 xem đóng gói hay chưa. Gọi sản xuất'
		RETURN
	END




					-- IAC;6010A0981401;2525;VVPO213R060608;00250;VV5256L00002;
			--SET @Barcode = '[)>@06@1P'+ @rPN + '@Q140@9D' + @rDC + '@1T' + @LotNo + '@4LVN@@' 

			--SET @Barcode = char(91)+char(41)+char(62) +char(30) +'06'+char(29) +'1P'+ @rPN + char(29) + 'Q140' + char(29) + '9D'+ @rDC + char(29) + '1T' + @LotNo + char(29) + '4LVN' + char(04)

				--SET @Barcode = CONVERT(VARBINARY, '[)>␞06␝1PVEC3R0107QG␝Q140␝9D2510␝1T01␝4LVN␝␞␄')
				SET @Barcode = ''
				
				--SET @Barcode = '~1\x1E06\x1D1PVEC3R0107QG\x1DQ140\x1D9D2510\x1D1T01\x1D4LVN\x1D\x1E\x04'

			SELECT
						MLI.MaterialCode,
						MM.MaterialName,
						--MLI.PackingID,
						--N'Nhãn sản phẩm' AS LabelType,
						@rPN AS PN,
						60 AS Qty,		-- số lượng trên tem nhỏ
						@rDC AS DC,
						@LotNo AS LotNo,
						RIGHT(@LotNo, 2) AS LotNumber,
						'VN' AS Country,
						--@Barcode AS Barcode,
						--ISNULL(PACH.PrintCnt, 0) AS PrintCnt,
						'' AS PONumber,
						'' AS POLineNumber,
						'' AS PackListNumber,
						120 AS QtyLogisticBox,		-- Số lượng trên tem logistic
						1 AS LabelQty,
						'Report' AS CommandType
				FROM
						STB_MaterialLotInfo MLI WITH(NOLOCK)
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						--LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						--LEFT OUTER JOIN (SELECT LotNo, COUNT(*) AS PrintCnt 
						--					FROM STB_DigiKeyLabelInnerPrintHist
						--				   WHERE LabelType = N'Nhãn Sản phẩm'
						--				  GROUP BY LotNo
						--				) PACH ON PACH.LotNo = SI.Barcode 
				WHERE
						SI.Barcode = @LotNo
		
	
END

-- print '␞ ␝  ␄'
