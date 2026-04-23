-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.02.13
-- Browsable : true
-- Group : 자재관리 > 자재이동관리 > 사내이동창고 > 원자재창고불출이력등록
-- Description: [원자재창고불출이력등록] 화면에서 원자재출고처리 및 반납처리 버튼
-- Modified:
--             2020.04.14 활성탄(GAKCCA-002 등) 예외처리
--             2020.04.16 재출고부분 오류해결 
--             2020.06.03 유효기간이 지난 자재 체크기능 추가 (주영진, 고연 요청)

-- Exec :  usp_MaterialWarehouseInOutHist_iud 'kilee','Korean','VNT','VNT_F1','kilee','ASSYLINE-05','O','ROH_WH','ROUTE_WH','123'
-- =============================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_iud_FIFO]
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

	-- Location
	-- 해당 창고의 첫번째 로케이션으로 지정한다.
	SELECT TOP 1 @TargetLocation = MaterialLocationCode
	  FROM STB_MaterialLocation
	 WHERE MaterialWarehouseCode = @TargetMaterialWarehouseCode
	 ORDER BY MaterialLocationCode ASC

	-- 분리막은 전체 내용에서 LotID를 분리한다. 50,8  -> 2020.04.16 구보겸에 의해 제외
	-- 분리막 구분은 @LotID의 길이가 100자를 넘어가는 것으로 한다. 별도의 기준으로 변경 필요 

	-- 원본 백업
		--IF(LEN(@LotID) > 100)
		-- BEGIN
		--	SET @LotID = SUBSTRING(@LotID, 50, 8)
		-- END

	  -- 2020.04.09 중복된 바코드 처리요청 (구보겸) + 2020.04.13 타겟창고에 따라 조건문추가 
		IF @SourceMaterialWarehouseCode = 'ROH_WH'                     -- 원자재 출고처리의 경우
		
		BEGIN 
				SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
								,  @ProcessedLotID = SM.LotID	
								, @MaterialCode = SM.MaterialCode									
				  FROM (
							SELECT  SML.MaterialLotNo                                                                        
									 , SML.LotID																						   AS LotID
									 , SML.MaterialCode                                                                               AS MaterialCode
									 , SML.PackingID                                                                                   AS PackingID
									 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult	
									 , SML.MaterialLocationCode                                                                     AS MaterialLocationCode				
							FROM                        STB_MaterialLotInfo                  SML
									 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
							WHERE 1=1
							AND SML.MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'					
							AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
						 -- AND (SML.LotID = '202600120#2200039818#H219112362#32#DLC3702' OR SML.LotNo = '202600120#2200039818#H219112362#32#DLC3702')  			          -- TEST용 주석처리
						  ) SM
					WHERE 1=1
						AND SM.ProcessedResult  = '미출고'         
		 END 

		 ELSE      --@TargetLocation = 'ROH_WH'              -- 원자재 반납처리의 경우

		  BEGIN
		  
				   SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
								,  @ProcessedLotID = SM.LotID	
								, @MaterialCode = SM.MaterialCode								
				  FROM (
							SELECT  SML.MaterialLotNo                                                                        
									 , SML.LotID																						   AS LotID
									 , SML.MaterialCode                                                                               AS MaterialCode
									 , SML.PackingID                                                                                   AS PackingID
									 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult	
									 , SML.MaterialLocationCode                                                                     AS MaterialLocationCode				
							FROM                        STB_MaterialLotInfo                  SML
									 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   Or SML.PackingID = MWIOH.ProcessedLotID
							WHERE 1=1
							   AND SML.MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'					
							   AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  									 
						  ) SM
					WHERE 1=1
						AND SM.ProcessedResult  = '정상출고'
                     ORDER by SM.MaterialLotNo 
		  END       				 
