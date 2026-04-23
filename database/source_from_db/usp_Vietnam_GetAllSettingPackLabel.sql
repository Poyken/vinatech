
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-09
-- Browsable : true
-- =============================================        exec [usp_Vietnam_GetAllSettingPackLabel]  '','','MVVNQ186R015507'
CREATE PROCEDURE [dbo].[usp_Vietnam_GetAllSettingPackLabel]                          
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL,
						@pLabelType NVARCHAR(30) = 'BoxLabel'
AS

BEGIN
	SET NOCOUNT ON;
	--MVVNQ186R015507

	declare @count INT=0

	declare @barcode VARCHAR(20) = dbo.fn_VVT_getLastestBarCode(@pLotNo)



			DECLARE @MaterialName VARCHAR(200) = '' 
			DECLARE @PartNo VARCHAR(200) = '' 
			DECLARE @ext VARCHAR(200) = ''
			DECLARE @MaterialCod0 VARCHAR(200) = '' 
			DECLARE @PackQty numeric 
			DECLARE @cCount INT 



		 select 

		 @PartNo = case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
						when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
						else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end 

		 ,@ext =	case WHEN CHARINDEX('-', MM.MaterialName,12) >= 12 
					THEN  substring(	MM.MaterialName, 
										CHARINDEX('-', MM.MaterialName,12), 
										(case when CHARINDEX(' ', MM.MaterialName,12)>CHARINDEX('-', MM.MaterialName,12) 
											  then  CHARINDEX(' ', MM.MaterialName,12)-CHARINDEX('-', MM.MaterialName,12) 
											  else (case when CHARINDEX('(', MM.MaterialName,12)>CHARINDEX('-', MM.MaterialName,12) 
													then  CHARINDEX('(', MM.MaterialName,12)-CHARINDEX('-', MM.MaterialName,12) 
													else len(MM.MaterialName) - CHARINDEX('-', MM.MaterialName,12)+1 
													end)  
										end )  
								   ) 
					end
		 from  STB_MaterialLotInfo MLI   WITH(NOLOCK) 
		 join  STB_MaterialMaster MM  WITH(NOLOCK)  on  MLI.MaterialCode = MM.MaterialCode 
		 where LotNo  in (@pLotNo,@barcode)	


		 set @PartNo=@PartNo+@ext

		 if(@PartNo not in ('WEC6R0504QG-I','WEC6R0155QG-H')) begin
			set  @pLotNo=''
			set  @barcode=''
		 end
		 else
			set  @PartNo=@PartNo+'(L&G)'

		 
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
			MLI.MaterialCode,
			MM.MaterialName,
			MLI.LotID,
			MLI.PackingID,

			 LI.FormatName,

			 isnull(LI.CommandType,'Report')  as CommandType,
			 isnull(LI.Dpi,'200')  as Dpi,
			isnull(LI.PrinterName,'') PrinterName,
			LI.LabelType,
			--LI.CommandType,
			--LI.Dpi,
			--LI.PrinterName,
			1 AS LabelQty,
			0 AS LotQty,
			--'' AS LotQty,
			MLI.CurrentQty,
			--ISNULL(PLS.LotNo, MLI.LotNo)  AS LotNo,
			MLI.LotNo, --edited by Mr.Tung on 27-March-2021 
			 
			 ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
			 
			ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
			
			@PartNo   AS PartNo,
			
			'' AS IsModule,
			isnull(MLI.StockAttrib1,'')StockAttrib1,
			dbo.fnGetWeekNumber(GETDATE()) AS DC,
			SI.SIExtText07 AS MarkingLetter
			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가

		   ,''  AS ThinkwareBarcode
		    , CONVERT(CHAR(10), GetDate(), 121) AS Today
			, MLI.LotAttr08 AS CustomerName
			, MLI.CreateUserID AS WorkerCode
			, @pProcessUserID WorkerName
			, MM.MaterialUnit
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	    ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @pLabelType
			LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 	        ON LI.LabelType = MLBI.LabelType  AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK)   ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK)   ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)

			LEFT OUTER JOIN STB_PackingStandard SPS  WITH(NOLOCK)  ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
	WHERE
			MLI.LotNo in (@pLotNo,@barcode) 
			 

END
