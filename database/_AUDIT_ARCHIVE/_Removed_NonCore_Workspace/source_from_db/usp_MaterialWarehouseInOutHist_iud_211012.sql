-- ED-VJPMTR000000015
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
--             2020.06.12 유효기간 체크부분 오류해결 (변수명 잘못입력 및 SML.Lotattr10로 변경) 
--             2020.07.21 활성탄 처리 SQL문 수정 (이전에 불출된 동일 Lot번호도 있는 문제)
--			   2021.09.16 원자재출고 처리시 VALIDATE LOGIC 추가
--             2024.09.26 작업장별 특정 라인을 지정하여 BOM 체크 없이 원자재를 불출할 수 있도록 처리 (개발 원자재 불출 관련 프로세스) #240926 구보겸 프로 요청
-- ===================================================================================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_iud_211012]
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20),
								@pCompanyCode VARCHAR(20) = NULL,
								@pWorkCenterCode VARCHAR(20) = NULL,
								@pWorkerCode VARCHAR(20) = NULL,
								@pLineCode VARCHAR(20) = NULL,
								@pWarehouseInOutCode VARCHAR(1) = NULL,
								@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
								@pTargetMaterialWarehouseCode VARCHAR(20) = NULL,
								@pLotID VARCHAR(500) = NULL,
								@pCurrentQty NUMERIC(20, 5) = NULL,
								@pMaterialCode VARCHAR(30) = NULL,
								@pMaterialName VARCHAR(50) = NULL
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
			 ,@CurrentQty							NUMERIC(20, 5) = @pCurrentQty										--2021. 9. 2   Material Return (화면에서 입력값)
			 ,@Qty									NUMERIC(20, 5) = Null												--2021.09.28 추가 원자재출고시 재고 수량
			 ,@ModelCode								VARCHAR(20) = RTRIM(LTRIM(@pMaterialCode))												--2021. 9. 15 ProductOfLine Popup
