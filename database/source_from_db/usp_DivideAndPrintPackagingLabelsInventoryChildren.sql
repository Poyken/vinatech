-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-06
-- Description:	Xem các tem con được tách ra
-- exec usp_DivideAndPrintPackagingLabelsInventoryChildren 'PKHN612614'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabelsInventoryChildren] 
	-- Add the parameters for the stored procedure here
    @pPackingID NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    DECLARE @PackingID VARCHAR(50) = @pPackingID 
    -- Insert statements for procedure here
	declare @psagemcom varchar(10) = isnull('sagemcom',''),
	@LabelType varchar(50)='BoxLabel'
	
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
				 DP.DividePackagingID,
				 MLI.MaterialCode,
				 MM.MaterialName,
				 MLI.LotNo,
				 DP.PackingID,

				 isnull(LI.LabelType,'BoxLabel')  + (case when @psagemcom<>'' then 'VVT' else '' end)  as LabelType,
				 case 
					  when MLI.WorkCenterCode='VVT_F3'  then LI.FormatName+'NewVietNam_HN' 
					  when LI.FormatName like '%삼성향%' then LI.FormatName+'NewVietNam' 
						  else (
						  case when @psagemcom<>'' then '포장라벨Sagecom' 
									else '포장라벨NewVietNam' 
									end) 
					 
				 end as FormatName,

				 isnull(LI.CommandType,'Report')  as CommandType,
				 isnull(LI.Dpi,'200')  as Dpi,
				 isnull(LI.PrinterName,'') PrinterName,
				 0 AS LabelQty,
				 0 AS LotQty,
				 DP.Qty AS CurrentQty,
				FORMAT(CAST(MLI.Voltage AS DECIMAL(10,2)), '0.#') AS Voltage,
                FORMAT(CAST(MLI.Farad AS DECIMAL(10,2)), '0.#') AS Farad,
				 CONVERT(VARCHAR, CONVERT(numeric(20,1), MLI.MBISizeW)) as MBISizeW,
				 CONVERT(VARCHAR, CONVERT(numeric(20,1), MLI.MBISizeH)) as MBISizeH,
				 --ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
				 --PartNo,
				 --isnull(MLI.StockAttrib1,'')StockAttrib1,
				  --COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter,
				 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
				 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
				 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
				  MLI.Unit ,
 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		'2409A0200057' as SerialNo,
		 'VINA ENESOL' as CompanyName,
		 	MLI.Marking AS MarkingLetter
				from STB_DividePackaging DP
				LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON DP.PackingParentID = MLI.PACKINGID --AND DP.LOTNO = MLI.LOTNO
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
				LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
				LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
				--LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
				--LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
				LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
				where DP.PackingParentID=@PackingID

END
