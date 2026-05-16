-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : ???? > ????? > ???? ?????? > ?????? (?????)
-- Description:	????? ?????
-- Modified: ItemSpec ??
--           VPC ??? ?? ????, ??, ?? ?? 2021-03-26 By Jackaroe
-- =============================================

CREATE PROCEDURE [dbo].[usp_SetInfo_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pUtcOffset INT,
				@pPONo VARCHAR(20) = NULL,
				@pDayPlanNo VARCHAR(20) = NULL,
				@pLabelType NVARCHAR(30) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '%' ELSE @pDayPlanNo END
	DECLARE @LabelType NVARCHAR(30) = @pLabelType
	
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
	), MainAssemble AS
	(
		SELECT
				MAPI.ControlNo,
				COUNT(*) AS AssmCount
		FROM
				STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
		WHERE
				MAPI.ControlNo IN (
									SELECT 
											ControlNo 
									FROM 
											STB_SetInfo SI WITH(NOLOCK) 
									WHERE
											SI.PONo = @PONo AND
											SI.DayPlanNo LIKE @DayPlanNo
								)
		GROUP BY
				MAPI.ControlNo
	)
	SELECT
			SI.ControlNo AS OldControlNo,
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			--MM.MaterialName,
			case when SI.ControlNo IN ('20251004000008', '20251004000009') THEN 'VEL10403R8157D (1040)'  -- following Mr.Tinh's request
			     when SI.ControlNo = '20251121000286' THEN 'WEC3R0335QG(0820 Low)' --following Mrs. Phuong Anh's request
				else MM.MaterialName END AS MaterialName,
			SI.SetSeq,
			SI.IsLineInput,
			SI.IsLoss,
			SI.IsDefect,
			SI.CurrentRouteCode,
			SI.InternalProdNo,
			SI.OutSetNo,
			SI.OutSetNoSeq,
			SI.Barcode,
			SUBSTRING(SI.Barcode, 16, 3) AS Cutno ,
			SI.InputLineCode,
			LI.LineName,
			dbo.fnGetLocalTime(SI.InputJobDate, @pUtcOffset) AS InputJobDate,
			SI.InputShiftCode,
			dbo.fnGetLocalTime(SI.InputDateTime, @pUtcOffset) AS InputDateTime,
			SI.DefectQty,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.SalesOrderNo,
			SI.SOISequence,
			SI.IsOutboundFinalInspection,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotCreateDateTime,
			SI.LotDecisionResult,
			SI.GradeCode,
			SI.GradeChangeJobDate,
			SI.GradeChangeShiftCode,
			SI.GradeChangeDateTime,
			SI.GradeChangeUserID,
			SI.GradeModelCode,
			SI.GradeChangeSetNo,
			SI.PrintDate,
			SI.LineOutTactTime,
			SI.ProdQty,
			SI.SIExtText01,
			SI.SIExtText02,
			SI.SIExtText03,
			SI.SIExtText04,
			SI.SIExtText05,
			SI.SIExtInt01,
			SI.SIExtInt02,
			SI.SIExtInt03,
			SI.SIExtInt04,
			SI.SIExtInt05,
			SI.SIExtReal01,
			SI.SIExtReal02,
			SI.SIExtReal03,
			SI.SIExtReal04,
			SI.SIExtReal05,
			SI.CreateDateTime,
			--SI.CreateUserID,
			( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SI.CreateUserID) AS CreateUserID,
			SI.ChangeDateTime,
			SI.ChangeUserID,
			SUBSTRING(SI.Barcode,10,2) AS MixBatchNo,
			SUBSTRING(SI.Barcode,12,1) AS EDLC,
			0 AS LabelQty,
			LBI.CommandType,
			LBI.FormatName,
			LBI.LabelType,
			LBI.PrinterName,
			MA.AssmCount,
			MBI.MBIExtText04 + '(V)-' + MBIExtText05 + '(F)' AS ItemSpec,
			LotUniqueNumber,
			DPP.LineCode,
			LI2.LineName AS LineNameDPP,
			MBI.MBIExtText03 AS ModelType,
			MBI.MBIExtText04 AS ModelVolt,
			MBI.MBIExtText05 AS ModelFarad
			

       FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				        ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)			ON MLI.ModelCode = SI.MaterialCode        AND MLI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LBI										    ON LBI.LabelType = @LabelType             AND LBI.FormatName = MLI.FormatName     AND LBI.RankIndex = 1
			LEFT OUTER JOIN MainAssemble MA				                    ON MA.ControlNo = SI.ControlNo
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)			ON SI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)            ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_LineInfo LI2 WITH(NOLOCK)				    ON LI2.LineCode = DPP.LineCode
	   
	   WHERE 1=1
		AND SI.PONo = @PONo 
		AND SI.DayPlanNo LIKE @DayPlanNo

	ORDER BY SI.ControlNo

END

(1 rows affected)
