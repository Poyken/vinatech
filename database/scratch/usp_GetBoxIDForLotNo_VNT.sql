
-- ==================================================================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리 > [B520]제품박스실적입력 > Grid-3 BOX ID 정보
-- Description: 패킹공정 실적 입력을 위한 바코드 정보를 가져옵니다
-- Modified:
-- 2021.04.22 팅크웨어향 라벨 관련 (고객사)자재코드 추가 #21.04.22
-- 2021.11.04 삼성향포장라벨 PartNo부분 Case문 조건 추가 (Mr.Song)
-- 2022.03.21 작업일자 자동

-- 프로시저 실행 :    Exec usp_GetBoxIDForLotNo_VNT 'kilee','Korean','VJLS193R850606', ''
-- ====================================================================================
CREATE PROCEDURE [dbo].[usp_GetBoxIDForLotNo_VNT]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL,
						@pLabelType NVARCHAR(30) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(30) = @pLabelType 
	DECLARE @LotNo VARCHAR(100) = @pLotNo 
	DECLARE @IsModule BIT = 0 
	--#241023
	Declare @WorkCenterCode VARCHAR(20)
	

	
	--edited by Mr.Tung on 27-March-2021 
	--For Vietnam Factory printing VJ label
	DECLARE @allowVJ BIT = 0 
	DECLARE @CompanyVal VARCHAR(20) = ''


	  SELECT @CompanyVal = [CompanyCode]
	  FROM [SmartFactoryV2].[dbo].[STB_UserInfo]
	  where UserID = @pProcessUserID


-- 베트남부분 (VVT)
  IF ( (@LotNo like 'VV%' and @CompanyVal='VVT')  ) 
	Begin 			
			DECLARE @MaterialName VARCHAR(200) = '' 
			DECLARE @PartN0 VARCHAR(200) = '' 
			DECLARE @MaterialCod0 VARCHAR(200) = '' 
			DECLARE @PackQty numeric 
			DECLARE @cCount INT 

			
		 select 
		 @MaterialCod0 = MLI.MaterialCode,
		 @PartN0 = (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) 
				   +  CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' 
				           WHEN @LotNo like 'VV%' and CHARINDEX('-B080', MM.MaterialName) > 0 THEN '-B080' --Mr.Tung on 05-April-2021 for Bending Model
						   WHEN @LotNo like 'VV%' and CHARINDEX('-B084', MM.MaterialName) > 0 THEN '-B084' --Mr.Tung on 09-April-2021 for Bending Model
						   ELSE '' END ),
		 @MaterialName = MM.MaterialName,
		 @PackQty = CurrentQty
		 from 		 STB_MaterialLotInfo MLI  join  STB_MaterialMaster MM  on  MLI.MaterialCode = MM.MaterialCode
		 where   LotNo = @LotNo
		 -- 2026-04-23 [김형진] POP 재공품 제외
		 AND ISNULL(MLI.LotAttr01, '') != 'WIP_CREDIT'
		 

		 select  top  1  @allowVJ = PrintVJ
		 from    STB_Vietnam_PackingPrinting
		 where   (MaterialCode = @MaterialCod0 or PartNo = @PartN0) and (PrintVJ=1 or PrintVJ='1')	

				 declare @isDisableVJ int = 0
				 exec usp_Vietnam_GetExceptVJ  @LotNo, @isDisableVJ  OUTPUT  --this Procedure for except to print VJ Label

				 if (@isDisableVJ > 0)
				 begin
					select @allowVJ = 0
				 end
		 
		 --if(@allowVJ=1 )
		 begin
				select  @cCount = count(*)
				from	 STB_SavePackingTime_VVT
				where LotNo = @LotNo

				if (@cCount < 2)
				begin
				--RAISERROR(@MaterialName,16,1)
		 			insert into STB_SavePackingTime_VVT (PackingID, LotNo, MaterialCode, MaterialName, PackQty, PrintTime, EmpNo, isPrinted, isModule, partNo)
					     values (STUFF(@LotNo, 1, 2,   'VJ'  ), @LotNo, @MaterialCod0, @MaterialName, -@PackQty, getdate(), @pProcessUserID, 0, 0, @PartN0 );
				end
		 end

	end 
	--end Mr.Tung



