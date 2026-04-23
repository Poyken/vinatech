-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	기종변경을 위한 일일계획를 불러옵니다
-- =============================================

--exec usp_GetSetInfoForChangeMaterial_TEST '','','2024042300027'
--exec usp_GetSetInfoForChangeMaterial_TEST '','','2024041800017'
CREATE PROCEDURE [dbo].[usp_GetSetInfoForChangeMaterial_TEST]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo

	SELECT*
			--SI.PONo,
			--SI.DayPlanNo,
			--SI.ControlNo,
			--SI.Barcode,
			--SI.MaterialCode,
			--MM.MaterialName,
			--SI.ProdQty,
			--SI.InputLineCode,
			--LI.LineName AS InputLineName,
			--SI.BefDayPlanNo,
			--'' AS TargetDayPlanNo,
			--'' AS TargetMaterialCode,
			--'' AS TargetMaterialName
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.DayPlanNo = @DayPlanNo 
			--AND
			--SI.IsProdFinish = 0 AND
			--SI.IsLoss = 0
END



--select * from STB_SetInfo  where Barcode='VVOM243R050508'
--select * from STB_SetInfo  where Barcode='VJOM193R070501'
--select * from STB_SetInfo  where Barcode='VJOM193R070502'
--select * from STB_SetInfo  where Barcode='VJOM193R070503'

--select * from STB_LotChangeMaterialHistory where BefDayPlanNo ='2024041800017'



--update STB_SetInfo 
--SET Barcode = 'VVOM193R070502'
--WHERE DayPlanNo = '2024041800021' and ControlNo='20240418000130' 
 
-- select * from STB_SetInfo where Barcode='VVOM193R070514'


--UPDATE STB_SetInfo
--   SET Barcode = 'VVOM193R070514'
-- WHERE Barcode = 'VJOM193R070502'

---- UPDATE STB_SetInfo
----   SET Barcode = 'VJOM193R070502'
---- WHERE Barcode = 'VVOM193R070514'


--UPDATE STB_SetInfo
--   SET Barcode = 'VVOM193R070514'
-- WHERE Barcode = 'VJOM193R070502'

-- select * from STB_SetInfo 
   
-- WHERE Barcode = 'VJOM193R070502'


--select * from STB_LotChangeMaterialHistory where OldBarcode ='VVOM183R070503'
--select * from STB_LotChangeMaterialHistory where OldBarcode ='VVOM183R070504'
--select * from STB_LotChangeMaterialHistory where OldBarcode ='VVOM183R070505'


--INSERT INTO STB_LotChangeMaterialHistory
--	(
--		ControlNo,
--		BefMaterialCode,
--		BefPONo,
--		BefDayPlanNo,
--		AftMaterialCode,
--		AftPONo,
--		AftDayPlanNo,
--		JobDate,
--		CreateDateTime,
--		CreateUserID,
--		OldBarcode,
--		NewBarcode
--	)
--	VALUES
--	(
--		'20240418000130',
--		'ECVT30-282',
--		'240325000009',
--		'2024041800017',
--		'ECVT30-283',
--		'240325000010',
--		'2024041800021',
--		'2024-04-24',
--		'2024-04-24 09:30:05.437',
--		'yjyu',
--		'VVOM183R070503',
--		'VVOM193R070514'
--	)