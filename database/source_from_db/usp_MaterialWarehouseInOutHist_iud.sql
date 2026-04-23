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
--             Mr.Tung add on 2023-June-03   for  save PaperNoExport
-- [프로시저 확인방법] 마지막에 바코드No
-- Exec :   usp_MaterialWarehouseInOutHist_iud 'anhduy157','vi','VVT','VVT_F2','32006013','32006013','I','HOLDING_BG_WH','ROH_BG_WH','ML20251112000181'
--          usp_MaterialWarehouseInOutHist_iud 'kilee','Korean','VNT','VNT_F1','kilee','ASSYLINE-11','O','ROH_WH','ROUTE_WH','WEC2R7106QG 2.7 10 2004161104'     --2020.09.17 문제된 슬리브 바코드임!

-- =============================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_iud]
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
								@pDayPlanNo VARCHAR(30) = NULL,
								@pPlanDate datetime = null,
								@pProductCode VARCHAR(50) = NULL,
								@pPaperNoExport nVarchar(150)=null,
								@pDateExport  datetime=null,
								@pHoldingError  nVarchar(150)=null
AS

BEGIN
	Declare @CompanyCode                    VARCHAR(20) = @pCompanyCode
			 ,@WorkCenterCode                  VARCHAR(20) = @pWorkCenterCode
			 ,@WorkerCode                       VARCHAR(20) = @pWorkerCode
			 ,@LineCode                           VARCHAR(20) = @pLineCode
			 ,@WarehouseInOutCode            VARCHAR(1) = @pWarehouseInOutCode
			 ,@SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
			 ,@TargetMaterialWarehouseCode VARCHAR(20) = @pTargetMaterialWarehouseCode
			 ,@LotID                                 VARCHAR(500) = ltrim(RTRIM(@pLotID))                                      -- 2020.04.16 RTRIM 추가 
			 ,@DayPlanNo VARCHAR(30) = @pDayPlanNo
			  ,@HoldingError  nVarchar(150) = @pHoldingError, -- 2024.07.18
			@ActualExportQuantity numeric(20,5)

	Declare @MaterialLotNo         VARCHAR(20) 
	         , @ProcessedLotID        VARCHAR(20)
		     , @TargetLocation         VARCHAR(20)
			 , @MaterialCode           VARCHAR(30)          --2020.04.27 추가
			 , @MaterialDocDetailNo VARCHAR(30)          --2020.05.12 추가
			 
		--RAISERROR(@LineCode ,16, 1)           
		--RETURN	
		

	----------------------------------- add 09/10/2024
		declare @CountLotSmall int 
		declare @CountLotSmallHist int 

		select @CountLotSmall=count(*)  from stb_materialdoclotinfo where lotid = @LotID and IsSlpitLot=1

		--select @CountLotSmallHist=count(LotID)  from STB_MaterialWarehouseInOutHist where lotID =@LotID

		if(@CountLotSmall >0  )
				BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot này đã tách rồi. Không thể xuất nữa !'
					RETURN
				END
 
	---------------------------------- end  09/10/2024
	----------------------------------- add 25/12/2024 - kiem tra neu lot slitting chua co qc kiem tra se bao loi
		
		
		declare @checkQC varchar(20)
		select @checkQC = ischeck ,@ActualExportQuantity =  CurrentQty    from stb_materiallotinfo where lotid = @LotID
		if((@SourceMaterialWarehouseCode ='SLITTING_HN_WH'and @checkQC <>'pass') or (@SourceMaterialWarehouseCode= 'SLITTING_HN_WH' and @checkQC is null))
		begin
								 RAISERROR(N'^Lot này QC chưa kiểm tra hoặc lot này QC đã  Reject^ ' ,16, 1)           
									RETURN	
		end

	---------------------------------- end   25/12/2024 

	
	--Kiểm tra nếu xuất từ kho sản xuất về các kho thì không cho xuất bắt buộc phải nhập lại
	if(@WarehouseInOutCode='O' and @SourceMaterialWarehouseCode in ('ROUTE_BG_WH','ROUTE_VN_WH','ROUTE_HN_WH', 'ROUTE_BG2_WH'))
	begin
			EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot này đã xuất ra sản xuất ! Chỉ được dùng nguyên vật liệu đầu vào hoặc nhập lại từ sản xuất !'
			return
	end
	--




		--raiserror(@SourceMaterialWarehouseCode,16,1)
    --Duy kiểm tra hàng có đang được xuất đi bắc giang hay không nếu đang được xuất sẽ báo lỗi
		--exec usp_VVT_CheckHoldWarehouseExportBG @LotID
	
	--begin by Mr.Tung check LotID if exists at Source WAREHOUSE on 26-May-2022 & 11-July-2022
	declare @Err nvarchar(500)='';

	
	EXEC usp_VVTMaterialWarehouse_validFIFO @pProcessLanguage = @pProcessLanguage,
											@pProcessUserID = @pProcessUserID,
											@pKindCheck	='SEARCH',	
											@pErr  = @Err OUT,
											@pWarehouseInOutCode =@WarehouseInOutCode,
											@pSourceMaterialWarehouseCode =@SourceMaterialWarehouseCode,
											@pTargetMaterialWarehouseCode =@TargetMaterialWarehouseCode,
											@pLotID =@LotID,
											@pDayPlanNo1=@DayPlanNo,
											@pPlanDate1=@pPlanDate,
											@pProductCode1=@pProductCode


		 
	if(@Err is not null and @Err<>'') begin								
			--select '' as LotID,@Err as ProcessedResult
			--return;
			GOTO procedure_end
	end
	--end by Mr.Tung check LotID if exists at Source WAREHOUSE on 26-May-2022 & 11-July-2022
	



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
		IF @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH','ROH_BG_WH','ROH_HN_WH','HOLDING_VN_WH', 'MODULE_BG2_WH')                     -- 원자재 출고처리의 경우	
		BEGIN 			   		 
		
			 --Mr.Tung begin FIFO on  10-Feb-2022
			-- Mr.Tung begin FIFO on  10-Feb-2022
			
			if ( @pTargetMaterialWarehouseCode NOT IN ('ROH_BG_WH')  and @WorkCenterCode not in ('VVT_F2', 'VVT_F3','VVT_F1', 'VVT_F4') )
			begin 
			
			 EXEC usp_VVTMaterialWarehouse_validFIFO @pProcessLanguage = @pProcessLanguage,
												@pProcessUserID = @pProcessUserID,
												@pKindCheck	='FIFO',	
												@pErr  = @Err OUT,
												@pWarehouseInOutCode =@WarehouseInOutCode,
												@pSourceMaterialWarehouseCode =@SourceMaterialWarehouseCode,
												@pTargetMaterialWarehouseCode =@TargetMaterialWarehouseCode,
												@pLotID =@LotID	,
												@pDayPlanNo1=@DayPlanNo,
												@pPlanDate1=@pPlanDate,
												@pProductCode1=@pProductCode,
												@pWorkCenterCode = @WorkCenterCode
											--print 'a';
					
			end
			if(@Err is not null and @Err<>'') begin								
				select '' as LotID,@Err as ProcessedResult
				return;
			end
			
			-- Mr.Tung end FIFO on  10-Feb-2022
			-- Mr.Tung end FIFO on  10-Feb-2022
			

			 --RAISERROR(' Lỗi ' ,16, 1)   
			DECLARE 
			@SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),			
			@PackingID VARCHAR(50),
			@IsUseBarcode BIT,
			@IsFIFO BIT,
			@IsUseBarcoe BIT,
			@GRDate DATE
		
			SELECT
					
					@SourceCompanyCode = MLI.CompanyCode,
					@SourceWorkCenterCode = MLI.WorkCenterCode,
					@SourceMaterialWarehouseCode = MLI.MaterialWarehouseCode,
					@IsUseBarcode = ISNULL(MSAI.IsUseBarcode,0),
					@IsFIFO = ISNULL(MSAI.IsFIFO,0),
					@PackingID = MLI.PackingID,
					@MaterialLotNo = MLI.MaterialLotNo,
					@MaterialCode = MLI.MaterialCode,
					@ActualExportQuantity =   MLI.CurrentQty     
			FROM
					STB_MaterialLotInfo MLI
					LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI 
						ON	MSAI.MaterialCode = MLI.MaterialCode
				--LEFT OUTER JOIN STB_VN_DIVIDEMATERIALSMAL DMS on MLI.LotID=DMS.LotID

			WHERE
					 MLI.LotID = @LotID 
					 --or
					--DMS.PACKINGIDSMALL= @LotID;
			--if(@LotID in (select PACKINGIDSMALL from STB_VN_DIVIDEMATERIALSMAL))
			--	begin
			--			select @SourceMaterialWarehouseCode =  MaterialWarehouseCode from  STB_VN_DIVIDEMATERIALSMAL where  PACKINGIDSMALL= @LotID;
			--	end		


			SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
								  , @ProcessedLotID = SM.LotID	
								  , @MaterialCode = SM.MaterialCode									
				  FROM (
							SELECT  SML.MaterialLotNo,                                                                       
									  SML.LotID 	AS LotID
									 --DMS.PACKINGIDSMALL			AS LotID
									 --ISNULL(SML.LotID, DMS.PACKINGIDSMALL)					AS LotID
									 , SML.MaterialCode                                                                               AS MaterialCode
									 , SML.PackingID                                                                                    AS PackingID
									 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult	
									 , SML.MaterialLocationCode                                                                     AS MaterialLocationCode				
							FROM                        STB_MaterialLotInfo                  SML
									 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
									 --LEFT OUTER JOIN STB_VN_DIVIDEMATERIALSMAL DMS on SML.LotID=DMS.LotID
							WHERE 1=1
							AND SML.MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'												
							AND (SML.LotID = @LotID OR SML.LotNo = @LotID )  			
													 
						   --AND SML.MaterialLocationCode LIKE  'ROH_WH' + '%'												                                  -- TEST용 주석처리
						  --AND (SML.LotID = 'WEC2R7106QG 2.7 10 2004161104' OR SML.LotNo = 'WEC2R7106QG 2.7 10 2004161104')  	  -- TEST용 주석처리
						    
						  ) SM
					WHERE 1=1
						AND SM.ProcessedResult  = '미출고'         
				  ORDER BY SM.MaterialLotNo                          -- 2020.09.17 추가


				  	   
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

					-- RAISERROR(@SourceMaterialWarehouseCode,16, 1) 
					-- return

		  END       				 