-- // 한국본사 (VNT) 부분
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
			LI.LabelType,
			LI.FormatName,
			LI.CommandType,
			LI.Dpi,
			LI.PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			--'' AS LotQty,
			MLI.CurrentQty,
			--ISNULL(PLS.LotNo, MLI.LotNo)  AS LotNo,
			(case when @allowVJ=1  then STUFF(MLI.LotNo, 1, 2,   'VJ'  ) else ISNULL(PLS.LotNo, MLI.LotNo) end) AS LotNo, --edited by Mr.Tung on 27-March-2021 
			ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage,
			ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')') AS Rating,
			
			-- ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))))  + (CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo,	
			CASE WHEN MM.MMExtText05 IS NOT NULL THEN MM.MMExtText05
				 ELSE 
						CASE WHEN CHARINDEX(' ', ModelName) > 10 THEN ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName,1, 14))))
								   ELSE ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12)))) END
						+ ( CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' 
									  WHEN @LotNo like 'VV%' and CHARINDEX('-B080', MM.MaterialName) > 0 THEN '-B080' --Mr.Tung on 05-April-2021 for Bending Model
									  WHEN @LotNo like 'VV%' and CHARINDEX('-B084', MM.MaterialName) > 0 THEN '-B084' --Mr.Tung on 09-April-2021 for Bending Model
									  WHEN CHARINDEX('-B0615', MM.MaterialName) > 0 THEN '-B0615'
									  WHEN CHARINDEX('-B063', MM.MaterialName) > 0 THEN '-B063'
									  WHEN CHARINDEX('-WC', MM.MaterialName) > 0 THEN '-WC'
									  WHEN CHARINDEX('-B034', MM.MaterialName) > 0 THEN '-B034'   -- 삼성향 VPC라벨 (2021.11.05)
						ELSE '' END)
				  END AS PartNo,

			@IsModule AS IsModule,
			CASE WHEN MLI.WorkCenterCode = 'VNT_F2' AND ISNULL(MLI.StockAttrib1, '') = '' THEN '' ELSE MLI.StockAttrib1 END AS StockAttrib1,
			dbo.fnGetWeekNumber(GETDATE()) AS DC,
			SI.SIExtText07 AS MarkingLetter
			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 추가
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 추가
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 추가
		--,	'' AS LotQtyTwo
		    , CASE WHEN MLI.MaterialCode = 'ECVT30-333' THEN 'AASC-0K00005' --#210422
			          WHEN MLI.MaterialCode = 'ECVT30-322' THEN 'AASC-4P00001'
				      WHEN MLI.MaterialCode = 'ECVT30-320' THEN 'AASC-4R00001'
				      WHEN MLI.MaterialCode = 'ECVT30-321' THEN 'AASC-4M00001' ELSE '' END AS ThinkwareBarcode
		   --, CONVERT(VARCHAR(10), GETDATE(), 121) AS Today -- 출력일이 아니라 포장(입고)일이 되어야 함.
		   --,CONVERT(CHAR(10), GRDate, 121) AS Today

		    , CONVERT(CHAR(10), GetDate(), 121) AS Today
			, MLI.LotAttr08 AS CustomerName
			, MLI.CreateUserID AS WorkerCode
			, (SELECT UserName FROM SmartFramework.dbo.STB_UserInfo WHERE UserID = MLI.CreateUserID) AS WorkerName
			, MM.MaterialUnit
			, MLI.LotAttr06
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LI				                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI			                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)

			LEFT OUTER JOIN STB_PackingStandard SPS				     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 추가 
	WHERE
			MLI.LotNo = @LotNo
			-- 2026-04-23 [김형진] POP 재공품 제외
			AND ISNULL(MLI.LotAttr01, '') != 'WIP_CREDIT'

END