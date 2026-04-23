-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-05-07
-- Description:	Tìm kiếm các packing theo lotno
-- ============================================= exec  usp_Vietnam_GetBoxIDForLotNo_VVT_F3 '','','VE251003-006'
CREATE PROCEDURE [dbo].[usp_Vietnam_GetBoxIDForLotNo_VVT_F3]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()

	)
	SELECT DISTINCT
	     ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
			'16RHV567MB2' as MaterialCodeCustomer,
			CASE
			WHEN  Mli.LotNo IN('VE250401-004','VE250401-003') THEN LEFT(MLI.MaterialCode,10)
			   WHEN  Mli.LotNo IN('VE250602-003','VE250716-003','VE250417-010','VE250225-003') THEN LEFT(MLI.MaterialCode,11)
	            WHEN  Mli.LotNo IN('VE250701-015','VE250805-006','VE250815-003','VE250815-004','VE250809-011','VE250325-007','VE250807-011') THEN LEFT(MLI.MaterialCode,13)
			   --when Mli.LotNo IN ('VE250519-004') then '16VLL100MC6'
			      when MLI.MaterialCode in('63RHV180ME16XL0R01') THEN LEFT(MLI.MaterialCode,12)+'L0R'
				when MLI.MaterialCode in('63RHV180ME16XL0L01') THEN LEFT(MLI.MaterialCode,12)+'L0L' 
				when MLI.MaterialCode in('35RHHL470ME11XB00') THEN '35RHV470ME11XXB001'
    WHEN CHARINDEX('X', ISNULL(HN.NewMaterialCode, MLI.MaterialCode)) > 0 
         THEN LEFT(ISNULL(HN.NewMaterialCode, MLI.MaterialCode), CHARINDEX('X', ISNULL(HN.NewMaterialCode, MLI.MaterialCode)) - 1)
		 
    ELSE LEFT(ISNULL(HN.NewMaterialCode, MLI.MaterialCode), 12)
		
			end as ShortMaterialCode,
			MM.MaterialName,
			MLI.LotID,
			MLI.PackingID,
			'BoxLabel' as LabelType,
			'포장라벨NewVietNam_HN_OnlyCustomer'  as FormatNameOnlyCustomer,
			'포장라벨NewVietNam_HN_TuiBong'  as FormatNameOnlyCustomer_tuibong,
			'포장라벨NewVietNam_HN'  as FormatName,
			'포장라벨NewVietNam_HN_Packing' as FormatNamePacking,
			 isnull(LI.CommandType,'Report')  as CommandType,
			 isnull(LI.Dpi,'200')  as Dpi,
			isnull(LI.PrinterName,'') PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			CAST(MLI.CurrentQty AS INT) AS CurrentQty,
			--MLI.CurrentQty,
			Mli.LotNo, 
			--ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
			--ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			--CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
			--CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
--ISNULL(ISNULL(CFG.Voltage, PLS.Voltage), MBI.MBIExtText04) AS Voltage,
ISNULL(FORMAT(CAST(COALESCE(CFG.Voltage, PLS.Voltage, TRY_CAST(MBI.MBIExtText04 AS FLOAT)) AS FLOAT), '0.#'), '') AS Voltage,

    -- Xử lý Farad: Dùng cách tương tự để hiển thị 6.3, 100.0 một cách gọn gàng
    ISNULL(FORMAT(CAST(COALESCE(CFG.Farad, PLS.Farad, TRY_CAST(MBI.MBIExtText05 AS FLOAT)) AS FLOAT), '0.#'), '') AS Farad,

CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), ISNULL(CFG.MBISizeW, MBI.MBISizeW))) AS MBISizeW,
CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), ISNULL(CFG.MBISizeH, MBI.MBISizeH))) AS MBISizeH,

			ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
		
		    '' as PartNo, 
			 --@PartNo   AS PartNo,
			'' AS IsModule,
			isnull(MLI.StockAttrib1,'')StockAttrib1,
			dbo.fnGetWeekNumber(GETDATE()) AS DC,
			 UPPER(COALESCE(NULLIF(CML.MarkingName, ''), SI.SIExtText07, 'notsave')) AS MarkingLetter
			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가
	
		   ,''  AS ThinkwareBarcode
		   ,'16RHV567MB2' as CustomerCode
			, MLI.LotAttr08 AS CustomerName
			, MLI.CreateUserID AS WorkerCode
			, @pProcessUserID WorkerName
			, MM.MaterialUnit


			-- Mr.Manh update 2025-03-26
			,CASE WHEN EXISTS (Select 1 from STB_PackingLabelPrintHist PLPH where PLPH.PackingID = MLI.PackingID and PLPH.PrintCount >= 1) THEN N'Đã in' ELSE N'Chưa in'
				END as PrintStatus,
				---FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
			-- PART NO: code rút gọn (MaterialCode)

		case 
		   when MLI.MaterialCode='63RHV180ME16XL0L01' then '2409A0200076'
		   when MLI.MaterialCode='63RHV180ME16XL0R01' THEN '2409A0200078'
		   ELSE FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001'
	      end as SerialNo,
		  'VINA ENESOL' AS CompanyName
			
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = 'BoxLabel'
			LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
			LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
			
	WHERE
			MLI.LotNo = @pLotNo
	union all 
		
	SELECT DISTINCT
			ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
			'16RHV567MB2' as MaterialCodeCustomer, -- Mặc đinh là Vina Enesol
			CASE
			   WHEN  Mli.LotNo IN('VE250602-003','VE250401-003','VE250417-010','VE250225-003') THEN LEFT(MLI.MaterialCode,11)
			   WHEN  Mli.LotNo IN('VE250401-004') THEN LEFT(MLI.MaterialCode,10)
			    WHEN  Mli.LotNo IN('VE250701-015','VE250805-006','VE250815-003','VE250815-004','VE250809-011','VE250325-007') THEN LEFT(MLI.MaterialCode,13)
			    when Mli.LotNo IN ('VE250519-004') then '16VLL100MC6'
			    when Mli.MaterialCode in('63RHV180ME16XL0R01') THEN LEFT(MLI.MaterialCode,12)+'L0R'
				when Mli.MaterialCode in('63RHV180ME16XL0L01') THEN LEFT(MLI.MaterialCode,12)+'L0L' 
				when MLI.MaterialCode in('35RHHL470ME11XB00') THEN '35RHV470ME11XXB001'
             WHEN CHARINDEX('X', ISNULL(HN.NewMaterialCode, MLI.MaterialCode)) > 0 
         THEN LEFT(ISNULL(HN.NewMaterialCode, MLI.MaterialCode), CHARINDEX('X', ISNULL(HN.NewMaterialCode, MLI.MaterialCode)) - 1)
              ELSE LEFT(ISNULL(HN.NewMaterialCode, MLI.MaterialCode), 12)
			end as ShortMaterialCode,
			MM.MaterialName,
			MLI.LotID,
			CTF.PackingID,
			'BoxLabel' as LabelType,
			'포장라벨NewVietNam_HN_OnlyCustomer'  as FormatNameOnlyCustomer,
			'포장라벨NewVietNam_HN_Customer_Tui'  as FormatNameOnlyCustomer_tuibong,
			'포장라벨NewVietNam_HN_Packing' as FormatNamePacking,
			'포장라벨NewVietNam_HN'  as FormatName,
			 isnull(LI.CommandType,'Report')  as CommandType,
			 isnull(LI.Dpi,'200')  as Dpi,
			isnull(LI.PrinterName,'') PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			CAST(MLI.CurrentQty AS INT) AS CurrentQty,
			--MLI.CurrentQty,
			CTF.LotNo, 
			---ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
			--ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			--CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
			--CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
	--ISNULL(ISNULL(CFG.Voltage, PLS.Voltage), MBI.MBIExtText04) AS Voltage,
ISNULL(FORMAT(CAST(COALESCE(CFG.Voltage, PLS.Voltage, TRY_CAST(MBI.MBIExtText04 AS FLOAT)) AS FLOAT), '0.#'), '') AS Voltage,

    -- Xử lý Farad: Dùng cách tương tự để hiển thị 6.3, 100.0 một cách gọn gàng
    ISNULL(FORMAT(CAST(COALESCE(CFG.Farad, PLS.Farad, TRY_CAST(MBI.MBIExtText05 AS FLOAT)) AS FLOAT), '0.#'), '') AS Farad,
CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), ISNULL(CFG.MBISizeW, MBI.MBISizeW))) AS MBISizeW,
CONVERT(VARCHAR, CONVERT(NUMERIC(20,1), ISNULL(CFG.MBISizeH, MBI.MBISizeH))) AS MBISizeH,

			--ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,

			ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
		
		    '' as PartNo, 
			 --@PartNo   AS PartNo,
			'' AS IsModule,
			isnull(MLI.StockAttrib1,'')StockAttrib1,
			dbo.fnGetWeekNumber(GETDATE()) AS DC,
			 UPPER(COALESCE(NULLIF(CML.MarkingName, ''), SI.SIExtText07, 'notsave')) AS MarkingLetter
			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가
	
		   ,''  AS ThinkwareBarcode
		   ,'16RHV567MB2' as CustomerCode
			, MLI.LotAttr08 AS CustomerName
			, MLI.CreateUserID AS WorkerCode
			, @pProcessUserID WorkerName
			, MM.MaterialUnit


			-- Mr.Manh update 2025-03-26
			,CASE WHEN EXISTS (Select 1 from STB_PackingLabelPrintHist PLPH where PLPH.PackingID = MLI.PackingID and PLPH.PrintCount >= 1) THEN N'Đã in' ELSE N'Chưa in'
				END as PrintStatus,
				case 
		   when MLI.MaterialCode='63RHV180ME16XL0L01' then '2409A0200076'
		   when MLI.MaterialCode='63RHV180ME16XL0R01' THEN '2409A0200078'
		   ELSE FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001'
	      end as SerialNo,
		   'VINA ENESOL' AS CompanyName
				--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
				--'2409A0200057' as SerialNo
			
	FROM
			STB_CreateTemFakeForHaNam CTF WITH(NOLOCK) 
			OUTER APPLY ( SELECT TOP 1 * from STB_MaterialLotInfo MLI  WHERE  MLI.LotNo= CTF.LotNo ) MLI
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = 'BoxLabel'
			LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
			LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
	WHERE
			CTF.LotNo = @pLotNo

END
