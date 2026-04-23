-- =============================================
-- Author:		Mr.Duy & Mr.Trieu
-- Create date: 2025-04-02
-- Description: lấy dữ liệu	chia tem và in tem cho hàng đóng gói ngoài sản xuất hà nam
-- =============================================
--  exec  usp_DivideAndPrintPackagingLabels '','','PKPM0200118',''
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabels]
		@pProcessUserID VARCHAR(20) =NULL,
	    @pProcessLanguage VARCHAR(20) =NULL,
		@pPackingID NVARCHAR(50) = NULL,
		@pTypeBox VARCHAR(50)= NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Thêm trường hợp là check với tem chia hay không là tem chia
	DECLARE @IsFakePacking BIT

	-- Kiểm tra xem nó có phải là tem fake hay không nếu mà phải thì sẽ thêm trường hợp nữa
	


	declare @TypeBox VARCHAR(50) = @pTypeBox
	declare @PackingID NVARCHAR(50) = @pPackingID
	declare @FormattedDate  VARCHAR(20)
	declare @DividePackagingID NVARCHAR(50)
	declare @psagemcom varchar(10) = isnull('sagemcom',''),
	@LabelType varchar(50)='BoxLabel'
	IF EXISTS(SELECT * FROM STB_MaterialLotInfo where PackingID=@pPackingID)
	begin
	  set @IsFakePacking=1;  
	end
	

	-- Trường hợp 1: Là Packing bình thường
	IF(@IsFakePacking=1)
	begin

	IF (@TypeBox is null  or  @TypeBox = '') 
		begin

			IF NOT EXISTS (Select * FROM STB_MaterialLotInfo  where PackingID =@PackingID)
							BEGIN
										raiserror( N'Lot này không tồn tại hoặc chưa đóng gói',16,1)		
										RETURN;
							END
			ELSE
				BEGIN
						IF NOT EXISTS (Select * FROM STB_DividePackaging  where PackingID =@PackingID)  --NẾU CHƯA TỒN TẠI THÌ SẼ THÊM VÀO BẢNG
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
														@PackingID,
														InitialQty,
														ProductionDate,
														MaterialCode,
														LoTNo,
														GETDATE(),
														@pProcessUserID
														FROM STB_MaterialLotInfo where PackingID =@PackingID order by CreateDateTime DESC
								END

					
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
				-- MLI.Lotno,
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
				 MLI.CurrentQty,
				 MLI.LotNo,
				 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
				 ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
				 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
				 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
				 ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
				 PartNo,
				 isnull(MLI.StockAttrib1,'')StockAttrib1,
				  COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter,
				 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
				 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
				 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
				  MM.MaterialUnit ,
				  	 0 as QtySliptBox ,
					   	 0 as QtySliptBox_Export 
				  from STB_DividePackaging DP
				 LEFT JOIN 	STB_MaterialLotInfo MLI WITH(NOLOCK) ON DP.PACKINGID = MLI.PACKINGID --AND DP.LOTNO = MLI.LOTNO
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
				LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
				LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
				LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
				LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
				LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
				LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
				where DP.Packingid=@packingid
				
		end

		select @DividePackagingID =DividePackagingID from STB_DividePackaging where packingid=@packingid -- lấy ra mã của thằng cha
		IF (@TypeBox  like 'Small')  
				begin

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
						 UPPER(LTRIM(RTRIM(DP.DividePackagingID))),
						ISNULL(HN.NewMaterialCode, MLI.MaterialCode) AS MaterialCode,
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
						 ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
						 ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
						 PartNo,
						 isnull(MLI.StockAttrib1,'')StockAttrib1,
						  UPPER(COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave')) AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else LEFT(ISNULL(HN.NewMaterialCode, MLI.MaterialCode), 12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		 'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	STB_MaterialLotInfo MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
						LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			        			LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = DP.PackingID
	                 LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 1
						order by DP.PackingID
				end

			IF (@TypeBox  like 'Nilon')  
				begin

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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
						 ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
						 ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
						 PartNo,
						 isnull(MLI.StockAttrib1,'')StockAttrib1,
						  COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	STB_MaterialLotInfo MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
						LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 2
							order by DP.PackingID
				end


				-- Mã custom theo nhà cung cấp
				IF (@TypeBox  like 'SmallCustom')  
				begin

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
					 isnull(DP.Materialcode,MLI.MaterialCode)as MaterialCode,
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
						 ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
						 ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
						 PartNo,
						 isnull(MLI.StockAttrib1,'')StockAttrib1,
						  COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	STB_MaterialLotInfo MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
						LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 1
							order by DP.PackingID
				end

				-- Mã custom theo nhà cung cấp
				IF (@TypeBox  like 'NilonCustom')  
				begin

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
						 MLI.MaterialCode as MaterialCode,
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
						 ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
						 CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
						 ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
						 PartNo,
						 isnull(MLI.StockAttrib1,'')StockAttrib1,
						  COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	STB_MaterialLotInfo MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
						LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 2
							order by DP.PackingID
				end
		end
		else
		begin
		     IF (@TypeBox is null  or  @TypeBox = '') 
		begin

			IF NOT EXISTS (Select * FROM FinishGoodMESInstock_HN  where PackingID =@PackingID)
							BEGIN
										raiserror( N'Lot này không tồn tại hoặc chưa đóng gói',16,1)		
										RETURN;
							END
			ELSE
				BEGIN
						IF NOT EXISTS (Select * FROM STB_DividePackaging  where PackingID =@PackingID)  --NẾU CHƯA TỒN TẠI THÌ SẼ THÊM VÀO BẢNG
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
														@PackingID,
														InitialQty,
														ProductionDate,
														MaterialCode,
														LoTNo,
														GETDATE(),
														@pProcessUserID
														FROM STB_MaterialLotInfo where PackingID =@PackingID order by CreateDateTime DESC
								END

					
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
				-- MLI.Lotno,
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
				 MLI.Quantity AS CurrentQty,
				 MLI.LotNo,
				 MLI.Voltage AS Voltage, 
				 MLI.Farad AS Farad,
				 MLI.MBISizeW as MBISizeW,
				 MLI.MBISizeH as MBISizeH,
				 '' AS Rating,
				 '' AS PartNo,
				 '' as StockAttrib1,
				 '' AS MarkingLetter,
				 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
				 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
				 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
				  MM.MaterialUnit ,
				  	 0 as QtySliptBox ,
					   	 0 as QtySliptBox_Export 
				  from STB_DividePackaging DP
				 LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON DP.PACKINGID = MLI.PACKINGID --AND DP.LOTNO = MLI.LOTNO
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
				LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
				LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
				LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
				LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
				LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
				where DP.Packingid=@packingid
				
		end

		select @DividePackagingID =DividePackagingID from STB_DividePackaging where packingid=@packingid -- lấy ra mã của thằng cha
		IF (@TypeBox  like 'Small')  
				begin

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
						 UPPER(LTRIM(RTRIM(DP.DividePackagingID))),
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 MLI.Voltage AS Voltage, 
						 MLI.Farad AS Farad,
						 MLI.MBISizeW as MBISizeW,
						 MLI.MBISizeH as MBISizeH,
						'' AS Rating,
						 '' AS PartNo,
						 '' AS StockAttrib1,
						  '' AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 1
						order by DP.PackingID
				end

			IF (@TypeBox  like 'Nilon')  
				begin

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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 MLI.Voltage AS Voltage, 
						 MLI.Farad AS Farad,
						 MLI.MBISizeW as MBISizeW,
						 MLI.MBISizeH as MBISizeH,
						'' AS Rating,
						 '' AS PartNo,
						 '' AS StockAttrib1,
						  '' AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 2
							order by DP.PackingID
				end


				-- Mã custom theo nhà cung cấp
				IF (@TypeBox  like 'SmallCustom')  
				begin

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
					 isnull(DP.Materialcode,MLI.MaterialCode)as MaterialCode,
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 MLI.Voltage AS Voltage, 
						 MLI.Farad AS Farad,
						 MLI.MBISizeW as MBISizeW,
						 MLI.MBISizeH as MBISizeH,
						'' AS Rating,
						 '' AS PartNo,
						 '' AS StockAttrib1,
						  '' AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 1
							order by DP.PackingID
				end

				-- Mã custom theo nhà cung cấp
				IF (@TypeBox  like 'NilonCustom')  
				begin

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
						 MLI.MaterialCode as MaterialCode,
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
						 0 AS LotQtyClose,
						 DP.Qty as LotQty,
						 --MLI.LotNo,
						 MLI.Voltage AS Voltage, 
						 MLI.Farad AS Farad,
						 MLI.MBISizeW as MBISizeW,
						 MLI.MBISizeH as MBISizeH,
						'' AS Rating,
						 '' AS PartNo,
						 '' AS StockAttrib1,
						  '' AS MarkingLetter,
						 ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty,  
						 ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty,  
						 ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty,
						  MM.MaterialUnit,
						 0 as QtySliptBox,
						 	 '16RHV567MB2' as CustomerCode,
		'' as CustomerName,
         '16RHV567MB2' as MaterialCodeCustomer,
		 case 
		    when  MLI.MaterialCode in ('10RS560ME11XXXB001','12RHV470MB9XXXT001') then left( MLI.MaterialCode,11)
		
			when  MLI.MaterialCode in ('16RSH1500ME16XB001','63RHHL180ME16XB001') then left( MLI.MaterialCode,13)
			 else left( MLI.MaterialCode,12)
	     end as ShortMaterialCode,
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
		'2409A0200057' as SerialNo,
		'VINA ENESOL' as CompanyName
						    
						  from STB_DividePackaging DP
						 LEFT JOIN 	FinishGoodMESInstock_HN MLI WITH(NOLOCK) ON @packingid = MLI.PACKINGID AND DP.LOTNO = MLI.LOTNO
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
						LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
						LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
						LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
						LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.Marking = CML.MarkingCode
						LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
			
						where DP.ParentPackingID=@DividePackagingID 
						and TypeBox = 2
							order by DP.PackingID


		 end

		 end
END


