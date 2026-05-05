-- Procedure: get_MaterialCodePrintTemFor_HN
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-25
-- Description:	Làm màn hình in tem thoải mái
-- =============================================
CREATE PROCEDURE [dbo].[get_MaterialCodePrintTemFor_HN]
		@pProcessUserID VARCHAR(20),
	    @pProcessLanguage VARCHAR(20),
		@pMaterialCode varchar(50)=NULL
AS
BEGIN

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
	SELECT top 1
		'PKCT'+RIGHT('00000000' + CAST(CAST(RIGHT((select  max(PackingID) as PackingID  from STB_CreateTemFakeForHaNam where Packingid like 'PKCT%' and  LEN(PackingID) = 12 ), 8) AS INT) + 1 AS VARCHAR), 8) as PackingID,
		0 as CurrentQty,
		'' AS MarkingLetter,
		'' as LotNo,
		@pMaterialCode as MaterialCode ,
		'BoxLabel' as LabelType,
		'포장라벨NewVietNam_HN_Finish' as FormatName,
		'포장라벨NewVietNam_HN' as FormatNameSmall,
		 isnull(LI.CommandType,'Report')  as CommandType,
		 isnull(LI.Dpi,'200')  as Dpi,
		 isnull(LI.PrinterName,'') PrinterName,
		 MBI.MBIExtText04 AS Voltage, 
		 MBI.MBIExtText05 AS Farad,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
		'' as PackingOutPutFinishGoodsID,
		'' as MaterialCodeCustomer,
		'' as ShortMaterialCode
		from  STB_ModelBasicInfo MBI	 	
		LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON  MLBI.LabelType = 'BoxLabel'
		LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 	        ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
		where MBI.ModelCode = @pMaterialCode
END

GO

