-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-12
-- Description:	In tem tồn kho trước khi sử dụng MES
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetBoxIDForLotInventory_HN]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotNo VARCHAR(100) = NULL,
	@pMaterialCode VARCHAR(100)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
			ISNULL(HN.NewMaterialCode, FGHN.MaterialCode) AS MaterialCode,
			'16RHV567MB2' as MaterialCodeCustomer, -- Mặc đinh là Vina Enesol
			CASE
			   WHEN  FGHN.LotNo IN('VE250602-003') THEN LEFT(FGHN.MaterialCode,11)
			    when FGHN.LotNo IN ('VE250519-004') then '16VLL100MC6'
				when FGHN.MaterialCode in('25RSC100MB9XXXB001') then '25RSC100MB9'
				WHEN CHARINDEX('X', FGHN.MaterialCode) > 0 
                 THEN LEFT(FGHN.MaterialCode, CHARINDEX('X', FGHN.MaterialCode) - 1)
			   else LEFT(FGHN.MaterialCode,12)
			end as ShortMaterialCode,
			FGHN.ProductName,
			FGHN.PackingID,
			'BoxLabel' as LabelType,
			'포장라벨NewVietNam_HN_OnlyCustomer'  as FormatNameOnlyCustomer,
			'포장라벨NewVietNam_HN_TuiBong'  as FormatNameOnlyCustomer_tuibong,
			'포장라벨NewVietNam_HN_Packing' as FormatNamePacking,
			'포장라벨NewVietNam_HN'  as FormatName,
			 isnull(LI.CommandType,'Report')  as CommandType,
			 isnull(LI.Dpi,'200')  as Dpi,
			isnull(LI.PrinterName,'') PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			FGHN.LotNo, 
	       REPLACE(RTRIM(CAST(FGHN.Quantity AS FLOAT)), '.0', '') AS CurrentQty,
           REPLACE(RTRIM(CAST(FGHN.Voltage AS FLOAT)), '.0', '') AS Voltage,
           REPLACE(RTRIM(CAST(FGHN.Farad AS FLOAT)), '.0', '') AS Farad,
           REPLACE(RTRIM(CAST(FGHN.MBISizeW AS FLOAT)), '.0', '') AS MBISizeW,
           REPLACE(RTRIM(CAST(FGHN.MBISizeH AS FLOAT)), '.0', '') AS MBISizeH,
		  FGHN.Marking AS MarkingLetter,
          '16RHV567MB2' AS CustomerCode,
          FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo,
		    'VINA ENESOL' AS CompanyName

		
			
	FROM
			FinishGoodMESInstock_HN FGHN WITH(NOLOCK) 
		
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = FGHN.MaterialCode AND MLBI.LabelType = 'BoxLabel'
			LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = FGHN.PackingID
	        LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
			
	WHERE
			FGHN.LotNo = @pLotNo OR FGHN.MaterialCode=@pMaterialCode
			

END