---------------------------------------------------------	

   IF @MaterialLotNo IS NULL
   --IF @@ROWCOUNT = 0                  -- 매핑이 안된 LotNo인 경우
		    
			BEGIN
				 RAISERROR(' 현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.' ,16, 1)           
				 RETURN
			END
     
  -- 2020.06.03 선입선출 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  --   Declare @MakeDate  VARCHAR(20)
	 --Declare @PackDate   VARCHAR(20)	 
	 --Declare @MakeDate2  VARCHAR(20)
	 --Declare @PackDate2   VARCHAR(20)	 	   

	 ---- 1. 해당제품의 가장 빠른 유효일 파악
		-- SELECT	TOP 1 @MakeDate = MDLI.Lotattr10                                                                                                                                                       
		--				   , @PackDate  =CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
		-- FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	 -- 				LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK)  ON MDLI.MaterialCode = MM.MaterialCode			 
		--			LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK)  ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
		--	WHERE 1=1
		--		--AND	MDLI.MaterialDocNo = '200522000102'		
		--		--AND	MDLI.MaterialCode = 'GBHNAC-044'		
		--		AND	MDLI.MaterialCode = @MaterialCode	
		--		--AND SML.LotNo = '1004214772004270231'
		--		--AND MDLI.LOTID = 'ML20200522000010'
		--		--AND MDLI.LOTID = @LotID
		--	ORDER BY MDLI.MDLISeqNo

  --    -- 2. 해당 Lot의 유효일 파악
	 --        SELECT	    @MakeDate2 = MDLI.Lotattr10                                                                                                                                                       
		--				   , @PackDate2  =CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
		-- FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	 -- 				LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode			 
		--			LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK) ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
		--	WHERE 1=1
		--	   --AND SML.LotNo = '1004214772004270231'
		--		--AND MDLI.LOTID = 'ML20200522000010'
		--		AND MDLI.LOTID = @LotID			

	 -- -- 3. 해당 Lot의 유효일이 가장빠르지 않으면 에러
	 --   IF @PackDate > @PackDate2         
		    
		--	BEGIN
		--		 RAISERROR(' 출고처리가 실패하였습니다. (제조일자가 앞선 Lot가 존재합니다) ' ,16, 1)           
		--		 RETURN
		--	END

  -- 2020.06.03 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------


    -- 일련번호 채번 
	Declare @MaterialWarehouseInOutHistNo VARCHAR(20)
	Declare @ProductGroupCode                  VARCHAR(20)	

		SELECT    TOP 1  @MaterialDocDetailNo =  SMD.MaterialDocDetailNo	
	           ,               @ProductGroupCode   = SMM.ProductGroupCode                            
		FROM                        STB_MaterialLotInfo         SML				
					LEFT OUTER JOIN STB_MaterialDocLotInfo SMD  ON SML.LotNo = SMD.LotNo                AND SML.LOTID = SMD.LOTID
					LEFT OUTER JOIN STB_MaterialMaster      SMM ON SMM.MaterialCode = SML.MaterialCode
		WHERE 1=1	
		AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  	



   --2020.04.27 추가사항 (활성탄 두제품의 경우에는 바코드를 찍으면 일괄처리되도록 - 구보겸요청) ---------------------------------------------------------------------------------------------
	  -- IF @MaterialCode IN ('GAKCCA-002', 'GAKCCA-003') 	        BEGIN          --예외처리 제품인 경우
		IF @MaterialCode = 'GATCCC-001' Or  @ProductGroupCode  ='A.C'   BEGIN
		
			------------------------------
			 DECLARE CarbonData CURSOR FOR 
				--SELECT SML.LotNo                                        -- 2020.05.20
				SELECT SML.MaterialLotNo                     
				  FROM STB_MaterialDocLotInfo SMD
				          LEFT OUTER JOIN STB_MaterialLotInfo SML ON  SML.LotNo = SMD.LotNo                AND SML.LOTID = SMD.LOTID
				 WHERE SMD.MaterialDocDetailNo = @MaterialDocDetailNo          --'200427000023' --

				 --SELECT MaterialLotNo, *              
				 -- FROM STB_MaterialDocLotInfo
				 --WHERE 1=1
				 --AND CreateDateTime > '2020-05-19 00:00:00'
				 -- and MaterialCode IN (   'GAKCCA-003')
				  
				 -- MaterialDocDetailNo = '200427000023' --@MaterialDocDetailNo




			OPEN CarbonData

			WHILE 1 = 1 
			BEGIN
				FETCH NEXT FROM CarbonData INTO
									 @MaterialLotNo
							
				 IF @@FETCH_STATUS <> 0 
				 BEGIN
							BREAK
				 END
			
			--------------------------------	
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

			-- INSERT 입력
			INSERT INTO STB_MaterialWarehouseInOutHist (
																		MaterialWarehouseInOutHistNo
																	   ,CompanyCode
																	   ,WorkCenterCode
																	   ,SourceMaterialWarehouseCode
																	   ,TargetMaterialWarehouseCode
																	   ,WarehouseInOutCode
																	   ,LotID
																	   ,WorkerCode
																	   ,LineCode
																	   ,CreateUserID
			) VALUES (
							@MaterialWarehouseInOutHistNo
						   ,@CompanyCode
						   ,@WorkCenterCode
						   ,@SourceMaterialWarehouseCode
						   ,@TargetMaterialWarehouseCode
						   ,@WarehouseInOutCode
						   ,@LotID
						   ,@WorkerCode
						   ,@LineCode
						   ,@pProcessUserID
			)

			-- 창고이동
			IF @MaterialLotNo IS NOT NULL 
	
			BEGIN
				EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'                       -- 다른 프로시저 호출 : 정상출고 처리되는 부분
			END

			print @TargetLocation

            print @MaterialLotNo
			

	 
	     IF   @SourceMaterialWarehouseCode = 'ROH_WH'       
	        BEGIN
					UPDATE STB_MaterialWarehouseInOutHist
						 SET ProcessedLotID = @ProcessedLotID
					 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					 			 
			 		SELECT @ProcessedLotID AS LotID
					        , '정상출고'          AS ProcessedResult          -- 조회되면 무조건 [정상출고]

				END

       ELSE        -- 반납의 경우 ProcessedLotID를 제외한다!! (재출고땜시..) 

		  BEGIN
		             UPDATE STB_MaterialWarehouseInOutHist
						 SET ProcessedLotID = ''
					 WHERE 1=1
					   --and MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					   And (LotID = @LotID )  	
					   And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가
					   --And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                                   -- 주석이맞는듯?


				 -- 화면에 표기되는 부분 (조회부분)
				 --IF @MaterialLotNo IS NOT NULL BEGIN
					SELECT @ProcessedLotID AS LotID
							, '반납완료'          AS ProcessedResult          -- 조회되면 무조건 [반납완료]

			END

			END
              	CLOSE CarbonData;
				DEALLOCATE CarbonData;	
				

          
		    END    -- 예외제품에 대한 END




	   --IF @MaterialCode NOT IN ('GAKCCA-002', 'GAKCCA-003') 	BEGIN    -- 정상제품인 경우
	   IF @MaterialCode <> 'GATCCC-001' AND  @ProductGroupCode  <> 'A.C'	    BEGIN
	   ------------- 여기까지
			
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

			-- INSERT 입력
			INSERT INTO STB_MaterialWarehouseInOutHist (
																		MaterialWarehouseInOutHistNo
																	   ,CompanyCode
																	   ,WorkCenterCode
																	   ,SourceMaterialWarehouseCode
																	   ,TargetMaterialWarehouseCode
																	   ,WarehouseInOutCode
																	   ,LotID
																	   ,WorkerCode
																	   ,LineCode
																	   ,CreateUserID
			) VALUES (
							@MaterialWarehouseInOutHistNo
						   ,@CompanyCode
						   ,@WorkCenterCode
						   ,@SourceMaterialWarehouseCode
						   ,@TargetMaterialWarehouseCode
						   ,@WarehouseInOutCode
						   ,@LotID
						   ,@WorkerCode
						   ,@LineCode
						   ,@pProcessUserID
			)

			-- 창고이동
			IF @MaterialLotNo IS NOT NULL 
	
			BEGIN
				EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'                       -- 다른 프로시저 호출 : 정상출고 처리되는 부분
			END


    --END  --추가부분 End

	-- ProcessedLotID 업데이트 이 부분이 정상출고로 업데이트 되는 부분인데, 수정  (2020.04.16)
	   IF   @SourceMaterialWarehouseCode = 'ROH_WH'       
	        BEGIN
					UPDATE STB_MaterialWarehouseInOutHist
						 SET ProcessedLotID = @ProcessedLotID
					 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					 			 
			 		SELECT @ProcessedLotID AS LotID
					        , '정상출고'          AS ProcessedResult          -- 조회되면 무조건 [정상출고]

				END

       ELSE        -- 반납의 경우 ProcessedLotID를 제외한다!! (재출고땜시..) 

		  BEGIN
		             UPDATE STB_MaterialWarehouseInOutHist
						 SET ProcessedLotID = ''
					 WHERE 1=1
					   --and MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					   And (LotID = @LotID )  	
					   And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가
					   And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                                   -- 2020.04.23 추가


				 -- 화면에 표기되는 부분 (조회부분)
				 --IF @MaterialLotNo IS NOT NULL BEGIN
					SELECT @ProcessedLotID AS LotID
							, '반납완료'          AS ProcessedResult          -- 조회되면 무조건 [반납완료]

							  END

              END   -- 추가부분

END
