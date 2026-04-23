CREATE PROCEDURE [dbo].[usp_VVTMaterialWarehouse_validFIFO]
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20),	
								@pKindCheck		varchar(20),
								@pErr nvarchar(500) OUT,
								@pWarehouseInOutCode VARCHAR(1) = NULL,
								@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
								@pTargetMaterialWarehouseCode VARCHAR(20) = NULL,
								@pLotID VARCHAR(500) = NULL,
								@pDayPlanNo1 VARCHAR(30) = NULL,								
								@pPlanDate1 datetime = null,
								@pProductCode1 VARCHAR(50) = NULL,
								@pWorkCenterCode VARCHAR(50) = NULL

AS

BEGIN


	Declare 		
			 @WarehouseInOutCode            VARCHAR(1) = @pWarehouseInOutCode
			 ,@SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
			 ,@TargetMaterialWarehouseCode VARCHAR(20) = @pTargetMaterialWarehouseCode
			 ,@LotID                                 VARCHAR(500) = ltrim(RTRIM(@pLotID))                                      -- 2020.04.16 RTRIM 추가 
			 ,@DayPlanNo VARCHAR(30)     = @pDayPlanNo1
			 ,@PlanDate VARCHAR(30)     = @pPlanDate1
			 ,@ProductCode VARCHAR(30)     = @pProductCode1

	Declare @MaterialLotNo         VARCHAR(20) 
	         , @ProcessedLotID        VARCHAR(20)
		     , @TargetLocation         VARCHAR(20)
			 , @MaterialCode           VARCHAR(30)          
			 , @MaterialDocDetailNo VARCHAR(30)       			


		  set @pErr = '';
		   --raiserror(@SourceMaterialWarehouseCode,16,1)
		   --RETURN
	
		if(@pKindCheck='SEARCH') begin	

		-- What is this? Make a comment 2024.05.10
		-- SELECT * FROM STB_MaterialLotInfo

			--begin by Mr.Tung check LotID if exists at Source WAREHOUSE on 26-May-2022 & 11-July-2022
			Declare @cnt int
			declare @errrr nvarchar(500)='';
			select @cnt = count(*) from STB_MaterialLotInfo with(nolock) 
			where LotID = @LotID OR  STB_MaterialLotInfo.LotID = (SELECT LOTID FROM STB_VN_DIVIDEMATERIALSMAL WITH(NOLOCK) WHERE PACKINGIDSMALL = @LotID)
			if(@cnt=0)begin
				select @cnt = count(*) from STB_MaterialDocLotInfo with(nolock) 
				
					where STB_MaterialDocLotInfo.LotID = @LotID OR STB_MaterialDocLotInfo.LotID = (SELECT LOTID FROM STB_VN_DIVIDEMATERIALSMAL WITH(NOLOCK) WHERE PACKINGIDSMALL = @LotID) -- Kiểm tra mã lot tách nhỏ

				if(@cnt>0) 
					set @errrr  = N'LotID is not Fixed/Confirmed in F330 Screen.   Lot chưa được xác nhận nhập kho ở màn hình F330 !';
				else
					set @errrr  = N'LotID is wrong.   Sai mã Lót!';

				set @pErr = @errrr

				if( isnull(@LotID,'')<>'' ) 
					raiserror (@errrr,16,1);
					
				return;
			end  --- STB_MaterialDocLotInfo

			--Declare @df         VARCHAR(20) =@cnt
			--raiserror(@SourceMaterialWarehouseCode,16,1)
		   --RETURN
			select @cnt = count(*) from STB_MaterialLotInfo with(nolock) 
			where LotID = @LotID and MaterialWarehouseCode = @SourceMaterialWarehouseCode --OR STB_MaterialLotInfo.LotID = (SELECT LOTID FROM STB_VN_DIVIDEMATERIALSMAL WITH(NOLOCK) WHERE PACKINGIDSMALL = @LotID)
			if(@cnt=0)begin
							 raiserror(@SourceMaterialWarehouseCode,16,1)
				set @errrr  = N'LotID is not exists in the Source Warehouse.   Lót không tồn tại trong kho Nguồn bạn chọn!';
				set @pErr = @errrr
				if( isnull(@LotID,'')<>'' )
					raiserror (@errrr,16,1);
		
				return;
			end
			--end by Mr.Tung check LotID if exists at Source WAREHOUSE on 26-May-2022 & 11-July-2022

		end


			DECLARE --@LotID VARCHAR(50),
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
					@MaterialCode = MLI.MaterialCode           --add by Mr.Tung on 2022-03-30 because  @MaterialCode  null , can not compare data below
			FROM
					STB_MaterialLotInfo MLI with(nolock) 
					LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI  with(nolock) 
						ON	MSAI.MaterialCode = MLI.MaterialCode
			WHERE
					MLI.LotID = @pLotID




			---- Verify BOM match raw MAterials  select * from stb_bomdetail with(nolock)  
			if (@SourceCompanyCode='VVT' and @ProductCode is not null and @ProductCode<>'') begin
					declare @count INT=0
 					select @count=count(*) from	STB_ProductionOrderBom POB WITH(NOLOCK) 
								--INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK) ON	PO.PONo = POB.PONo 
								join STB_DayProdPlan dpp WITH(NOLOCK) on pob.PONo=dpp.PONo and pob.MaterialCode=dpp.MaterialCode  
					where POB.MaterialCode=@ProductCode 
					and ChildMaterialCode= (select MaterialCode from STB_MaterialLotInfo WITH(NOLOCK) where LotID=@LotID) 

					if(@count<=0) begin
							set @errrr  = N'The raw Material='+@LotID+''+(select MaterialCode from STB_MaterialLotInfo WITH(NOLOCK) where LotID=@LotID) 
										 +N' is not match with BOM! Nguyên liệu đưa vào không khớp với BOM(và PO) của sản phẩm='+@ProductCode;
							set @pErr = @errrr
							if( isnull(@LotID,'')<>'' )
								raiserror (@errrr,16,1);
		
							return;
					end
			end
			---- End verify 
		

 		 
		 
		if(@pKindCheck='FIFO') begin		
				-- Mr.Tung begin FIFO on  10-Feb-2022
				-- Mr.Tung begin FIFO on  10-Feb-2022

								

				-- 선입선출 체크
	
	if(@TargetMaterialWarehouseCode not like 'HOLDING%WH' and @TargetMaterialWarehouseCode not like 'NG_RAW%WH') 		
		IF  /* @IsFIFO = 1  and*/  
				@SourceCompanyCode='VVT' 			
	   		and @MaterialCode  not  in ( 
			'GB332N00-005'
			--những mã code NVL cần bỏ qua FIFO sẽ list ở đây
			  --'GBAKAC-037',
			  --'GBRLAC-005',
			 --'GBRLAC-012',
			  --'GBAKAC-037',
			 -- 'GCTN00-S01',
			--  'GCMTTT-012' , 
			 -- 'GBLYAC-003', 
			--  'GCSN00-002'
			--'GBAKAC-054',
			--'GBAKAC-064',
			--'GBAKAC-036',
			--'GBSN00-005',
			--'GBSN00-001',
			--'GBAKAC-063',
			--'GBNKSP-069',
			--'GCTN00-002',
			--'GBAKAC-068',
			--'GBAKAC-037',
			--'GCSN00-002',
			--'GCMDPT-435',
			--'GBHB00-043',
			--'GBAKAC-052',
			--'GBAKAC-051',
			--'PBDM00-171',
			--'GAJCFO-002',
			--'GAJCFO-010',
			--'GBRBPL-003',
			--'GBCP00-001',
			--'GCMDPT-223',
			--'GCMDPT-301',
			--'GCMDPT-380',
			--'GCMDPT-275',
			--'GCMDPT-379',
			--'GCMDPT-382',
			--'GCMDPT-388',
			--'GCSAAT-001',
			--'GBNKSP-061',
			--'GBNKSP-057',
			--'GBNKSP-054',
			--'GBNKSP-059',
			--'GBNKSP-063',
			--'GBNKSP-067',
			--'GBHB00-036',
			--'GBHB00-034',
			--'GBHB00-042',
			--'GBAKAC-059',
			--'GBNKSP-067',
			--'GBHB00-036',
			--'GBHB00-034',
			--'GBSN00-003',
			--'GBAKAC-059',
			--'GBAKAC-005'
			)
				BEGIN		
				--RAISERROR(@MaterialLotNo ,16, 1)  																					 --For Vietnam Factory Only  on  2022-02-22 by Mr.Tung
					EXEC usp_DoValidateFIFO @pProcessLanguage = @pProcessLanguage,
											@pProcessUserID = @pProcessUserID,
											@pCompanyCode = @SourceCompanyCode,
											@pWorkCenterCode = @SourceWorkCenterCode,
											@pMaterialWarehouseCode = @SourceMaterialWarehouseCode,
											@pMaterialLotNo = @MaterialLotNo

					IF @@ERROR <> 0 BEGIN
						set @pErr = N'FIFO : [usp_VVTMaterialWarehouse_validFIFO]'
						raiserror(@pErr,16,1)
						RETURN
					END

				END
				
				-- Mr.Tung end FIFO on  10-Feb-2022
				-- Mr.Tung end FIFO on  10-Feb-2022

		end 
		
END