---------------------------------------------------------	

   IF @MaterialLotNo IS NULL --or @LotID not in ('ML20251112000181')
   --IF @@ROWCOUNT = 0                  -- 매핑이 안된 LotNo인 경우
		    
			BEGIN
				 --RAISERROR(' 현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.' ,16, 1) 다국어 처리를 하지 않음.
				 --RETURN
				 --RAISERROR('/chekc' ,16, 1)
				 EXEC usp_RaiseLocalizedError @pProcessLanguage, '현재 재고가 없는 바코드입니다. 바코드를 확인바랍니다.'
				RETURN
			END
     
-- 2020.06.03 선입선출 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
     Declare @MakeDate  VARCHAR(20)
	 Declare @PackDate   VARCHAR(20)	 	
	 Declare @MakeDate2  VARCHAR(20)
	 Declare @PackDate2   VARCHAR(20)	 	   
	 Declare @Todate   VARCHAR(20)	 	   

	  --1. 해당제품의 가장 빠른 유효일 파악
			 SELECT	TOP 1 @MakeDate = MDLI.Lotattr10                                                                                                                                                      
							   , @PackDate  = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, SML.Lotattr10), 121)), 121)
			 FROM                           STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  					LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK)  ON MDLI.MaterialCode = MM.MaterialCode			 
						LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK)  ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
				WHERE 1=1				
					--AND	MDLI.MaterialCode = 'GBHNAC-044'		
					AND	MDLI.MaterialCode = @MaterialCode	

					--AND SML.LotNo = '1004214772004270231'				
				ORDER BY MDLI.MDLISeqNo

      -- 2. 해당 Lot의 유효일 파악
				 SELECT	    @MakeDate2 = CASE WHEN  MDLI.Lotattr10 = '' THEN SML.Lotattr10 ELSE IsNull(MDLI.Lotattr10, SML.Lotattr10) END
							   , @PackDate2 = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)
							   , @Todate = CONVERT(VARCHAR(10),	GetDate(), 121)  
			       FROM                     STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
	  					LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK) ON MDLI.MaterialCode = MM.MaterialCode			 
						LEFT OUTER JOIN STB_MaterialLotInfo        SML WITH(NOLOCK) ON SML.LotNo = MDLI.LotNo                    AND SML.LOTID = MDLI.LOTID
				WHERE 1=1
				   --AND SML.LotNo = '1004214772004270231'
					--AND MDLI.LOTID = 'ML20200522000010'
					AND MDLI.LOTID = @LotID			
		
	 -- 3. 해당 Lot의 유효일이 가장빠르지 않으면 에러 (구보겸에 의해서 우선 주석처리)
	 --   IF @PackDate > @PackDate2         
		    
		--	BEGIN
		--		 RAISERROR(' 출고처리가 실패하였습니다. (제조일자가 앞선 Lot가 존재합니다) ' ,16, 1)           
		--		 RETURN
		--	END

  -- 2020.06.03 선입선출 체크사항 End --------------------------------------------------------------------------------------------------------------------------------------------------------------------


   -- 2020.06.04 유효일자 체크사항 Start  --------------------------------------------------------------------------------------------------------------------------------------------------------------------
   -- 2. 해당 Lot의 유효일이 가장 빠르지 않으면 에러
	 
	 	declare @OpenExpired bit = 0  --Mr.Tung add for exclude Expired Date 2023-sep-23
	 	;with data1 as (
			select LotID,max(createdatetime) as createdatetime
			from stb_vvt_OpenExpiredMaterial  with(nolock) 
			where (LotID=@LotID  )
			group by lotid
		)
		select top 1 @OpenExpired = voem.OpenExpired 
		from stb_vvt_OpenExpiredMaterial voem with(nolock) 
		join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime
		
		if(@PackDate2 is null) -- đây là ktra cho các mã SP chia tem vào bảng STB_MaterialLotInfo
			--set @PackDate2='1900-01-01'
			 SELECT	    @MakeDate2 = IsNull(MLI.Lotattr10, '1900-01-01') 
							   , @PackDate2 = IsNull(CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121), '1900-01-01')
							   , @Todate = CONVERT(VARCHAR(10),	GetDate(), 121)  
			       FROM     STB_MaterialLotInfo MLI WITH(NOLOCK)
	  					LEFT OUTER JOIN STB_MaterialMaster        MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode			 

				WHERE 1=1
				   --AND SML.LotNo = '1004214772004270231'
					--AND MDLI.LOTID = 'ML20200522000010'
					AND MLI.LOTID = @LotID		
	    IF @Todate  >  @PackDate2
		begin
	    
		    if( isnull(@OpenExpired,0)<1 and @TargetMaterialWarehouseCode not like 'HOLDING%WH' and @TargetMaterialWarehouseCode not like 'NG_RAW%WH') 	 --Mr.Tung add for exclude Expired Date 2023-sep-23
			BEGIN

				 exec usp_VVTMaterialWarehouse_HOLDexpired 
															@pProcessUserID					=@pProcessUserID
															,@pCompanyCode					=@CompanyCode					
															,@pWorkCenterCode				=@WorkCenterCode				
															,@pSourceMaterialWarehouseCode  =@SourceMaterialWarehouseCode  
															,@pWarehouseInOutCode			=@WarehouseInOutCode			
															,@pLotID						=@LotID						
															,@pWorkerCode					=@WorkerCode					
															,@pLineCode						=@LineCode						

				 RAISERROR(' ^유효일자가 지난 자재입니다. 확인 바랍니다.^ ' ,16, 1)           
				 RETURN
			END
			end
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

		IF (@MaterialCode = 'GATCCC-001' Or  @ProductGroupCode  ='A.C') AND @CompanyCode = 'VNT'   BEGIN		-- Add @CompanyCode
			
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
																			,Status_Confirm_Export --Mr.Duy update confirm export
																				   ,ActualExportQuantity
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
																					   ,1
																					     ,@ActualExportQuantity
																		            )

			-- 창고이동
			IF @MaterialLotNo IS NOT NULL 
	
			BEGIN
				
				IF(@TargetMaterialWarehouseCode <> 'ROH_BG_WH' AND @TargetMaterialWarehouseCode <> 'ROH_VN_WH'AND @TargetMaterialWarehouseCode <> 'ROH_HN_WH' AND @TargetMaterialWarehouseCode <> 'MODULE_BG2_WH')--Duy check thuộc kho BG thì sẽ chưa cho update ngay
					BEGIN
						
						EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N'           -- 다른 프로시저 호출 : 정상출고 처리되는 부분
					END
				ELSE
					BEGIN
						DECLARE @date_confirm varchar(20) = substring(convert(varchar(20),getdate(),120),1,10);
						EXEC usp_PDADoPutaway_AddDateConfirmEX_new @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo,@pLotID,@date_confirm, 'N' 
					END

			
			END



			--print @TargetLocation

           -- print @MaterialLotNo
			
	 
	     IF   @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH', 'ROH_BG_WH', 'ROH_HN_WH', 'MODULE_BG2_WH')       -- 원자재창고이면

				BEGIN
						--raiserror (@SourceMaterialWarehouseCode,16,1)
						UPDATE STB_MaterialWarehouseInOutHist
							 SET ProcessedLotID = @ProcessedLotID
						 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					 			 
			 			SELECT @ProcessedLotID AS LotID
						, case when lower(@pProcessUserID) like 'vi%' then 'Đã xuất kho' else '정상출고' end  AS ProcessedResult          -- 조회되면 무조건 [정상출고]

					END

       ELSE        -- 반납의 경우 ProcessedLotID를 제외한다!! (재출고땜시..) 

				  BEGIN
							 UPDATE STB_MaterialWarehouseInOutHist
							   SET ProcessedLotID = NULL
								 --SET ProcessedLotID = ''
							 WHERE 1=1
							   --and MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
							   And (LotID = @LotID )  	
							  -- and createdatetime =(SELECT MAX(createdatetime) FROM STB_MaterialWarehouseInOutHist where LotID=@LotID)
							   --And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가  (2020-09-02 주석처리함!!)
							   --And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                                   -- 주석이맞는듯?

						 -- 화면에 표기되는 부분 (조회부분)
						 --IF @MaterialLotNo IS NOT NULL BEGIN
							SELECT @ProcessedLotID AS LotID
							, case when lower(@pProcessUserID) like 'vi%' then 'Hoàn trả xong' else '반납완료' end  AS ProcessedResult          -- 조회되면 무조건 [반납완료]
					END

			END

              	CLOSE CarbonData;
				DEALLOCATE CarbonData;	
				
          
		    END    -- 예외제품에 대한 END

     
	   IF (@MaterialCode <> 'GATCCC-001' AND  @ProductGroupCode  <> 'A.C') OR @CompanyCode = 'VVT'	    BEGIN              -- 정상제품의 경우 (활성탄x)
	   ------------- 여기까지

			--	declare @f varchar(20)=@ActualExportQuantity
				--RAISERROR(@f ,16, 1)           
				-- RETURN


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
																	   ,Status_Confirm_Export --Mr.Duy update confirm export
																	   ,errorcontent
																	   ,ActualExportQuantity
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
																	   ,1
																	   ,@HoldingError 
																	   ,@ActualExportQuantity
														)
			
			-- 창고이동
			IF @MaterialLotNo IS NOT NULL 
	
			BEGIN
				IF(@TargetMaterialWarehouseCode <> 'ROH_BG_WH' AND @TargetMaterialWarehouseCode <> 'ROH_VN_WH' AND @TargetMaterialWarehouseCode <> 'ROH_HN_WH' AND @TargetMaterialWarehouseCode <> 'MODULE_BG2_WH') --Duy check thuộc kho BG thì sẽ update cả nahf máy mới hiển thị
					BEGIN
						EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo, 'N',@HoldingError                        -- 다른 프로시저 호출 : 정상출고 처리되는 부분
					END
				ELSE
					BEGIN
							DECLARE @date_confirm1 varchar(20) = substring(convert(varchar(20),getdate(),120),1,10);
							EXEC usp_PDADoPutaway_AddDateConfirmEX_new @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo,@pLotID,@date_confirm, 'N' 
					END
			END
			-- NẾU MÀ XUẤT TỪ KHO SANG SLITTING THÌ LOT ĐÓ SẼ CHUYỂN THÀNH LOT CHA VÀ CẬP NHẬT LẠI LÀ CHƯA CẮT
			IF(@SourceMaterialWarehouseCode ='ROH_HN_WH' AND @TargetMaterialWarehouseCode = 'SLITTING_HN_WH')
			BEGIN
			--raiserror(@LotID,16,1)
			--return
				UPDATE STB_MaterialLotInfo 
				SET IsParrent='1' , IsSlitting=NULL
				WHERE LOTID=@LotID
			END

    --END  --추가부분 End

	-- ProcessedLotID 업데이트 이 부분이 정상출고로 업데이트 되는 부분인데, 수정  (2020.04.16)
	   IF   @SourceMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH','ROH_BG_WH','ROH_HN_WH', 'MODULE_BG2_WH')       

				BEGIN
			  	-- RAISERROR(@pProcessUserID ,16, 1) 
						UPDATE STB_MaterialWarehouseInOutHist
							 SET ProcessedLotID = @ProcessedLotID
						 WHERE MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
					 			 

						
			 			SELECT @ProcessedLotID AS LotID
						, case when lower(@pProcessUserID) like 'vi%' then 'Đã xuất kho' else '정상출고' end  AS ProcessedResult    -- 조회되면 무조건 [정상출고]
						
				END

       ELSE        -- 반납의 경우 ProcessedLotID를 제외한다!! (재출고땜시..) 
					  BEGIN
				
								 UPDATE STB_MaterialWarehouseInOutHist
									 SET ProcessedLotID = ''
								 WHERE 1=1
								-- And MaterialWarehouseInOutHistNo = @MaterialWarehouseInOutHistNo
								   And (LotID = @LotID )  	
								   And WarehouseInOutCode = 'O'                                                                         -- 2020.04.23 추가
								   And  WorkCenterCode =@pWorkCenterCode -- Mr.Duy update cùng nhà máy để khi bắn đi bắn lại giữa bắc giang và bắc ninh k bị update của nhau
								  -- and createdatetime =(SELECT MAX(createdatetime) FROM STB_MaterialWarehouseInOutHist where LotID=@LotID) -- lấy ra bản ghi gần nahát để update
								-- And CreateDateTime > Dateadd(MINUTE, -10, getdate())			                              -- 2020.04.23 추가했으나 2020.12.18에 재불출문제건으로 주석처리

							 -- 화면에 표기되는 부분 (조회부분)
							 --IF @MaterialLotNo IS NOT NULL BEGIN

							 --raiserror(@SourceMaterialWarehouseCode,16,1)
								SELECT @ProcessedLotID AS LotID
								, case when lower(@pProcessUserID) like 'vi%' then 'Hoàn trả xong' else '반납완료' end  AS ProcessedResult   -- 조회되면 무조건 [반납완료]
							  END

              END   -- 추가부분

			  
			  -- Mr.Tung add on 2023-June-27   for  save PaperNoExport			  
			  if(@pPaperNoExport is not null and @pPaperNoExport<>'') begin

				begin try
				
					update STB_MaterialDocDetail
					set MRMDExtText02 = @pPaperNoExport , MRMDExtText05 = convert(varchar(19),@pDateExport,120)
					where MaterialDocDetailNo=@MaterialDocDetailNo
				end try
				begin catch
					set @pPaperNoExport=@pPaperNoExport
				end catch

			  end

			  			  
		-- Mr.Tung add on 2022-July-12   for monitor Qty Issued base on DayPlanNo

			
			declare @count INT=0
			select @count = count(*) from STB_MaterialLotInfo where LotID=ltrim(rtrim(@pLotID)) and MaterialWarehouseCode=@TargetMaterialWarehouseCode
			declare @county INT=0
			select @county = count(*) from STB_MaterialDocDetail where MaterialDocDetailNo=@MaterialDocDetailNo
				
				--RAISERROR(@ProcessedLotID ,16, 1)

			if(@county=0 or @count>0 and @pDayPlanNo is not null and ltrim(rtrim(@pDayPlanNo))<>'' and @pLotID is not null and ltrim(rtrim(@pLotID))<>'') begin						
					
						declare @Qty float=0
						declare @materiacode varchar(200)= ''

						select @Qty = convert(float,CurrentQty),@materiacode=MaterialCode 
						from STB_MaterialLotInfo     
						where LotID=@pLotID          --and MaterialWarehouseCode not like '%ROH%';

						if(@materiacode is not null and @Qty>0) begin

							if(@SourceMaterialWarehouseCode='ROH_VN_WH')
								insert into STB_Vietnam_MaterialOrderHist (linecode,DayPlanNo,MaterialCode,LotID,Qty,CreateDateTime,CreateUserId,orderdate,ProductCode,Comment)
									values (@linecode,@pDayPlanNo,@materiacode,@pLotID,@Qty,getdate(),@pProcessUserID,dateadd(hour,2,isnull(@pPlanDate,@pDateExport)),@pProductCode,@pPaperNoExport);

							if(@TargetMaterialWarehouseCode='ROH_VN_WH')
								insert into STB_Vietnam_MaterialOrderHist (linecode,DayPlanNo,MaterialCode,LotID,Qty,CreateDateTime,CreateUserId,orderdate,ProductCode,Comment)
									values (@linecode,@pDayPlanNo,@materiacode,@pLotID,(-1*@Qty),getdate(),@pProcessUserID,dateadd(hour,2,isnull(@pPlanDate,@pDateExport)),@pProductCode,@pPaperNoExport);
							
						end
			end

			procedure_end:
				select '' as LotID,@Err as ProcessedResult
END