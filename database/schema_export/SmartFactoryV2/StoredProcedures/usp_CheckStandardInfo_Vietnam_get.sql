-- Procedure: usp_CheckStandardInfo_Vietnam_get
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-07-26
-- Description : 
-- Modified :
-- [usp_CheckStandardInfo_get] '','','','ASSYLINE-13','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckStandardInfo_Vietnam_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pCheckClassNo VARCHAR(20) = NULL,
				@pLineCode VARCHAR(20) = NULL,
				@pMachineCode VARCHAR(20) = NULL,
				@pCheckPartNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @CheckClassNo VARCHAR(20) = CASE WHEN ISNULL(@pCheckClassNo, '') = '' THEN '%' ELSE @pCheckClassNo END
	Declare @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '%' ELSE @pLineCode END
	Declare @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '%' ELSE @pMachineCode END
	Declare @CheckPartNo VARCHAR(20) = CASE WHEN ISNULL(@pCheckPartNo, '') = '' THEN '%' ELSE @pCheckPartNo END

	if(@LineCode='%' and @MachineCode='%' and @CheckPartNo='%')
	begin
		declare @warning varchar(200)='Ban can chon it nhat 1 trong 3 dieu kien Tim kiem: CheckPartNo, Ma Line, Ma may';
		raiserror (@warning,16,1);
		return;
	end

	SELECT CSI.CheckStandardNo
		  ,CSI.CheckClassNo
		  ,CCI.CheckClassName
		  ,CSI.LineCode
		  ,LI.LineName
		  ,CSI.MachineCode
		  ,MM.MachineName
		  ,CSI.CheckPartNo
		  ,CPI.CheckPartName
		  ,CSI.CheckPartPicture1
		  ,CSI.CheckPartPicture2
		  ,CSI.CheckPartPicture3
		  ,CSI.CheckPartPicture4
		  ,CSI.CheckPartPicture5
		  ,CSI.CheckPartContent
		  ,CSI.RelationshipContent
		  ,CSI.CheckStandard
		  ,CSI.CheckMethod
		  ,CSI.CheckRepeatCycleCode
		  ,BC.Description AS CheckRepeatCycleCodeName
		  ,CSI.CheckStartDate
		  ,CSI.CheckTime   --원본백업
		  ,CONVERT(CHAR(8), CSI.CheckTime, 108) as OnlyTime  
		  ,CSI.CheckDateOption
		  ,BC2.Description AS CheckDateOptionName
		  ,CSI.DayOfWeekCode
		  ,BC3.Description AS DayOfWeekName
		  ,CSI.CreateDateTime
		  ,CSI.CreateUserID
		  ,CSI.ChangeDateTime
		  ,CSI.ChangeUserID
		  ,CSI.IsUsed
		  ,CSI.ImageReferenceNo
	  FROM STB_CheckStandardInfo CSI
			  LEFT OUTER JOIN STB_CheckClassInfo CCI		ON CSI.CheckClassNo = CCI.CheckClassNo
			  LEFT OUTER JOIN STB_LineInfo LI					ON CSI.LineCode = LI.LineCode
			  LEFT OUTER JOIN STB_MachineMaster MM		ON CSI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_CheckPartInfo CPI			ON CSI.CheckPartNo = CPI.CheckPartNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON CSI.CheckRepeatCycleCode = BC.ItemCode	   AND BC.CodeGroup = 'CheckRepeatCycle'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2		ON CSI.CheckDateOption = BC2.ItemCode	   AND BC2.CodeGroup = 'CheckDateOption'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3		ON CSI.DayOfWeekCode = BC3.ItemCode	   AND BC3.CodeGroup = 'DayOfTheWeek'

	  WHERE ISNULL(CSI.CheckClassNo, '') LIKE @CheckClassNo
	    AND ISNULL(CSI.LineCode, '') LIKE @LineCode
		AND ISNULL(CSI.MachineCode, '') LIKE @MachineCode
		AND ISNULL(CSI.CheckPartNo, '') LIKE @CheckPartNo
		AND CSI.IsUsed = CONVERT(BIT, 1)

	  --ORDER BY CSI.CheckStandardNo, CSI.CheckTime
	  ORDER BY  CSI.CheckStandardNo

END
GO

