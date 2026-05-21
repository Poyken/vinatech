-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-06-11
-- Description:	Lấy dữ liệu khi gộp xong box
-- exec usp_getMergePackingBoxSmall_HN '','','50RHVL100ME11XB001PR1000011'
-- PKPR1000320_01 ,5J1 ,100.00000 ;PKPR1000322 ,5J1 ,200.0000000000
-- =============================================

CREATE PROCEDURE [dbo].[usp_getMergePackingBoxSmall_HN]
		@pProcessUserID VARCHAR(20),
	    @pProcessLanguage VARCHAR(20),
		@pMergeNilonToSmallBox varchar(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	select  @pMergeNilonToSmallBox = MergeNilonToSmallBox from  STB_MaterialLotInfo where LotID=@pMergeNilonToSmallBox 
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
		POP.PackingNilonToBoxSmallID,
		POP.CurrentQty as LotQty,
		UPPER(dbo.ufn_RemoveDuplicateText(POP.Marking)) AS MarkingLetter,
		POP.CombineMaterialcodeAndQty ,
		POP.CreateDateTime ,
		POP.CreateUserID ,
		case 
		    when POP.PackingNilonToBoxSmallID ='PK202509150000000005' then '63RUH330ME16XXB001'
			when POP.MaterialCode='50RHVL100ME11XB001' then '50RHV100ME11XXB001'
			else ISNULL(HN.NewMaterialCode, POP.MaterialCode)
		end AS MaterialCode,
		'BoxLabel' as LabelType,
		'MergerNilonToBoxSmall_HN' as FormatName,
		'포장라벨NewVietNam_HN_TuiBong' as FormatNameOnlyCustomer_tuibong,
		 isnull(LI.CommandType,'Report')  as CommandType,
		 isnull(LI.Dpi,'200')  as Dpi,
		 isnull(LI.PrinterName,'') PrinterName,
		 MBI.MBIExtText04 AS Voltage, 
		 MBI.MBIExtText05 AS Farad,
		 POP.CurrentQty,
		 MLi.LotNo,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
		CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
		'16RHV567MB2' as CustomerCode,
		'' as CustomerName,
		'16RHV567MB2' as MaterialCodeCustomer,
	     CASE  
		    WHEN POP.PackingNilonToBoxSmallID IN('PK202506120000000002','PK202506120000000001','PK202506110000000003','PK202508140000000006','PK202508140000000001','PK202508140000000006','PK202508140000000007') THEN LEFT(POP.MaterialCode,11)
			when POP.PackingNilonToBoxSmallID IN ('pk202507010000000006','PK202508140000000008','PK202508140000000009','PK202508140000000010','PK202508190000000007','PK202508190000000010','PK202508180000000003','PK202508180000000002') then LEFT(POP.MaterialCode,13)
			when POP.PackingNilonToBoxSmallID IN ('PK202507230000000012' ) then LEFT(POP.MaterialCode,13)
			when (POP.MaterialCode) in ('25RS68MD11XXXXB001') then LEFT(POP.MaterialCode,10)
			when POP.MaterialCode in('63RHV180ME16XL0R01') THEN LEFT(POP.MaterialCode,12)+'L0R'
		    when POP.MaterialCode in('63RHV180ME16XL0L01') THEN LEFT(POP.MaterialCode,12)+'L0L'
			when POP.MaterialCode in('50RHHL220ME11XB001') then LEFT(POP.MaterialCode,13)
			when POP.MaterialCode in('6RL1200MD11XXXC001','25RL100MD11XXXB001') then LEFT(POP.MaterialCode,11)
			when POP.PackingNilonToBoxSmallID ='PK202509150000000005' then '63RUH330ME16'
			when POP.PackingNilonToBoxSmallID in('PK202508210000000006') then LEFT(POP.MaterialCode,13)
			WHEN CHARINDEX('X', ISNULL(HN.NewMaterialCode, POP.MaterialCode)) > 0 
              THEN LEFT(ISNULL(HN.NewMaterialCode, POP.MaterialCode), CHARINDEX('X', ISNULL(HN.NewMaterialCode, POP.MaterialCode)) - 1)
            ELSE LEFT(ISNULL(HN.NewMaterialCode, POP.MaterialCode), 12)

		 end as ShortMaterialCode,
	    
		--FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001' AS SerialNo
	case 
		   when POP.MaterialCode='63RHV180ME16XL0L01' then '2409A0200076'
		   when POP.MaterialCode='63RHV180ME16XL0R01' THEN '2409A0200078'
		   ELSE FORMAT(GETDATE(), 'yy') + FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') + '001'
	      end as SerialNo,
		  'VINA ENESOL' as CompanyName

		from STB_PackingNilonToBoxSmall_HN POP WITH(NOLOCK) 		
		LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON POP.MaterialCode = MBI.ModelCode
		LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = POP.MaterialCode AND MLBI.LabelType = 'BoxLabel'
		LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
		LEFT OUTER JOIN STB_Materiallotinfo  MLI  WITH(NOLOCK) 	ON POP.PackingNilonToBoxSmallID=MLI.MergeNilonToSmallBox
		LEFT JOIN STB_ChangeMaterialCode_HN HN WITH(NOLOCK) ON HN.PackingID = MLI.PackingID
	    LEFT JOIN STB_ChangeMaterialCode_Config CFG WITH(NOLOCK) ON CFG.oldMaterialCode = HN.oldMaterialCode

		where POP.PackingNilonToBoxSmallID=@pMergeNilonToSmallBox
	
		  
END

