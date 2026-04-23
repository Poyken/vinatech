
-- =========================================================================================
-- Author:	    Kevin
-- Create date: 2024-04-23
-- Browsable : false
-- Group : EA Vietnam Team
-- Description:	The show LotID in F330
  
-- =========================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialDocLotInfo_get_F332] -- EXEC usp_MaterialDocLotInfo_get_F332 '','','ML20240410000003'
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotID VARCHAR(20) = NULL
						
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LotID   VARCHAR(20) = CASE WHEN ISNULL(@pLotID,'') = '' THEN '' ELSE @pLotID END
	
	declare @companycode varchar(10)='';
	select @companycode = companycode 
	from STB_UserInfo
	where UserID=@pProcessUserID
	
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
			MM.MaterialName,
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
			--LBI.CommandType,
			--LBI.LabelType                                       AS LabelType,
			--case when @companycode='VVT' then LBI.FormatName+'NewVietNam' else LBI.FormatName end   AS LabelFormatName,

			--LBI.PrinterName,
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
			  when @companycode='VVT' and ISDATE(MDLI.Lotattr10)=1  then CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(day,  MM.MMExtInt01*30, MDLI.Lotattr10), 121)), 121)
		      when  ISDATE(MDLI.LotAttr10)=1  then  CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
			  else N'Error Date LotAttr10_Lỗi ngày tháng' end  AS PackDate,   -- [유효기한] = [유효일] + [제조일자] -1           (2019.03.12 kilee 추가)
		
		-- SMQ.DecisionDateTime  AS TestDate,                                                                                                                                        -- [검사일] 이전백업           
			CONVERT(VARCHAR(10), SMQ.DecisionDateTime, 121)   AS TestDate,   -- STB_MaterialQcSampleResult 수입검사 [검사일]
		 -- SMQ.DecisionUserID                                                                                                                                           AS TestUser,   -- STB_MaterialQcSampleResult 수입검사 [검사자] 이전백업
			(SELECT UserName FROM VW_UserInfo UR WHERE UR.UserId = SMQ.DecisionUserID)  AS TestUser,  -- STB_MaterialQcSampleResult 수입검사 [검사자]  
			1              AS LabelQty,                                                                                                                                                       -- 바코드출력라벨 고정인듯 (기존소스)
			MST.productGroupCode
	FROM 	STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
			    LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	 ON MDLI.MaterialCode = MM.MaterialCode
			    LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK) ON MDI.MaterialDocNo = MDLI.MaterialDocNo
			    LEFT OUTER JOIN STB_CustomerInfo CI WITH (NOLOCK)		 ON (CI.CustomerCode = MDI.SourceCustomerCode)				
			    --LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)	 ON MLI.ModelCode = MDLI.MaterialCode               AND	 MLI.LabelType = @LabelType                                                          -- @LabelType  => PartLabel				
			  --  LEFT OUTER JOIN LABELINFO LBI				                 ON LBI.LabelType = @LabelType                          AND	 LBI.FormatName = MLI.FormatName    AND	LBI.RankIndex = 1                -- LABELINFO는 위에서 만든 TABLE
			    LEFT OUTER JOIN STB_MaterialMaster MST				         ON MDLI.MaterialCode = MST.MaterialCode				
			 -- LEFT OUTER JOIN STB_MaterialDocDetail MDD				     ON MDLI.MaterialDocNo = MDD.MaterialDocNo                          -- 두번째화면 Table			
				LEFT OUTER JOIN STB_MaterialDocDetail MDD				     ON MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo             -- 두번째화면 Table			
			    LEFT OUTER JOIN STB_MaterialQcInfo  SMQ			         ON MDD.MaterialIqcNo = SMQ.MaterialQcNo                              -- 수입검사 Table 정보 추가
			 -- LEFT OUTER JOIN STB_MaterialLotInfo MLI2  ON MLI2.LotID = MDLI.LotID

	WHERE 1=1
--		AND 	((@MaterialDocNo = '*') OR (MDLI.MaterialDocNo = @MaterialDocNo)) 
--		AND 	((@MaterialDocDetailNo = '*') OR (MDLI.MaterialDocDetailNo = @MaterialDocDetailNo)) 
--		AND 	((@MaterialCode = '*') OR (MDLI.MaterialCode = @MaterialCode))
		AND	((MDLI.LotID = @LotID)) 
		--AND	((MDLI.MaterialDocDetailNo = @MaterialDocDetailNo)) 
		--AND	((@MaterialCode = '*') OR (MDLI.MaterialCode = @MaterialCode))
	ORDER BY MDLI.MDLISeqNo


END


--select * from STB_MaterialDocLotInfo