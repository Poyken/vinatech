-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-04
-- Description:	Chia tem và in tem tồn trước MES ở nhà máy Hà Nam
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingInventoryLabels]
	-- Add the parameters for the stored procedure here
     @pProcessUserID VARCHAR(20) =NULL,
	 @pProcessLanguage VARCHAR(20) =NULL,
     @pPackingID NVARCHAR(50) = NULL,
	 @pDividePackagingQty INT=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Khai báo 1 packing dược truyền vào từ tham sô
	declare @DividePackagingID NVARCHAR(50)
	declare @psagemcom varchar(10) = isnull('sagemcom',''),
	@LabelType varchar(50)='BoxLabel'
	declare @DividePackagingQty int =@pDividePackagingQty
	
		   	IF NOT EXISTS (Select * FROM STB_DividePackaging  where PackingID =@pPackingID)  --NẾU CHƯA TỒN TẠI THÌ SẼ THÊM VÀO BẢNG
							BEGIN
						 EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging',@DividePackagingID OUTPUT

													INSERT INTO STB_DividePackaging (
														DividePackagingID,
														PackingID,
														Qty,
														GRDate,
														MaterialCode,
														LotNo,
														CreateDateTime,
														CreateUserID
														)
														SELECT top (1)
														@DividePackagingID,
														@pPackingID,
														Quantity,
														NULL,
														MaterialCode,
														LoTNo,
														GETDATE(),
														@pProcessUserID
														FROM FinishGoodMESInstock_HN where PackingID =@pPackingID order by CreateDateTime DESC
								END
		
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
				 SELECT top(1) 
				 DP.DividePackagingID,
				 MLI.MaterialCode,
				 MM.MaterialName,
				 MLI.Lotno,
				 MLI.PackingID,

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
				 MLI.Quantity,
				 MLI.LotNo,
				 MLI.Voltage as Voltage, 
				 MLI.Farad AS Farad,
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
				  @DividePackagingQty as QtySliptBox ,
			      0 as QtySliptBox_Export 
				from STB_DividePackaging DP
				LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON DP.PACKINGID = MLI.PACKINGID --AND DP.LOTNO = MLI.LOTNO
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
				LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
				LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
				--LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
				--LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
				LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
				where DP.Packingid=@pPackingID
END
