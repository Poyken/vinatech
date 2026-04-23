-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020.06.11
-- Browsable : true
-- Group : 자재관리 > 
-- Description: 
-- Modified: 유효일 체크하여 메일발송 또는 SMS

-- Exec : usp_MaterialWarehouseCheck_get 'kilee','Korean','VNT','VNT_F1','kilee','ASSYLINE-05','O','ROH_WH','ROUTE_WH','123'
-- =============================================================================================
Create PROCEDURE [dbo].[usp_MaterialWarehouseCheck_get]
							@pProcessUserID varchar(20),
							@pProcessLanguage varchar(20),
							@pCompanyCode VARCHAR(20) = NULL,
							@pWorkCenterCode VARCHAR(20) = NULL,
							@pWorkerCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(20) = NULL,
							@pWarehouseInOutCode VARCHAR(1) = NULL,
							@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
							@pTargetMaterialWarehouseCode VARCHAR(20) = NULL,
							@pLotID VARCHAR(500) = NULL
AS

BEGIN
	Declare @CompanyCode                    VARCHAR(20) = @pCompanyCode
			 ,@WorkCenterCode                  VARCHAR(20) = @pWorkCenterCode
			 ,@WorkerCode                       VARCHAR(20) = @pWorkerCode
			 ,@LineCode                           VARCHAR(20) = @pLineCode
			 ,@WarehouseInOutCode            VARCHAR(1) = @pWarehouseInOutCode
			 ,@SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
			 ,@TargetMaterialWarehouseCode VARCHAR(20) = @pTargetMaterialWarehouseCode
			 ,@LotID                                 VARCHAR(500) = RTRIM(@pLotID)                                      -- 2020.04.16 RTRIM 추가 

	Declare @MaterialLotNo         VARCHAR(20) 
	         , @ProcessedLotID        VARCHAR(20)
		     , @TargetLocation         VARCHAR(20)
			 , @MaterialCode           VARCHAR(30)          --2020.04.27 추가
			 , @MaterialDocDetailNo VARCHAR(30)          --2020.05.12 추가
     	 	 
	 Declare @MakeDate  VARCHAR(20)
	 Declare @PackDate   VARCHAR(20)	 	
	 Declare @MakeDate2  VARCHAR(20)
	 Declare @PackDate2   VARCHAR(20)	 	   
	 Declare @Todate   VARCHAR(20)	 	   


	 -- 1. 해당제품의 가장 빠른 유효일 파악
		 SELECT	TOP 1 @MakeDate = MDLI.Lotattr10                                                                                                                                                       
						   , @PackDate  =CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
		 FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  				LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK)  ON MDLI.MaterialCode = MM.MaterialCode			 
					LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK)  ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
			WHERE 1=1			
				AND	MDLI.MaterialCode = @MaterialCode					
			ORDER BY MDLI.MDLISeqNo

      -- 2. 해당 Lot의 유효일 파악
	         SELECT	    @MakeDate2 = MDLI.Lotattr10                                                                                                                                                       
						   , @PackDate2  =CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
						   , @Todate = CONVERT(VARCHAR(10),	GetDate(), 121)
		 FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  				LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode			 
					LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK) ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
			WHERE 1=1			 
				AND MDLI.LOTID = @LotID			

	 -- -- 3. 해당 Lot의 유효일이 가장빠르지 않으면 에러 (구보겸에 의해서 우선 주석처리)
	 --   IF @PackDate > @PackDate2         
		    
		--	BEGIN
		--		 RAISERROR(' 출고처리가 실패하였습니다. (제조일자가 앞선 Lot가 존재합니다) ' ,16, 1)           
		--		 RETURN
		--	END

  -- 2020.06.03 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------

   -- 2020.06.04 유효일자 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- 2. 해당 Lot의 유효일이 가장 빠르지 않으면 에러
	 
	    IF @Todate  <  @PackDate 
		    
			BEGIN
				 RAISERROR(' 유효일자가 지난 자재입니다. 확인 바랍니다. ' ,16, 1)           
				 RETURN
			END

   --2020.06.04 유효일자 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------



	End