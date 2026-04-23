-- ========================================================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2021-04-29
-- Browsable : True
-- Group : 공통
-- Description:	생산관리 > 일계획관리 > [B457] 4M변경이력 > 2번째 Grid화면
-- Modified:

-- 프로시저실행 :  [usp_FourMChangHist_Second_get] '','', 'VJLM102R750630'
-- ========================================================================================================================

Create PROCEDURE [dbo].[usp_FourMChangHist_Second_get_20210504]
						@pProcessUserID     VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(20) = Null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LotNo      Varchar(20) = @pLotNo


 -- SQL 조회부분
	SELECT 
			  FMC.LotNo As LotNo
			, FML.Unusual_First                                                   As Unusual
			, Case When FMC.ItemCode = 'P' Then '합격'
					When FMC.ItemCode = 'N' Then '불합격' ELSE '' End As PassOrNot 
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.Inspector ) As InspectorNM
	 FROM STB_FourMChangHist FMC
	          Left Outer Join STB_FourMLotNoHist FML On FML.LotNo = FMC.LotNo
      Where FMC.LotNo = @LotNo

	    Union All

       SELECT 
			 FMC.LotNo2 As LotNo
			, FML.Unusual_Second As Unusual
			, Case When FMC.ItemCode = 'P' Then '합격'
					When FMC.ItemCode = 'N' Then '불합격' ELSE '' End As PassOrNot 
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.Inspector ) As InspectorNM
	 FROM STB_FourMChangHist FMC
	          Left Outer Join STB_FourMLotNoHist FML On FML.LotNo = FMC.LotNo
	  Where FMC.LotNo =@LotNo

	   Union All

       SELECT 
			 FMC.LotNo3 As LotNo
			, FML.Unusual_Second As Unusual
			, Case When FMC.ItemCode = 'P' Then '합격'
					When FMC.ItemCode = 'N' Then '불합격' ELSE '' End As PassOrNot 
			, (SELECT  SPW.WorkerName From STB_ProdWorkerInfo SPW Where SPW.WorkerCode = FMC.Inspector ) As InspectorNM
	 FROM STB_FourMChangHist FMC
	          Left Outer Join STB_FourMLotNoHist FML On FML.LotNo = FMC.LotNo
	   Where FMC.LotNo =@LotNo

END