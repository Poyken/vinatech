
-- =========================================================================================
-- Author:	    Anonymous()
-- Create date: 2016-07-01
-- Browsable : true
-- Group : 자재관리 > 자재입고 및 라벨발행 > Grid3. 수불Lot정보
-- Description:	자재수불 LOT 리스트를 조회합니다.
-- Modified: 화면3번째 -> 자재입고 및 라벨발행에서 수불 lot정보
--              2019.02.20 라벨관련정보 추가 (kilee)
--              2019.03.11 수입검사정보 추가 (kilee)
--              2019.03.12 제조일자 표기 수정 및 소숫점자리표기 수정 (kilee)
--              2020.06.15 유효일자 문제로 조회 안되는 문제해결 (주석으로 설명) (kilee)

-- [프로시저 확인방법] : Grid1에서 수불문서번호가 3번째 변수, Grid2에서 컬럼추가로 DocDetailNo가 4번째변수 입력하여 조회함!!
						-- EXEC [usp_MaterialDocLotInfo_get] 'kilee','Korean','200518000108','200518000130','',''
						-- EXEC [usp_MaterialDocLotInfo_get] 'kilee','Korean','200518000157','200518000201','',''   
-- =========================================================================================
ALTER PROCEDURE [dbo].[usp_MaterialDocLotInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pMaterialDocDetailNo VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(20) = NULL,
						@pLabelType NVARCHAR(60) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo         VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '' ELSE @pMaterialDocNo END
	DECLARE @MaterialDocDetailNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocDetailNo,'') = '' THEN '' ELSE @pMaterialDocDetailNo END
	DECLARE @MaterialCode           VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @LabelType               NVARCHAR(60) = @pLabelType


	declare @companycode varchar(10)='';
	select @companycode = companycode 
	from STB_UserInfo
	where UserID=@pProcessUserID
	

						--	--- Mr.tung 2023-11-21  cập nhật dữ liệu Ngay Thang SX của Vendor cho những Lót bị trống Ngay Thang SX
						--UPDATE STB_MaterialDocLotInfo  
						-- SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot](materialcode,LotNo)  
						--where replace(isnull(LotAttr10,''),' ','')='' and isnull(LotNo,'')<>''
						--and MaterialLocationCode not like 'PROD%'
						--and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH')
						--and MaterialDocNo=@MaterialDocNo


						--UPDATE STB_MaterialLotInfo  
						-- SET   LotAttr10 =  [dbo].[fn_VVT_getdatebyVendorLot](materialcode,LotNo)  
						--where replace(isnull(LotAttr10,''),' ','')='' and isnull(LotNo,'')<>''
						--and MaterialLocationCode not like 'PROD%'
						--and (MaterialLocationCode like '%VN_WH' or MaterialLocationCode like '%BG_WH')
						----- Mr.tung 2023-11-21 

	   
	;WITH LABELINFO AS
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
			MDLI.MaterialDocDetailNo    AS OldMaterialDocDetailNo,
			MDLI.MDLISeqNo              AS OldMDLISeqNo,
			MDLI.MaterialDocDetailNo,
			MDI.DocStatus,
			MDLI.MDLISeqNo,
			MDLI.MaterialLotNo,
			MDLI.LotID,
			MDLI.MaterialCode,
			CASE 
				WHEN MDLI.MaterialCode = 'GBAKAC-608' THEN REPLACE(MM.MaterialName, '(', '-600F(')
				WHEN MDLI.MaterialCode = 'GBAKAC-048' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDLI.MaterialCode = 'GBAKAC-039' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDLI.MaterialCode = 'GBAKAC-050' THEN REPLACE(MM.MaterialName, '(', '-VPC(')
				WHEN MDLI.MaterialCode = 'GBAKAC-033' THEN REPLACE(MM.MaterialName, '(', '-500F(')
				ELSE MM.MaterialName 
			END AS MaterialName,
			MM.MaterialSpec,
			MDLI.MaterialStockAttribute,			
			MDLI.StockAttrib1,
			MDLI.StockAttrib2,
			MDLI.StockAttrib3,			
			ROUND(MDLI.StockQty, 2) AS StockQty ,
			MDLI.MaterialLocationCode,
			MDLI.MaterialDocNo,
			MDLI.MaterialDocNo         AS OldMaterialDocNo,
			MDLI.PackingID,
			MDLI.IsChecked,
			MDLI.LotNo,
			MDLI.CreateDateTime,
		  --MDLI.CreateUserID,
			(SELECT UserName FROM VW_UserInfo UR WHERE UR.UserId = MDLI.ChangeUserID)  AS CreateUserID,                -- 이름으로 변경 (2019.03.12, kilee추가)
			MDLI.ChangeDateTime,
		  --MDLI.ChangeUserID,
			(SELECT UserName FROM VW_UserInfo UR WHERE UR.UserId = MDLI.ChangeUserID)  AS ChangeUserID,               -- 이름으로 변경 (2019.03.12, kilee추가)
			MDLI.ChangeDateTime,
			MDLI.LotAttr01                                     AS MODEL,
			MDLI.LotAttr02                                     AS Production_Order,
			MM.MaterialUnit                                   AS MaterialUnit , 
			CI.CustomerName,
			CONVERT(VARCHAR(10), MDI.BasicDate, 120) AS GRDate,                                                             --
			LBI.CommandType,
			LBI.LabelType                                       AS LabelType,
			case when @companycode='VVT' then LBI.FormatName+'NewVietNam' else LBI.FormatName end   AS LabelFormatName,

			LBI.PrinterName,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04,
			MM.MMExtInt01,                                                                                                                                                                 -- Master Table의 [유효일]                      (2019.03.11 kilee 추가)
			case when  isnull(MDLI.LotAttr10,'')='' then  ''  when ISDATE(MDLI.LotAttr10)=1  then MDLI.LotAttr10 else N'Error Date LotAttr10_Lỗi ngày tháng' end LotAttr10,  --MR.Tung prevent EXCEPTION convert DATETIME 2023-11-17     
			--MM.MMExtInt01 AS Test,                                                                                                                                                            -- STB_MaterialDocLotInfo table의  Lotattr10 [제조일자]  (2019.03.11 kilee 추가)			
		 --  DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10)   AS PackDate_a,                                                                                                    -- [유효기간] 이전백업
		 -- CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01-1, MDLI.Lotattr10), 121)  AS PackDate_b,                                                              -- [유효기간] 이전백업2

		  --MR.Tung prevent EXCEPTION convert DATETIME 2023-11-17
		  
		 case when  isnull(MDLI.LotAttr10,'')='' then  ''
		 	  WHEN MDLI.MaterialCode = 'MDFLUX-002' THEN CONVERT(VARCHAR(10), DATEADD(DAY, (MM.MMExtInt01*30)-1, CAST(MDLI.LotAttr10 AS DATE)), 121)    -- 09/04/2026 [Just for code: 'MDFLUX-002' = 179 days] -- ThucTD 
			  when @companycode='VVT' and ISDATE(MDLI.Lotattr10)=1  then CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(day,  MM.MMExtInt01*30, MDLI.Lotattr10), 121)), 121)
		      when  ISDATE(MDLI.LotAttr10)=1  then  CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
			  else N'Error Date LotAttr10_Lỗi ngày tháng' end  AS PackDate,   -- [유효기한] = [유효일] + [제조일자] -1           (2019.03.12 kilee 추가)

		-- SMQ.DecisionDateTime  AS TestDate,                                                                                                                                        -- [검사일] 이전백업           
			--CONVERT(VARCHAR(10), SMQ.DecisionDateTime, 121)   AS TestDate,   -- STB_MaterialQcSampleResult 수입검사 [검사일]
		 -- SMQ.DecisionUserID                                                                                                                                           AS TestUser,   -- STB_MaterialQcSampleResult 수입검사 [검사자] 이전백업
			(SELECT UserName FROM VW_UserInfo UR WHERE UR.UserId = SMQ.DecisionUserID)  AS TestUser,  -- STB_MaterialQcSampleResult 수입검사 [검사자]  
			1              AS LabelQty,                                                                                                                                                       -- 바코드출력라벨 고정인듯 (기존소스)
			MST.productGroupCode,
			'' as StartPeriod,
			CASE WHEN MDD.MDDExtBit01 = 1 THEN '[개발]' ELSE '' END AS MDDExtBit01 , --개발품 여부,
			LevelJIANGHAI
	FROM 	STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
			    LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	 ON MDLI.MaterialCode = MM.MaterialCode
			    LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK) ON MDI.MaterialDocNo = MDLI.MaterialDocNo
			    LEFT OUTER JOIN STB_CustomerInfo CI WITH (NOLOCK)		 ON (CI.CustomerCode = MDI.SourceCustomerCode)				
			    LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)	 ON MLI.ModelCode = MDLI.MaterialCode               AND	 MLI.LabelType = @LabelType                                                          -- @LabelType  => PartLabel				
			    LEFT OUTER JOIN LABELINFO LBI				                 ON LBI.LabelType = @LabelType                          AND	 LBI.FormatName = MLI.FormatName    AND	LBI.RankIndex = 1                -- LABELINFO는 위에서 만든 TABLE
			    LEFT OUTER JOIN STB_MaterialMaster MST				         ON MDLI.MaterialCode = MST.MaterialCode				
			 -- LEFT OUTER JOIN STB_MaterialDocDetail MDD				     ON MDLI.MaterialDocNo = MDD.MaterialDocNo                          -- 두번째화면 Table			
				LEFT OUTER JOIN STB_MaterialDocDetail MDD				     ON MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo             -- 두번째화면 Table			
			    LEFT OUTER JOIN STB_MaterialQcInfo  SMQ			         ON MDD.MaterialIqcNo = SMQ.MaterialQcNo                              -- 수입검사 Table 정보 추가
			 -- LEFT OUTER JOIN STB_MaterialLotInfo MLI2  ON MLI2.LotID = MDLI.LotID

	WHERE 1=1
--		AND 	((@MaterialDocNo = '*') OR (MDLI.MaterialDocNo = @MaterialDocNo)) 
--		AND 	((@MaterialDocDetailNo = '*') OR (MDLI.MaterialDocDetailNo = @MaterialDocDetailNo)) 
--		AND 	((@MaterialCode = '*') OR (MDLI.MaterialCode = @MaterialCode))
		AND	((MDLI.MaterialDocNo = @MaterialDocNo)) 
		AND	((MDLI.MaterialDocDetailNo = @MaterialDocDetailNo)) 
		AND	((@MaterialCode = '*') OR (MDLI.MaterialCode = @MaterialCode))
	ORDER BY MDLI.MDLISeqNo


END