--			 ,@MaterialName								VARCHAR(50) = @pMaterialName

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

	--2021. 09. 28 현재고 수량
	SELECT TOP 1 @Qty = CurrentQty
	FROM STB_MaterialLotInfo
	WHERE 
		LotID = @LotID
		AND
		MaterialWarehouseCode = @SourceMaterialWarehouseCode
		AND
		CurrentQty >= @CurrentQty
	ORDER BY
		MaterialLotNo

	-- 분리막은 전체 내용에서 LotID를 분리한다. 50,8  -> 2020.04.16 구보겸에 의해 제외
	-- 분리막 구분은 @LotID의 길이가 100자를 넘어가는 것으로 한다. 별도의 기준으로 변경 필요 

	-- 원본 백업
		--IF(LEN(@LotID) > 100)
		-- BEGIN
		--	SET @LotID = SUBSTRING(@LotID, 50, 8)
		-- END


		--동일한 창고로 출고 / 반납 시 등록 불가 20220712 SJC
		IF @SourceMaterialWarehouseCode = @TargetMaterialWarehouseCode
			BEGIN
				RAISERROR('출고창고와 입고창고가 동일합니다. 창고 확인 바랍니다.',16,1)
				RETURN
			END


	  -- 2020.04.09 중복된 바코드 처리요청 (구보겸) + 2020.04.13 타겟창고에 따라 조건문추가 
	  -- IF @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH', 'W02', 'W14', 'W22', 'W23', 'W24', 'W25')       -- 원자재창고 이거나 샘플창고이면,
	  IF @SourceMaterialWarehouseCode IN (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')
		
		BEGIN 

				SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
								  , @ProcessedLotID = SM.LotID	
								  , @MaterialCode = SM.MaterialCode									
				  FROM (
							SELECT  SML.MaterialLotNo                                                                        
									 , SML.LotID																						     AS LotID
									 , SML.MaterialCode                                                                               AS MaterialCode
									 , SML.PackingID                                                                                    AS PackingID
									 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult	
									 , SML.MaterialLocationCode                                                                     AS MaterialLocationCode				
							FROM                        STB_MaterialLotInfo                  SML
									 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotID = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
							WHERE 1=1
							AND SML.MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'												
							AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
													 
						   --AND SML.MaterialLocationCode LIKE  'ROH_WH' + '%'												                                  -- TEST용 주석처리
						  --AND (SML.LotID = 'WEC2R7106QG 2.7 10 2004161104' OR SML.LotNo = 'WEC2R7106QG 2.7 10 2004161104')  	  -- TEST용 주석처리
						    
						  ) SM
					WHERE 1=1
					 -- AND SM.ProcessedResult  = '미출고'         
				  ORDER BY SM.MaterialLotNo                          -- 2020.09.17 추가

				
		   --2021.09.16 LotID Status Check Start

		   --SELECT TOP 1 @MaterialCode = MaterialCode
		   --  FROM STB_MaterialDocLotInfo
		   -- WHERE LotID = @LotID

				SELECT TOP 1 @CompanyCode = MLI.CompanyCode
				  FROM STB_MaterialLotInfo MLI
  				  LEFT OUTER JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
				 WHERE MLI.CompanyCode = @CompanyCode									--'VNT'	
				   AND MLI.WorkCenterCode = @WorkCenterCode								--'VNT_F1'
				   AND MLI.MaterialWarehouseCode = @SourceMaterialWarehouseCode			--'ROUTE_WH'
				   AND MLI.LotID = @LotID												--'PU1879-K0036'
				   AND MLI.CurrentQty > 0
				
				IF @@ROWCOUNT = 0
					BEGIN
						--SELECT NULL AS MaterialCode
						RAISERROR('존재하지 않거나 자재창고에 없는 자재 LOT 입니다.',16,1)
						RETURN
					END
			
			/*
			SELECT TOP 1 @CompanyCode = CompanyCode
			  FROM (
				SELECT Top 1 CompanyCode, WarehouseInOutCode, LotID
				  FROM STB_MaterialWarehouseInOutHist
				 WHERE LotID = @LotID
				   AND TargetMaterialWarehouseCode = @TargetMaterialWarehouseCode
				 ORDER BY MaterialWarehouseInOutHistNo DESC) A
			  WHERE A.WarehouseInOutCode = 'O'
			    AND A.LotID NOT IN (SELECT LotID 
				                      FROM STB_MaterialWarehouseInOutHist 
									 WHERE WarehouseInOutCode = 'I' AND LotID = @LotID)
			*/
			 -- SELECT TOP 1 @CompanyCode = CompanyCode
			 -- FROM (
				--SELECT Top 1 CompanyCode, InOutCode
				--  FROM STB_RawMaterialLineInputHist
				-- WHERE LotID = @LotID
				-- ORDER BY MaterialWarehouseInOutHistNo DESC) A
			 -- WHERE A.InoutCode = 'O'

			 /*
				IF @@ROWCOUNT > 0
					BEGIN
						RAISERROR('이미 출고된 자재 LOT 입니다.',16,1)
						RETURN
					END
			*/

		   --2021.09.16 LotID Status Check End

		   --2021.09.16 BOM Check Start
				--SELECT TOP 1 @MaterialCode = MaterialCode
				--  FROM STB_MaterialLotInfo MLI
				--INNER JOIN (SELECT ChildMaterialCode	-- BOM Level 1
				--			   FROM STB_BomDetail
				--			  WHERE MaterialCode = @ModelCode	--'ECVT27-370'
				--			    AND BomVersion = CASE WHEN @CompanyCode = 'VNT' THEN '1'			--VNT = 1000 변경예정
				--									  WHEN @CompanyCode = 'VVT' Then '51' END	--VVT = 2000 변경예정)
				--			  UNION All
				--			  SELECT ChildMaterialCode	-- BOM Level 2
				--			    FROM VW_BomDetailWithHeaderBomUnit
				--			   WHERE MaterialCode IN (SELECT ChildMaterialCode 
				--			  						    FROM STB_BomDetail
				--			  						   WHERE MaterialCode = @ModelCode	--'ECVT27-370' 
				--			  						     AND BomVersion = CASE WHEN @CompanyCode = 'VNT' THEN '1'			--VNT = 1000 변경예정
				--			  												   WHEN @CompanyCode = 'VVT' Then '51' END)	--VVT = 2000 변경예정)
				--			  UNION ALL
				--			  SELECT DelegateMaterialCode	-- Delegate MaterialCode
				--			    FROM STB_MaterialMaster
				--			   WHERE MaterialCode in (SELECT ChildMaterialCode 
				--									    FROM STB_BomDetail
				--									   WHERE MaterialCode = @ModelCode
				--									     AND BomVersion = CASE WHEN @CompanyCode = 'VNT' THEN '1'		--VNT = 1000 변경예정
				--															   WHEN @CompanyCode = 'VVT' Then '51' END	--VVT = 2000 변경예정)
				--									  UNION All
				--									  SELECT ChildMaterialCode
				--									    FROM VW_BomDetailWithHeaderBomUnit
				--									   WHERE MaterialCode IN (SELECT ChildMaterialCode 
				--															    FROM STB_BomDetail
				--															   WHERE MaterialCode = @ModelCode
				--															     AND BomVersion = CASE WHEN @CompanyCode = 'VNT' THEN '1'			--VNT = 1000 변경예정
				--																					   WHEN @CompanyCode = 'VVT' Then '51' END)	--VVT = 2000 변경예정)
				--									     AND BomVersion = CASE WHEN @CompanyCode = 'VNT' THEN '1'			--VNT = 1000 변경예정
				--															   WHEN @CompanyCode = 'VVT' THEN '51' END)
				--				  AND DelegateMaterialCode IS NOT NULL
				--			) BOM ON MLI.MaterialCode = BOM.ChildMaterialCode
				-- WHERE MLI.LotID = @LotID	--'ML20210615000272'

				Declare @BomVersion VARCHAR(4)
				Declare @BomList TABLE (
						MaterialCode VARCHAR(20)
						);

				IF @CompanyCode = 'VNT'
					SELECT @BomVersion = MAX(Convert(INT, BomVersion))
						FROM STB_BomHeader
						WHERE MaterialCode = @ModelCode
						--AND BomVersion < 51
				ELSE 
					SELECT @BomVersion = MAX(Convert(INT, BomVersion))
						FROM STB_BomHeader
						WHERE MaterialCode = @ModelCode
						AND BomVersion > 50

				--모품목에 속하는 BOM 자재 리스트를 테이블 변수에 저장한다.
				INSERT INTO @BomList (MaterialCode)
					exec usp_GetNormalModelBomListOutput '', '', @ModelCode, @BomVersion, 1

				--대체품목이 존재하면 해당 내용을 추가해준다. 2022.09.05 By Jackaroe
				INSERT INTO @BomList (MaterialCode)
					SELECT DelegateMaterialCode 
						FROM STB_MaterialMaster 
						WHERE ISNULL(DelegateMaterialCode, '') <> ''
						AND MaterialCode IN (SELECT MaterialCode FROM @BomList)

					--제품 바코드로 Company 정보 조회
					--#240926
				--IF @MaterialCode <> 'GBTPPL-004' AND @LineCode NOT IN ('VIETNAMLINE-01', 'LINESETUP', 'MODULELINE-01', 'DRAFT-01')
				IF @MaterialCode <> 'GBTPPL-004' AND @LineCode NOT IN (SELECT LineCode FROM STB_LineInfo WHERE LineType = 'NoneBOM')
				BEGIN
					SELECT Top 1 @CompanyCode = CompanyCode
					  FROM STB_MaterialLotInfo
					 WHERE LotID = @LotID



					SELECT TOP 1 @MaterialCode = BOMCHECK.MaterialCode
					  FROM 
					   (
						SELECT MLI.MaterialCode
						  FROM STB_MaterialLotInfo MLI
						LEFT OUTER JOIN 
							--(
							--SELECT ChildMaterialCode 
							--  FROM STB_BomDetail
							-- WHERE MaterialCode = @ModelCode
							--   AND BomVersion = @BomVersion
							--UNION ALL 
							--SELECT ChildMaterialCode 
							--  FROM VW_BomDetailWithHeaderBomUnit
							-- WHERE MaterialCode IN (SELECT ChildMaterialCode 
							--						  FROM STB_BomDetail 
							--						 WHERE MaterialCode = @ModelCode
							--						   AND BomVersion = @BomVersion) 
							--   AND BomVersion = @BomVersion
							--UNION ALL 
							--SELECT ChildMaterialCode 
							--  FROM VW_BomDetailWithHeaderBomUnit
							-- WHERE MaterialCode IN (SELECT ChildMaterialCode 
							--						  FROM VW_BomDetailWithHeaderBomUnit
							--						 WHERE MaterialCode IN (SELECT ChildMaterialCode 
							--												  FROM STB_BomDetail 
							--												 WHERE MaterialCode = @ModelCode
							--												   AND BomVersion = @BomVersion) 
							--						   AND BomVersion = @BomVersion)

							--) BOM
							@BomList BOM
							--ON MLI.MaterialCode = BOM.ChildMaterialCode
							ON MLI.MaterialCode = BOM.MaterialCode
						 WHERE MLI.LotID = @LotID
						   --AND BOM.ChildMaterialCode Is NOT NULL
						   AND BOM.MaterialCode Is NOT NULL
						   --AND MLI.MaterialWarehouseCode = 'ROH_WH'  --원자재창고에 존재하는 자재만 불출 가능
						   AND MLI.MaterialWarehouseCode In (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')
						UNION ALL
						SELECT TOP 1 MM.MaterialCode 
						  FROM STB_MaterialMaster MM
						  LEFT OUTER JOIN STB_MaterialLotInfo MLI ON MM.MaterialCode = MLI.MaterialCode
						  LEFT OUTER JOIN (SELECT ChildMaterialCode 
											 FROM STB_BomDetail
											WHERE MaterialCode = @ModelCode
											  AND BomVersion = @BomVersion
											UNION ALL 
										   SELECT ChildMaterialCode 
											 FROM VW_BomDetailWithHeaderBomUnit
											WHERE MaterialCode IN (SELECT ChildMaterialCode 
																	 FROM STB_BomDetail 
																	WHERE MaterialCode = @ModelCode
																	  AND BomVersion = @BomVersion) 
											  AND BomVersion = @BomVersion) BD ON MM.DelegateMaterialCode = BD.ChildMaterialCode
						 WHERE MM.DelegateMaterialCode IS NOT NULL
						   --AND BD.BomVersion = @BomVersion
						   --AND BD.MaterialCode = @ModelCode
						   AND MLI.LotID = @LotID
						   --AND MLI.MaterialWarehouseCode = 'ROH_WH'  --원자재창고에 존재하는 자재만 불출 가능
						   AND MLI.MaterialWarehouseCode In (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')
						) BOMCHECK

					IF @@ROWCOUNT = 0
						BEGIN
							RAISERROR('생산중인 제품에 투입되는 자재가 아닙니다! 자재 정보를 확인 하십시오.',16,1)
							RETURN
						END
				END
   
		   --2021.09.16 BOM Check End

		 END 

		 ELSE      --@TargetLocation = 'ROH_WH'              -- 원자재 반납처리의 경우

		  BEGIN

		   --2021.09.16 LotID Status Check Start
					--SELECT TOP 1 @CompanyCode = MWIOH.CompanyCode 
					--  FROM STB_MaterialLotInfo MLI
					--  LEFT OUTER JOIN STB_MaterialWarehouseInOutHist MWIOH
					--    ON MWIOH.LotID = MLI.LotID
					-- WHERE MWIOH.CompanyCode = @CompanyCode
					--   AND MWIOH.WorkCenterCode = @WorkCenterCode
					--   AND MWIOH.LineCode = @LineCode
					--   AND MWIOH.WarehouseInOutCode = 'O'
					--   AND MWIOH.ProcessedLotID = @LotID
					--   AND MLI.LotID = @LotID
						
					--	IF @@ROWCOUNT = 0
					--		BEGIN
					--			RAISERROR('존재하지 않는 자재 입니다. 라인 정보나 자재 바코드 확인 바랍니다. ',16,1)
					--			RETURN
					--		END

		   --2021.09.16 LotID Status Check End

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
							   AND SML.CurrentQty > 0
							   AND SML.CurrentQty >= @CurrentQty
						  ) SM
					WHERE 1=1
						--AND SM.ProcessedResult  = '정상출고'
                     ORDER by SM.MaterialLotNo 
	--	  END       				 
---------------------------------------------------------	

   IF @MaterialLotNo IS NULL
   --IF @@ROWCOUNT = 0                  -- 매핑이 안된 LotNo인 경우
		    
			BEGIN
				 --RAISERROR(' 현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.' ,16, 1) 다국어 처리를 하지 않음.
				 --RETURN

				 EXEC usp_RaiseLocalizedError @pProcessLanguage, '현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.'
				RETURN
			END
		END
     
-- 2020.06.03 선입선출 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
     Declare @MakeDate  VARCHAR(20)
	 Declare @PackDate   VARCHAR(20)	 	
	 Declare @MakeDate2  VARCHAR(20)
	 Declare @PackDate2   VARCHAR(20)	 	   
	 Declare @Todate   VARCHAR(20)

	  --1. 해당제품의 가장 빠른 제조일/유효일 파악
			 SELECT	TOP 1 @MakeDate = MIN(SML.Lotattr10)                                                                                                                                                 
						, @PackDate  = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, SML.Lotattr10), 121)), 121)
			 FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  					LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK)  ON MDLI.MaterialCode = MM.MaterialCode			 
						LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK)  ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
				WHERE 1=1				
					--AND	MDLI.MaterialCode = 'GBHNAC-044'		
					AND	MDLI.MaterialCode = @MaterialCode	
					--AND SML.LotNo = '1004214772004270231'
					AND SML.CompanyCode = 'VNT'
					AND SML.MaterialWarehouseCode In (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')
				GROUP BY MM.MMExtInt01, SML.Lotattr10

      -- 2. 해당 Lot의 제조일/유효일 파악
				 SELECT	    @MakeDate2 = CASE WHEN  MDLI.Lotattr10 = '' THEN SML.Lotattr10 ELSE IsNull(MDLI.Lotattr10, SML.Lotattr10) END
							   , @PackDate2 = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
							   , @Todate = CONVERT(VARCHAR(10),	GetDate(), 121)
			       FROM                     STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  					LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode			 
						LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK) ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
				WHERE 1=1
				   --AND SML.LotNo = '1004214772004270231'
					--AND MDLI.LOTID = 'ML20200522000010'
					AND SML.CompanyCode = 'VNT'
					AND SML.MaterialWarehouseCode In (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')
					AND MDLI.LOTID = @LotID			
					AND MDLI.MDLISeqNo = (Select Max(MDLISeqNo) From STB_MaterialDocLotInfo Where LotID = @LotID )

	 ---- 3. 해당 Lot의 제조일이 가장빠르지 않으면 에러
	  --  IF @MakeDate < @MakeDate2         
		    
			--BEGIN
			--	 RAISERROR(' 출고처리가 실패하였습니다. (제조일자가 앞선 Lot가 존재합니다) ' ,16, 1)           
			--	 RETURN
			--END

  -- 2020.06.03 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------


   -- 2020.06.04 유효일자 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- 2. 해당 Lot의 유효일이 가장 빠르지 않으면 에러
		IF @LineCode NOT IN (SELECT LineCode FROM STB_LineInfo WHERE LineType = 'NoneBOM') BEGIN
			IF @Todate  >  @PackDate2  --22년 6월 2일 원복 예정_구보겸
		    
				BEGIN
					 RAISERROR(' 유효일자가 지난 자재입니다. 확인 바랍니다. ' ,16, 1)           
					 RETURN
				END
		END

   --2020.06.04 유효일자 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 일련번호 채번 
	Declare @MaterialWarehouseInOutHistNo VARCHAR(20)
	Declare @ProductGroupCode                  VARCHAR(20)	

		        --원본백업 (2020.07.20) : 활성탄의 경우 업체Lot가 같은 걸로 여러일 오는 경우가 발생.
				--SELECT    TOP 1  @MaterialDocDetailNo =  SMD.MaterialDocDetailNo	
			 --             ,               @ProductGroupCode   = SMM.ProductGroupCode                            
				--FROM                        STB_MaterialLotInfo         SML				
				--			LEFT OUTER JOIN STB_MaterialDocLotInfo SMD  ON SML.LotNo = SMD.LotNo                AND SML.LOTID = SMD.LOTID
				--			LEFT OUTER JOIN STB_MaterialMaster      SMM ON SMM.MaterialCode = SML.MaterialCode
				--WHERE 1=1	
				--AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  	

				-- 원본수정 (2020.07.20)
					SELECT    TOP 1  @MaterialDocDetailNo =  SMD.MaterialDocDetailNo	
							  ,             @ProductGroupCode  = SMM.ProductGroupCode                
						FROM                            STB_MaterialLotInfo         SML				
									LEFT OUTER JOIN STB_MaterialDocLotInfo SMD  ON SML.LotNo = SMD.LotNo                AND SML.LOTID = SMD.LOTID
									LEFT OUTER JOIN STB_MaterialMaster      SMM ON SMM.MaterialCode = SML.MaterialCode
										LEFT OUTER JOIN (
															     SELECT Max(ProductionDate)  AS ProductionDate, LotID FROM STB_MaterialLotInfo WHERE  1=1  AND LotID =  @LotID OR LotNo = @LotID Group By LotID
															     ) SML2 ON SML2.ProductionDate = SML.ProductionDate AND SML2.LotID = SML.LotID
						WHERE 1=1	
						  AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  					


   --2020.04.27 추가사항 (활성탄 두제품의 경우에는 바코드를 찍으면 일괄처리되도록 - 구보겸요청) ---------------------------------------------------------------------------------------------	  
   -- @MaterialCode = 'GATCCC-001' Or @MaterialCode = 'GATCCC-002' /// 
	/*
		IF (@ProductGroupCode  ='A.C') AND @CompanyCode = 'VNT' AND  @MaterialCode NOT IN ('GAPOCA-008', 'GAKCCA-002', 'GAKCCA-003', 'GAPOCA-006', 'GAHCCA-001')  BEGIN		-- Add @CompanyCode
			
			 DECLARE CarbonData CURSOR FOR      -- Cusor 이용
				
			-- SELECT SML.LotNo                                        -- 2020.05.20 (원본백업)
				SELECT SML.MaterialLotNo                             --                 원본수정
				  FROM STB_MaterialDocLotInfo SMD
				          LEFT OUTER JOIN STB_MaterialLotInfo SML ON  SML.LotNo = SMD.LotNo                AND SML.LOTID = SMD.LOTID
				 WHERE SMD.MaterialDocDetailNo = @MaterialDocDetailNo          			

			OPEN CarbonData

			WHILE 1 = 1 

			BEGIN
				FETCH NEXT FROM CarbonData INTO @MaterialLotNo
							
				 IF @@FETCH_STATUS <> 0 
				 BEGIN	BREAK	 
				 END			
			--------------------------------	
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

			-- INSERT문
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
																		) VALUES  (
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
			-- 21. 09. 28	원자재 일괄 투입이력(InOut) 저장 Start
			INSERT INTO STB_RawMaterialLineInputHist (MaterialWarehouseInOutHistNo
													 ,LotID
													 ,LineCode
													 ,InOutCode
													 ,Qty
													 ,ModelCode
													 ,CompanyCode
													 ,WorkCenterCode
													 ,WorkerCode
													 ,CreateDateTime
													 ,CreateUserID)
											VALUES (@MaterialWarehouseInOutHistNo
												   ,@LotID
												   ,@LineCode
												   ,@WarehouseInOutCode
												   ,CASE WHEN @CurrentQty IS NOT NULL AND @CurrentQty > 0 THEN @CurrentQty ELSE @Qty END --@Qty : 출고시 수량, @CurrentQty : 반납시 수량
												   ,CASE WHEN @WarehouseInOutCode = 'O' THEN @ModelCode ELSE '' END
												   ,@CompanyCode
												   ,@WorkCenterCode
												   ,@WorkerCode
												   ,GETDATE()
												   ,@pProcessUserID)
			
			-- 21. 09. 28	원자재 일괄 투입이력 저장 End													  	

			---- 창고이동
			--IF @MaterialLotNo IS NOT NULL 
	
			--BEGIN
			--	EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'            -- 다른 프로시저 호출 : 정상출고 처리되는 부분
			--END

			--print @TargetLocation

   --         print @MaterialLotNo
			
	 
			--IF @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH', 'W02', 'W14', 'W22', 'W23', 'W24', 'W25')       -- 원자재창고 이거나 샘플창고이면,
			IF @SourceMaterialWarehouseCode IN (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')

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
							   SET ProcessedLotID = NULL
								 --SET ProcessedLotID = ''
							 WHERE 1=1
							   --and MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
							   And (LotID = @LotID )  	
							   --And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가  (2020-09-02 주석처리함!!)
							   --And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                                   -- 주석이맞는듯?

								UPDATE STB_MaterialLotInfo																				--2021. 08. 31, 자재 반납시  CurrentQty  추가
										SET CurrentQty = @CurrentQty
								 WHERE LotID = @LotID

						 -- 화면에 표기되는 부분 (조회부분)
						 --IF @MaterialLotNo IS NOT NULL BEGIN
							SELECT @ProcessedLotID AS LotID
									 , '반납완료'          AS ProcessedResult          -- 조회되면 무조건 [반납완료]
					END

					-- 창고이동  위치 변경
			IF @MaterialLotNo IS NOT NULL BEGIN
				IF @Qty = @CurrentQty BEGIN
					EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'            -- 다른 프로시저 호출 : 정상출고 처리되는 부분
				END ELSE BEGIN
					exec usp_DoSplitRawMaterialAndMove @pProcessLanguage, @pProcessUserID, @MaterialLotNo, @CurrentQty, @TargetLocation
				END
			END

			print @TargetLocation

            print @MaterialLotNo

		END

              	CLOSE CarbonData;
				DEALLOCATE CarbonData;	
		
		*/
          
		--    END ELSE BEGIN    -- 예외제품에 대한 END 아래 IF문을 ELSE 문으로 대체 2025.01.13
     
	   --IF (@MaterialCode <> 'GATCCC-001' AND  @ProductGroupCode  <> 'A.C') OR @CompanyCode = 'VVT' OR  @MaterialCode IN ('GAPOCA-008', 'GAKCCA-002')	    BEGIN              -- 정상제품의 경우 (활성탄x)
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
																	   ,ProcessQty
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
																	   ,@CurrentQty
																	   ,@pProcessUserID
														)

			-- 21. 09. 28	원자재 일괄 투입이력(InOut) 저장 Start
			INSERT INTO STB_RawMaterialLineInputHist (MaterialWarehouseInOutHistNo
													 ,LotID
													 ,LineCode
													 ,InOutCode
													 ,Qty
													 ,ModelCode
													 ,CompanyCode
													 ,WorkCenterCode
													 ,WorkerCode
													 ,CreateDateTime
													 ,CreateUserID)
											VALUES (@MaterialWarehouseInOutHistNo
												   ,@LotID
												   ,@LineCode
												   ,@WarehouseInOutCode
												   ,CASE WHEN @CurrentQty IS NOT NULL AND @CurrentQty > 0 THEN @CurrentQty ELSE @Qty END --@Qty
												   ,CASE WHEN @WarehouseInOutCode = 'O' THEN @ModelCode ELSE '' END
												   ,@CompanyCode
												   ,@WorkCenterCode
												   ,@WorkerCode
												   ,GETDATE()
												   ,@pProcessUserID)
			
			-- 21. 09. 28	원자재 일괄 투입이력 저장 End	


			---- 창고이동
			--IF @MaterialLotNo IS NOT NULL 
	
			--BEGIN
			--	EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'                       -- 다른 프로시저 호출 : 정상출고 처리되는 부분
			--END


    --END  --추가부분 End

	-- ProcessedLotID 업데이트 이 부분이 정상출고로 업데이트 되는 부분인데, 수정  (2020.04.16)
	   --IF   @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH', 'W02', 'W14', 'W22', 'W23', 'W24', 'W25')       -- 원자재창고 이거나 샘플창고이면,
	   IF @SourceMaterialWarehouseCode IN (SELECT MaterialWareHouseCode FROM STB_MaterialWarehouse WHERE WHExtText01 = '1')

				BEGIN
						UPDATE STB_MaterialWarehouseInOutHist
							 SET ProcessedLotID = @ProcessedLotID
						 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo      
					 			 
			 			SELECT @ProcessedLotID AS LotID
								, '정상출고'           AS ProcessedResult          -- 조회되면 무조건 [정상출고]
				END

       ELSE        -- 반납의 경우 ProcessedLotID를 제외한다!! (재출고땜시..) 
					  BEGIN
								 UPDATE STB_MaterialWarehouseInOutHist
									 SET ProcessedLotID = ''
								 WHERE 1=1
								-- And MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
								   And (LotID = @LotID )  	
								   And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가
								-- And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                              -- 2020.04.23 추가했으나 2020.12.18에 재불출문제건으로 주석처리

								/*
								UPDATE STB_MaterialLotInfo																				--2021. 08. 31, 자재 반납시  CurrentQty 추가
										SET CurrentQty = @CurrentQty
								 WHERE MaterialLotNo = @MaterialLotNo
								*/

							 -- 화면에 표기되는 부분 (조회부분)
							 --IF @MaterialLotNo IS NOT NULL BEGIN
								SELECT @ProcessedLotID AS LotID
										 , '반납완료'          AS ProcessedResult          -- 조회되면 무조건 [반납완료]
							  END
			-- 창고이동
			IF @MaterialLotNo IS NOT NULL BEGIN
				IF @Qty = @CurrentQty BEGIN
					EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'            -- 다른 프로시저 호출 : 정상출고 처리되는 부분
				END ELSE BEGIN
					exec usp_DoSplitRawMaterialAndMove @pProcessLanguage, @pProcessUserID, @MaterialLotNo, @CurrentQty, @TargetLocation
				END
			END

    --END   -- 추가부분
END