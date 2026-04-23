-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.02.13
-- Browsable : true
-- Group : 자재관리
-- Description: 원자재창고불출이력등록
-- Modified:

-- usp_MaterialWarehouseInOutHist_iud 'kilee','Korean','VNT','VNT_F1','','','','','','202600120#2200039818#H219112362#32#DLC3702'

-- =============================================

CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_iud_20200410]
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
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	       ,@WorkerCode VARCHAR(20) = @pWorkerCode
	       ,@LineCode VARCHAR(20) = @pLineCode
	       ,@WarehouseInOutCode VARCHAR(1) = @pWarehouseInOutCode
	       ,@SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
	       ,@TargetMaterialWarehouseCode VARCHAR(20) = @pTargetMaterialWarehouseCode
	       ,@LotID VARCHAR(500) = @pLotID

	Declare @MaterialLotNo VARCHAR(20) 
	       ,@ProcessedLotID VARCHAR(20)
		   ,@TargetLocation VARCHAR(20)

	-- Location
	-- 해당 창고의 첫번째 로케이션으로 지정한다.
	SELECT TOP 1 @TargetLocation = MaterialLocationCode
	  FROM STB_MaterialLocation
	 WHERE MaterialWarehouseCode = @TargetMaterialWarehouseCode
	 ORDER BY MaterialLocationCode ASC

	-- 분리막은 전체 내용에서 LotID를 분리한다. 50,8
	-- 분리막 구분은 @LotID의 길이가 100자를 넘어가는 것으로 한다. 별도의 기준으로 변경 필요 
	IF(LEN(@LotID) > 100)

	 BEGIN
		SET @LotID = SUBSTRING(@LotID, 50, 8)
	 END


	-- MaterialLotNo  (원본백업)
	--SELECT TOP 1 @MaterialLotNo = MaterialLotNo                                             
	--                , @ProcessedLotID = LotID
	--  FROM STB_MaterialLotInfo
	-- WHERE 1=1
	--    AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'
	--    AND (LotID = @LotID OR LotNo = @LotID)                                                -- 비나텍 바코드, 업체 바코드 중 하나만 맞아도 조회
	-- ORDER BY LotID ASC
	 

	  -- 2020.04.09 중복된 바코드 처리요청 (구보겸)
	    SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
		                ,  @ProcessedLotID = SM.LotID							            
		  FROM (
					SELECT  SML.MaterialLotNo                                                                        
					         , SML.LotID																						   AS LotID
							 , SML.MaterialCode                                                                               AS MaterialCode
							 , SML.PackingID                                                                                   AS PackingID
							 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult					
					FROM                        STB_MaterialLotInfo                  SML
							 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
					WHERE 1=1
					AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'					
					AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
				 -- AND (SML.LotID = '202600120#2200039818#H219112362#32#DLC3702' OR SML.LotNo = '202600120#2200039818#H219112362#32#DLC3702')  			          -- TEST용 주석처리
				  ) SM
		    WHERE 1=1
		        AND SM.ProcessedResult  = '미출고'


	 --  SELECT   *
	 -- FROM STB_MaterialLotInfo 
	 --WHERE 1=1
	 --  -- AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'
	 --  AND CreateDateTime > '2020-04-06 00:00:00'
	 --  AND (LotID =  '202600120#2200043904#h219121842#32#dlc3702' OR LotNo =  '202600120#2200043904#h219121842#32#dlc3702')                                                -- 비나텍 바코드, 업체 바코드 중 하나만 맞아도 조회

	 --   --AND (LotID =  'WEC3R0335QG 3.0 3.3 2003240912' OR LotNo =  'WEC3R0335QG 3.0 3.3 2003240912')                                                -- 비나텍 바코드, 업체 바코드 중 하나만 맞아도 조회
	 --ORDER BY LotID ASC



	 -- 지금은 사용하지 말 것!
	 --IF @MaterialLotNo IS NULL    -- 비교할 때는 "IS, IS NOT"   / 업데이트문은 "=" 
	 --   BEGIN
		--END
  --    END



   IF @@ROWCOUNT = 0                  -- 매핑이 안된 LotNo인 경우
		    
			BEGIN
				 RAISERROR(' 현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.' ,16, 1)           
				 RETURN
			END




	-- 일련번호 채번
	Declare @MaterialWarehouseInOutHistNo VARCHAR(20)
	Declare @PackingID VARCHAR(20)

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT


	---- INSERT하기전에 SELECT해보고 있으면 처리된걸로 (2020.04.03)

	--    -- 2020.04.09 중복된 바코드 처리요청 (구보겸)
	--    SELECT  --TOP 1 SM.MaterialLotNo 
	--	   --      ,  SM.LotID
	--			 --, SM.MaterialCode
	--			  @PackingID = SM.PackingID
	--			 --, SM.ProcessedResult
			
	--	  FROM (
	--				SELECT  SML.MaterialLotNo                                                                        
	--				         , SML.LotID																						   AS LotID
	--						 , SML.MaterialCode                                                                               AS MaterialCode
	--				         , SML.PackingID                                                                                   AS PackingID
	--						 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult					
	--				FROM                        STB_MaterialLotInfo                  SML
	--						 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
	--				WHERE 1=1
	--				--AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'
	--				--AND (SML.LotID = '202600120#2200039818#H219112362#32#DLC3702' OR SML.LotNo = '202600120#2200039818#H219112362#32#DLC3702')  			
	--				  AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
	--			  ) SM
	--	    WHERE 1=1
	--	        AND SM.ProcessedResult  = '미출고'





		  --SELECT  SM.LotID
				--  , SM.MaterialCode
				--  , SM.PackingID
				--  , SM.ProcessedResult
		  --FROM (
				--	SELECT  SML.LotID																						   AS LotID
				--			 , SML.MaterialCode                                                                               AS MaterialCode
				--			 , SML.PackingID                                                                                   AS PackingID
				--			 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult
					
				--	FROM                          STB_MaterialLotInfo                  SML
				--			 RIGHT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON MWIOH.LotID = SML.LotID
				--	WHERE 1=1
				--	--AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'
				--	AND (MWIOH.LotID = @LotID )					
				--  ) SM
		  --  WHERE 1=1
		  --      AND SM.ProcessedResult  = '미출고'





		 --IF @@ROWCOUNT = 0                  -- 매핑이 안된 LotNo인 경우
		    
			--BEGIN
			--	 RAISERROR(' 현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.' ,16, 1)           
			--	 RETURN
			--END


        --ELSE -- @@ROWCOUNT > 0                   -- 미출고가 있는 경우


			--BEGIN
						
			--		  SELECT 	@WorkCenterCode = WorkCenterCode
			--		 FROM  STB_MaterialWarehouseInOutHist	   
			--		 WHERE 1=1		  
			--			AND LotID = @LotID           
			--		   --AND LotID = 'WEC3R0335QG 3.0 3.3 2003240912'   -- 미출고 테스트용  (주석처리)
			--		   --AND LotID = '1004214772004030028'                  -- 정상출고 테스트용 (주석처리)		   
			--		   --AND ProcessedLotID IS NOT NULL


			--		  IF @@ROWCOUNT > 0            

			--			BEGIN
			--				RAISERROR(' 해당 바코드는 이미 처리한 바코드입니다. 현재 재고가 없으니 확인바랍니다.' ,16, 1)               -- 2020.04.07 메세지 수정
			--				RETURN
			--			END


          --END
   

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

	-- ProcessedLotID 업데이트 (이 부분이 정상출고로 업데이트 되는 부분)
	UPDATE STB_MaterialWarehouseInOutHist
	     SET ProcessedLotID = @ProcessedLotID
	 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo



	 --- 추가구분 (2020.04.03)

	 --Declare @ProcessedResult VARCHAR(20)

	 -- MWIOH.MaterialWarehouseInOutHistNo
		--  ,MWIOH.WarehouseInOutCode
		--  ,BC.Description AS WarehouseInOutName
		--  ,MWIOH.SourceMaterialWarehouseCode
		--  ,MW1.MaterialWarehouseName AS SourceMaterialWarehouseName
		--  ,MWIOH.TargetMaterialWarehouseCode
		--  ,MW2.MaterialWarehouseName AS TargetMaterialWarehouseName


		  SELECT MWIOH.LotID   AS LotID
				  --,MM.MaterialCode
				  --,MM.MaterialName
				  --,MWIOH.WorkerCode
				  --,PWI.WorkerName
				  --,MWIOH.LineCode
				  --,LI.LineName
				  --,MWIOH.ProcessedLotID
				  --, CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult		  
				 , '정상출고' AS ProcessedResult		
	  FROM STB_MaterialWarehouseInOutHist MWIOH
			  LEFT OUTER JOIN STB_MaterialWarehouse MW1		        ON MWIOH.SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
			  LEFT OUTER JOIN STB_MaterialWarehouse MW2		        ON MWIOH.TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		                ON MWIOH.WorkerCode = PWI.WorkerCode
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON BC.ItemCode = MWIOH.WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'
			  LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI	                ON MDLI.LotID = MWIOH.LotID
			  LEFT OUTER JOIN STB_MaterialMaster MM	                    ON MM.MaterialCode = MDLI.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo LI	                                ON LI.LineCode = MWIOH.LineCode

	 WHERE 1=1	   
	   AND (@CompanyCode = '*'    OR MWIOH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
	   AND MWIOH.LotID NOT IN ( 
	                                       SELECT LotID 
										    FROM STB_MaterialDocLotInfo 
										  WHERE MaterialLocationCode LIKE 'ROUTE_%'
										  )                                                                               --- 창고체크

	    AND (MWIOH.LotID = @LotID)



	
					--SELECT  SML.LotID																						   AS LotID							
					--		 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END   AS ProcessedResult					
					--		--, '정상 출고 되었습니다.' AS ProcessedResult
					--FROM                        STB_MaterialLotInfo                  SML
					--		 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
					--WHERE 1=1
					----AND MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'
				 --    -- AND (SML.LotID = '202600120#2200039818#H219112362#32#DLC3702' OR SML.LotNo = '202600120#2200039818#H219112362#32#DLC3702')  			
					--  AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
			



	--IF @@ROWCOUNT = 1
	--	BEGIN
	--		RAISERROR('처리되었습니다.' ,16, 1)
	--	END	  



	 --SELECT LotID	        
	 --       , CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
	 --FROM  STB_MaterialWarehouseInOutHist	   
	 --WHERE 1=1
	 --  AND (LotID = 'VEC2R7705QD2.7 71806081503P36841736A' OR LotID = 'VEC2R7705QD2.7 71806081503P36841736A')
	 --  --AND (LotID = @LotID OR LotID = @LotID)   




END