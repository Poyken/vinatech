-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-14
-- Description:	Lấy dữ liệu thùng to
-- exec usp_getPackingOutPutFinishGoodsInventory_HN 'trieu','vi','PKHN612614'
-- =============================================
CREATE PROCEDURE [dbo].[usp_getPackingOutPutFinishGoodsInventory_HN]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMergeBoxSmallID varchar(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select @pMergeBoxSmallID = MergeBoxSmallID 
from FinishGoodMESInstock_HN 
where PackingID = @pMergeBoxSmallID


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
	SELECT 
		POP.PackingOutPutFinishGoodsID,
		POP.CurrentQty as LotQty,
		UPPER(dbo.ufn_RemoveDuplicateText(POP.Marking)) AS MarkingLetter,
		POP.CombineMaterialcodeAndQty ,
		POP.CreateDateTime ,
		POP.CreateUserID ,
		--POP.MaterialCode,
		ISNULL(CFG.NewMaterialCode, POP.MaterialCode) AS MaterialCode,
		'BoxLabel' as LabelType,
		'포장라벨NewVietNam_HN_Finish' as FormatName,
		 isnull(LI.CommandType,'Report')  as CommandType,
		 '포장라벨NewVietNam_HN_TuiBong' as FormatNameOnlyCustomer_tuibong,
		 isnull(LI.Dpi,'200')  as Dpi,
		 isnull(LI.PrinterName,'') PrinterName,
		 MBI.MBIExtText04 AS Voltage, 
		 MBI.MBIExtText05 AS Farad,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
		POP.CurrentQty,
		'16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when POP.MaterialCode in ('10RS560ME11XXXB001') then left(POP.MaterialCode,11)
			 else left(POP.MaterialCode,12)
	     end as ShortMaterialCode,
		FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo,
		'VINA ENESOL' as CompanyName

		from STB_PackingOutPutFinishGoods_HN POP WITH(NOLOCK) 		
		LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON POP.MaterialCode = MBI.ModelCode
		LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = POP.MaterialCode AND MLBI.LabelType = 'BoxLabel'
		LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
		 LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = POP.MaterialCode
		where POP.PackingOutPutFinishGoodsID=@pMergeBoxSmallID
END
