-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-24
-- Description:	Lấy dữ liệu để intem thùng to thành phẩm hà nam
-- exec usp_getPackingOutPutFinishGoods_HN '','','pkqm0800261'
CREATE PROCEDURE [dbo].[usp_getPackingOutPutFinishGoods_HN] 
		@pProcessUserID VARCHAR(20),
	    @pProcessLanguage VARCHAR(20),
		@pMergeParentId varchar(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- select top 1 * from STB_DividePackaging

	---select top 1 * from STB_MaterialLotInfo 
	SET NOCOUNT ON;
	select  @pMergeParentId = MergeParentId from  STB_MaterialLotInfo where LotID=@pMergeParentId 
	--select  @pMergeParentId = MergeParentId from  STB_DividePackaging where PackingId=@pMergeParentId 

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
		ISNULL(CFG.NewMaterialCode, POP.MaterialCode) AS MaterialCode,
		--ISNULL(CFG.NewMaterialCode, POP.MaterialCode) AS MaterialCode,
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
		    when POP.PackingOutPutFinishGoodsID='PKHNOP202601190000000001' then left(POP.MaterialCode,12)+'L0L'
			when POP.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left(POP.MaterialCode,13)
			WHEN CHARINDEX('X',  POP.MaterialCode) > 0 
                      THEN LEFT( POP.MaterialCode, CHARINDEX('X',  POP.MaterialCode) - 1)
			 else left(POP.MaterialCode,12)
			 
	     end as ShortMaterialCode,
		 case 
		   when POP.MaterialCode='63RHV180ME16XL0L01' then '2409A0200076'
		   when POP.MaterialCode='63RHV180ME16XL0R01' THEN '2409A0200078'
		   ELSE FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001'
	      end as SerialNo,
		  'VINA ENESOL' as CompanyName
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		--'2409A0200057' as SerialNo
		from STB_PackingOutPutFinishGoods_HN POP WITH(NOLOCK) 
		LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON POP.MaterialCode = MBI.ModelCode
		LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = POP.MaterialCode AND MLBI.LabelType = 'BoxLabel'
		LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
	    LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = POP.MaterialCode
		where POP.PackingOutPutFinishGoodsID=@pMergeParentId
		
END
-- SELECT * FROM STB_PackingOutPutFinishGoods_HN where PackingOutPutFinishGoodsID='PKHNOP202508190000000009'