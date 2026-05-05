-- Procedure: usp_AddDate

--  EXEC usp_DoChangeMaterialDocLotInfo ' ', ' ' , NULL

-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-09-30
-- Browsable : true
-- Group : 자재수불관리 
-- Description:	자재수불 LOT IUD - [F330] 자재입고 및 라벨발행 화면의 세번째 Grid Lot변경 Button

-- 2019-03-11 제조일자 업데이트 수정 (kilee) 
-- 2020-03-25 Fix상태 체크 IF문 주석처리 (kilee)
-- =============================================

-- EXEC usp_DoChangeMaterialDocLotInfo '','',''

CREATE PROCEDURE [dbo].[usp_AddDate]
	@pLotID VARCHAR(100),       
	@pStartDate VARCHAR(20)

AS

BEGIN
	SET NOCOUNT ON;
				DECLARE @LotID VARCHAR(100) = @pLotID
				DECLARE @StartDate VARCHAR(20) =@pStartDate


				--raiserror(@pStartDate,16,1)
					UPDATE STB_MaterialDocLotInfo  
						 SET   LotAttr10 = @StartDate
						 where  LotID = @LotID 
							  
						
				 UPDATE STB_MaterialLotInfo  
				 SET      LotAttr10 = @StartDate
					 where  LotID = @LotID 
				 
	
	
END
GO

