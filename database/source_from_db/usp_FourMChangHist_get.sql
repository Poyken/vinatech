-- ========================================================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2021-02-18
-- Browsable : True
-- Group : 공통
-- Description:	생산관리 > 일계획관리 > [B457] 4M변경이력
-- Modified:

-- 프로시저실행 :  [usp_FourMChangHist_get] '','','190607000006','','2019-01-01 00:00:00','2019-06-10 17:20:00',''
-- ========================================================================================================================

CREATE PROCEDURE [dbo].[usp_FourMChangHist_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pMaterialDocType VARCHAR(20) = NULL,	-- 수불유형
						@pMaterialDocTypeCode VARCHAR(20) = NULL	-- 수불문서 유형
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo         Varchar(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '' ELSE @pMaterialDocNo END
	--DECLARE @FromDate                Date        = @pFromDate
	--DECLARE @ToDate                   Date        = @pToDate

	DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate     DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	DECLARE @MaterialDocType       Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '*' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode Varchar(20) =  CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '*' ELSE @pMaterialDocTypeCode END
	DECLARE @PickingAssignQty       Int

   -- SQL 조회부분
  
	SELECT FMC.TimeCode
	        , Case When FMC.TimeCode = 1 Then '주간'
			         When FMC.TimeCode = 2 Then '야간'
					 When FMC.TimeCode = 3 Then '휴무' Else '기타' End TimeName
			, FMC.ProdUserID 
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.ProdUserID ) As ProdUserNM
			, FMC.Approver
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.Approver ) As ApproverNM
			, FMC.LotNo
			, FMC.LotNo2
			, FMC.LotNo3
			, FMC.MaterialCode
			, FMC.MachineCode
			, (SELECT SMM.MachineName From STB_MachineMaster SMM Where SMM.MachineCode = FMC.MachineCode ) As MachineName
			, FMC.ChangeDateTime
			, FMC.DetailContent
			, FMC.ItemCode
			, FMC.Inspector
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.Inspector ) As InspectorNM
			, FMC.CreateDateTime
			, FMC.CreateUserID          
			, FMC.ChangeDateTime
			, FMC.ChangeUserID              
			, FMC.ChangesReasons 
			, FMC.Unusual                                        
	 FROM STB_FourMChangHist FMC
	WHERE 1=1
	  AND FMC.CreateDateTime Between @pFromDate AND @pToDate
	 Order by FMC.CreateDateTime ASC

END


/*
-- 2021.04.07 컬럼추가

ALTER TABLE STB_FourMChangHist  ADD [LotNo2]  Varchar(18)
ALTER TABLE STB_FourMChangHist  ADD [LotNo3]  Varchar(18)


select * from STB_FourMChangHist
where 1=1
Order By CreateDateTime desc

*/