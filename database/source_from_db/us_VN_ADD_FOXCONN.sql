
-- us_VN_ADD_FOXCONN'','','','','','','Small',''          -- exec [dbo].[us_VN_ADD_FOXCONN]   '','','','VVPJ232R740605','','100','',''

 
CREATE PROC [dbo].[us_VN_ADD_FOXCONN]  
		@pProcessUserID VARCHAR(20) =NULL,
	    @pProcessLanguage VARCHAR(20) =NULL,
		@pCPN NVARCHAR(50) = NULL,
		@pLOTNO NVARCHAR(50) = NULL,
		@pCOO NVARCHAR(50) = NULL,
		--@pQTY  NVARCHAR(50) = NULL, --
		@pQTY  NUMERIC(20, 5) = NULL,
		@pTypeBox VARCHAR(20)= NULL,
		@pId int = NULL


AS
BEGIN
	 SET NOCOUNT ON;
	declare @TypeBox VARCHAR(20) = @pTypeBox
	declare @LOTNO NVARCHAR(50) = @pLOTNO
	 declare @QTY  NUMERIC(20, 5) = @pQTY
	declare @Id int = @pId
	 declare @FormattedDate  VARCHAR(20)

	 DECLARE @VV_perModule VARCHAR(20) = 'M%' -- DinhManh add 2025-03-21
	 DECLARE @VE_per VARCHAR(20) = 'VE%'
	
		--SELECT  @FormattedDate =  CONVERT(VARCHAR, InputJobDate, 23)  FROM stb_setInfo where barcode =@LOTNO    --Mr.Manh update 2025-03-24
		--raiserror(@FormattedDate,16,1)


		-- Mr.Manh update 2025-03-24 following Mr.Tha request
		--IF @LOTNO = 'VVPK072R710642'
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-02-07'
		--	END
		--ELSE IF @LOTNO IN ('VVPN292R733503','VVPN292R733504')   -- 2025-06-20
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-05-29'
		--	END
		--ELSE IF @LOTNO IN ('VVPP262R733501',	'VVPP262R733502', 'VVPP262R733503')
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-07-26'
		--	END
		--ELSE IF @LOTNO IN (  -- 2025-08-09
		--	'VVPP282R733501',
		--	'VVPP282R733502',
		--	'VVPP282R733503',
		--	'VVPP282R733504',
		--	'VVPP282R733505'
		--	)  
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-07-28'
		--	END
		--ELSE IF @LOTNO IN (  -- 2025-09-20
		--	'VVPQ213R012617'
		--	)  
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-08-21'
		--	END
		--ELSE IF @LOTNO IN (  -- 2025-09-25
		--	'VVPR233R012601'
		--	)  
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-09-23'
		--	END

		--ELSE IF @LOTNO IN (  -- 2025-10-04
		--	'VVPR162R0740652'
		--	)  
		--	BEGIN 
		--		SELECT  @FormattedDate =  '2025-09-16'
		--	END
		--ELSE
		--	BEGIN
		--		SELECT  @FormattedDate =  CONVERT(VARCHAR, InputJobDate, 23)  FROM stb_setInfo where barcode =@LOTNO 
		--	END

		--raiserror(@FormattedDate,16,1)
		--return;


		-- Mr.Manh BIG UPDATE 2025-10-04: Set @FormattedDate by LOTNo
		declare @Year VARCHAR(4),
				@Month VARCHAR(2),
				@Date VARCHAR(2),
				@year_str VARCHAR(2),
				@month_str VARCHAR(2)

		IF @LOTNO LIKE 'M%'
			BEGIN
				set @year_str = SUBSTRING(@LOTNO, 4, 1)
				set @month_str  = SUBSTRING(@LOTNO, 5, 1)
				set @Date  = SUBSTRING(@LOTNO, 6, 2)
			END
		ELSE 
			BEGIN
				set @year_str  = SUBSTRING(@LOTNO, 3, 1)
				set @month_str  = SUBSTRING(@LOTNO, 4, 1)
				set @Date = SUBSTRING(@LOTNO, 5, 2)
			END

			select @Year = YI.Year from STB_YearInfo YI where YI.YearCode = @year_str

			select @Month = MI.Month from STB_MonthInfo MI where MI.MonthCode = @month_str

			SET @FormattedDate = @Year + '-' + @Month + '-' + @Date

		-- END UPDATE

IF (@TypeBox is null  or  @TypeBox = '') 
		begin


					 
					IF NOT EXISTS (Select * FROM STB_MaterialLotInfo  where LotNo =@LOTNO)
							BEGIN
										raiserror( N'Lot này không tồn tại hoặc chưa đóng gói',16,1)		
										RETURN;
							END
					ELSE 
							BEGIN
											
											IF NOT EXISTS  (Select * FROM STB_VN_STAMP_FOXCONN  where LotNo =@pLOTNO and Qty = @Qty )
												BEGIN

												
													INSERT INTO STB_VN_STAMP_FOXCONN (
																				CPN,
																				Qty,
																				MaterialCode,
																				GRDate,
																				LotNo,
																				PackingID,
																				COO,
																				CreateDateTime,
																				CreateUserID

																			)SELECT top (1)
																					@pCPN,
																					@pQTY,
																					MaterialCode,
																					@FormattedDate,
																					@pLOTNO,
																					PackingID,
																					@pCOO,
																					GETDATE(),
																					@pProcessUserID
 
																			FROM STB_MaterialLotInfo where LotNo =@LOTNO order by CreateDateTime DESC

												END	
												 
									
							END

						--	declare @test varchar(20) =@pQTY
					 --raiserror(@test,16,1)

					 						 SELECT top(1)
																	id,
																	'S' + SVSF.PackingID as PackingIDScan,
																	'L'+SVSF.LotNo as BarcodeScan,
																	'Q'+FORMAT(SVSF.Qty, '0.######') as QtyScan,

																	 'M' +
																	   case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end   as PartNoScan, --'M'+
																	'C' +SVSF.COO as COOScan, --'C' +
																	'P' + @pCPN as CPNScan,
																	--'D'+FORMAT(CAST(SVSF.GRDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	 'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	'P' + @pCPN +','+
																	'Q'+FORMAT(SVSF.Qty, '0.######')+','+
																	'M'+
																	--MM.MaterialName 
																	   CASE
																			-- Điều kiện này để kiểm tra phần chuỗi trước dấu ngoặc đơn
																			-- Mr.Manh comment 2025-03-24 remove 'HY-CAP' following Ms.Sao request
																			-- when CHARINDEX('(', MaterialName) > 0 then RTRIM(LTRIM(SUBSTRING(MaterialName, 1, CHARINDEX('(', MaterialName) - 2)))
    
																			-- Các điều kiện khác không thay đổi
																			when substring(MaterialName, 1, 3) in ('VEC', 'WEC') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 11)))
																			when substring(MaterialName, 1, 3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 14)))
																			when substring(MaterialName, 8, 20) in ('WEM12R0126QG') then RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName) + 1, 12)))
																			else RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))
																		END

																	+','+
																	'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') +','+
																	'L'+SVSF.LotNo +','+ --'L'+
																	'S' + SVSF.PackingID +','+
																	'C' +SVSF.COO  as QRCode,
																	SVSF.CreateDateTime,
																	SVSF.CreateUserID,
																	'PartLabel' AS LabelType,                         
																	'FoxConn자재라벨' AS LabelFormatName,			
																	'Report' AS CommandType,
																	-------------------------------------------------
																	SVSF.PackingID as PackingID,
																	SVSF.LotNo as Barcode,
																	FORMAT(SVSF.Qty, '0.######') as Qty,
																	case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end + 
																					



																					-- DinhManh add 2025-03-13 as requested by Ms.Sao and Ms.Duong Hoa 

																					-- Update on 2025-03-21
																					(  
																						case WHEN @LOTNO like @VV_perModule and CHARINDEX('-LG (1030)', MM.MaterialName) > 0 then '-LG'
																						   WHEN CHARINDEX('-I-L', MM.MaterialName) > 0 THEN '-I-L' 
																						 WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' 

				
																						 WHEN @LOTNO like @VV_perModule and CHARINDEX('-3PLA', MM.MaterialName) > 0 then '-3PLA'
					
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-B030R', MM.MaterialName) > 0 then '-B034'
																							 WHEN @LOTNO in ('VVOT133R850606') and CHARINDEX('-B030R', MM.MaterialName) > 0 then '-B034'
						 																		 WHEN @LOTNO in (
																								'VVOT143R850601',
																								'VVOT153R850606',
																								'VVOT213R850602',
																								'VVOT223R850601',
																								'VVOT203R850601',
																								'VVOT223R850607',
																								'VVOT193R850610',
																								'VVOT213R850606',
																								'VVOU033R850601',
																								'VVOT223R850604',
																								'VVOT253R850607',
																								'VVOU043R850601',
																								'VVOT253R850604',
																								'VVOT193R850604',
																								'VVOT213R850601',
																								'VVOT203R850606',
																								'VVOT203R850604',
																								'VVOT223R850602',
																								'VVOT223R850605',
																								'VVOT213R850607',
																								'VVOU043R850602',
																								'VVOT223R850608',
																								'VVOT213R850603'
																								)  then '-B050'
																							  WHEN @LOTNO in ('VVOT153R850605','VVOT153R850602') then '-B030R'
																						 -- WHEN @LotNo like @VV_perModule and CHARINDEX('-OL', MM.MaterialName) > 0 then '-OL'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-OL', MM.MaterialName) > 0 then '-OL-C68M42'
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-O-T', MM.MaterialName) > 0 then '-O-T'
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-OT', MM.MaterialName) > 0 then '-O-T'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-O', MM.MaterialName) > 0 then '-O'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-IL030', MM.MaterialName) > 0 then '-IL030'
																							 WHEN @LOTNO like @VV_perModule and CHARINDEX('-IC030', MM.MaterialName) > 0 then '-IC030'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-ILB', MM.MaterialName) > 0 then '-ILB'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-IL-ET', MM.MaterialName) > 0 then '-IL-ET'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-ILA', MM.MaterialName) > 0 then '-ILA'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-IL', MM.MaterialName) > 0 then '-IL(9MM)'
					 
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-I-P', MM.MaterialName) > 0 then '-I-P'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-I-T', MM.MaterialName) > 0 then '-I-T'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-I', MM.MaterialName) > 0 then '-I'

																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-HL-104M40', MM.MaterialName) > 0 then '-HL-104M40'
																							 WHEN @LOTNO like @VV_perModule and CHARINDEX('-HL', MM.MaterialName) > 0 then '-HL'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-H', MM.MaterialName) > 0 then '-H'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(67)', MM.MaterialName) > 0 then '-WCI(67MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(80)', MM.MaterialName) > 0 then '-WCI(80MM)'		
					  
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC(40mm)', MM.MaterialName) > 0 then '-WC(40MM)'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC(40)', MM.MaterialName) > 0 then '-WC(40)'

																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC(100)', MM.MaterialName) > 0 then '-WC(100MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC(60mm)', MM.MaterialName) > 0 then '-WC(60MM)'	
			   
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC(50mm)', MM.MaterialName) > 0 then '-WC(50MM)'					   
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC (20mm)', MM.MaterialName) > 0 then '-WC(20MM)'

																						 WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(50mm)', MM.MaterialName) > 0 then '-WCI(50MM)'	
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(25mm)', MM.MaterialName) > 0 then '-WCI(25MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(35mm)', MM.MaterialName) > 0 then '-WCI(35MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(40mm)', MM.MaterialName) > 0 then '-WCI(40MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(67mm)', MM.MaterialName) > 0 then '-WCI(67MM)'
																						   WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(62mm)', MM.MaterialName) > 0 then '-WCI(62MM)'
																						  WHEN @LOTNO like @VV_perModule and CHARINDEX('HY-CAP VEM12R0126QG', MM.MaterialName) > 0 then 'G'
					  																		WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(17mm)', MM.MaterialName) > 0 then '-WCI(17MM)' 
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(35)(3)', MM.MaterialName) > 0 then '-WCI(35)(3)' 
																							WHEN @LOTNO like @VV_perModule and CHARINDEX('-WCI(50)(2)', MM.MaterialName) > 0 then '-WCI(50)(2)' 
																							 WHEN @LOTNO like @VV_perModule and CHARINDEX('-WC', MM.MaterialName) > 0 then '-WC'
																							 WHEN @LOTNO like @VE_per and CHARINDEX('AL-Cap', MM.MaterialName) > 0 then 'Polymer'
						

																						WHEN CHARINDEX('-', MM.MaterialName,12) >= 12 
																						THEN  substring(	MM.MaterialName,
																											CHARINDEX('-', MM.MaterialName,12), 
																											(case when CHARINDEX(' ', MM.MaterialName,12)>CHARINDEX('-', MM.MaterialName,12) 
																												  then  CHARINDEX(' ', MM.MaterialName,12)-CHARINDEX('-', MM.MaterialName,12) 
																												  else (case when CHARINDEX('(', MM.MaterialName,12)>CHARINDEX('-', MM.MaterialName,12) 
																														then  CHARINDEX('(', MM.MaterialName,12)-CHARINDEX('-', MM.MaterialName,12) 
																														else len(MM.MaterialName) - CHARINDEX('-', MM.MaterialName,12)+1 
																														end) 
																											end) 
																									   )
								   	
									
																						  ELSE '' END ) as PartNo,
																					---------------------------------------------------------------------------------------------------------------------------------
																					
																					
																	SVSF.COO as COO, --'C' +
																	@pCPN as CPN,
																	FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCode
															 FROM STB_VN_STAMP_FOXCONN SVSF
															 LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON SVSF.MaterialCode = MM.MaterialCode
															where LotNo =@LOTNO and Qty=@Qty
 
		end
 
 

	IF (@TypeBox  like 'Small') 
				begin
						
					 -- -- Mr.Manh update 2025-03-24 following Mr.Tha request
						--IF @LOTNO = 'VVPK072R710642'
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-02-07'
						--	END
						--ELSE IF @LOTNO IN ('VVPN292R733503','VVPN292R733504')   -- 2025-06-20
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-05-29'
						--	END
						--ELSE IF @LOTNO IN ('VVPP262R733501',	'VVPP262R733502', 'VVPP262R733503')
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-07-26'
						--	END
						--ELSE IF @LOTNO IN (  -- 2025-08-09
						--	'VVPP282R733501',
						--	'VVPP282R733502',
						--	'VVPP282R733503',
						--	'VVPP282R733504',
						--	'VVPP282R733505'
						--	)  
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-07-28'
						--	END
						--ELSE IF @LOTNO IN (  -- 2025-09-20
						--	'VVPQ213R012617'
						--	)  
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-08-21'
						--	END
						--ELSE IF @LOTNO IN (  -- 2025-09-25
						--	'VVPR233R012601'
						--	)  
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-09-23'
						--	END
						--ELSE IF @LOTNO IN (  -- 2025-10-04
						--	'VVPR162R0740652'
						--	)  
						--	BEGIN 
						--		SELECT  @FormattedDate =  '2025-09-16'
						--	END
						--ELSE
						--	BEGIN
						--		SELECT  @FormattedDate =  CONVERT(VARCHAR, InputJobDate, 23)  FROM stb_setInfo where barcode =@LOTNO 
						--	END
						 --raiserror(@LOTNO,16,1)

						 		-- Mr.Manh BIG UPDATE 2025-10-04: Set @FormattedDate by LOTNo

								IF @LOTNO LIKE 'M%'
									BEGIN
										set @year_str = SUBSTRING(@LOTNO, 4, 1)
										set @month_str  = SUBSTRING(@LOTNO, 5, 1)
										set @Date  = SUBSTRING(@LOTNO, 6, 2)
									END
								ELSE 
									BEGIN
										set @year_str  = SUBSTRING(@LOTNO, 3, 1)
										set @month_str  = SUBSTRING(@LOTNO, 4, 1)
										set @Date = SUBSTRING(@LOTNO, 5, 2)
									END

									select @Year = YI.Year from STB_YearInfo YI where YI.YearCode = @year_str

									select @Month = MI.Month from STB_MonthInfo MI where MI.MonthCode = @month_str

									SET @FormattedDate = @Year + '-' + @Month + '-' + @Date

								-- END UPDATE



						SELECT  
																	id,
																	'S' + SVSF.PackingID as PackingIDScan,
																	'L'+SVSF.LotNo as BarcodeScan,
																	'Q'+FORMAT(SVSF.Qty, '0.######') as QtyScan,

																	 'M' +
																	   case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end   as PartNoScan, --'M'+
																	'C' +SVSF.COO as COOScan, --'C' +
																	'P' + @pCPN as CPNScan,
																	--'D'+FORMAT(CAST(SVSF.GRDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	 'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	'P' + @pCPN +','+
																	'Q'+FORMAT(SVSF.Qty, '0.######')+','+
																	'M'+
																	--MM.MaterialName 
																	   CASE
																			-- Điều kiện này để kiểm tra phần chuỗi trước dấu ngoặc đơn
																			-- Mr.Manh comment 2025-03-24 remove 'HY-CAP' following Ms.Sao request
																			-- when CHARINDEX('(', MaterialName) > 0 then RTRIM(LTRIM(SUBSTRING(MaterialName, 1, CHARINDEX('(', MaterialName) - 2)))
    
																			-- Các điều kiện khác không thay đổi
																			when substring(MaterialName, 1, 3) in ('VEC', 'WEC') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 11)))
																			when substring(MaterialName, 1, 3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 14)))
																			when substring(MaterialName, 8, 20) in ('WEM12R0126QG') then RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName) + 1, 12)))
																			else RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))
																		END

																	+','+
																	'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') +','+
																	'L'+SVSF.LotNo +','+ --'L'+
																	'S' + SVSF.PackingID +','+
																	'C' +SVSF.COO  as QRCode,
																	SVSF.CreateDateTime,
																	SVSF.CreateUserID,
																	'PartLabel' AS LabelType,                         
																	'FoxConn자재라벨' AS LabelFormatName,			
																	'Report' AS CommandType,
																	-------------------------------------------------
																	SVSF.PackingID as PackingID,
																	SVSF.LotNo as Barcode,
																	FORMAT(SVSF.Qty, '0.######') as Qty,
																	case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end   as PartNo, --'M'+
																	SVSF.COO as COO, --'C' +
																	@pCPN as CPN,
																	FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCode
						 FROM STB_VN_STAMP_FOXCONN SVSF
						 LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON SVSF.MaterialCode = MM.MaterialCode
						where   SVSF.ParentPackingID = @Id and 
						 TypeBox = 1

						  --raiserror(@Id,16,1)
				end



IF (@TypeBox  like 'Nilon') 
				begin
					 
						
						SELECT 
																		id,
																	'S' + SVSF.PackingID as PackingIDScan,
																	'L'+SVSF.LotNo as BarcodeScan,
																	'Q'+FORMAT(SVSF.Qty, '0.######') as QtyScan,

																	 'M' +
																	   case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end   as PartNoScan, --'M'+
																	'C' +SVSF.COO as COOScan, --'C' +
																	'P' + @pCPN as CPNScan,
																	--'D'+FORMAT(CAST(SVSF.GRDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	 'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCodeScan,
																	'P' + @pCPN +','+
																	'Q'+FORMAT(SVSF.Qty, '0.######')+','+
																	'M'+
																	--MM.MaterialName 
																	   CASE
																			-- Điều kiện này để kiểm tra phần chuỗi trước dấu ngoặc đơn
																			-- Mr.Manh comment 2025-03-24 remove 'HY-CAP' following Ms.Sao request
																			-- when CHARINDEX('(', MaterialName) > 0 then RTRIM(LTRIM(SUBSTRING(MaterialName, 1, CHARINDEX('(', MaterialName) - 2)))
    
																			-- Các điều kiện khác không thay đổi
																			when substring(MaterialName, 1, 3) in ('VEC', 'WEC') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 11)))
																			when substring(MaterialName, 1, 3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName, 1, 14)))
																			when substring(MaterialName, 8, 20) in ('WEM12R0126QG') then RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName) + 1, 12)))
																			else RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))
																		END

																	+','+
																	'D'+FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') +','+
																	'L'+SVSF.LotNo +','+ --'L'+
																	'S' + SVSF.PackingID +','+
																	'C' +SVSF.COO  as QRCode,
																	SVSF.CreateDateTime,
																	SVSF.CreateUserID,
																	'PartLabel' AS LabelType,                         
																	'FoxConn자재라벨' AS LabelFormatName,			
																	'Report' AS CommandType,
																	-------------------------------------------------
																	SVSF.PackingID as PackingID,
																	SVSF.LotNo as Barcode,
																	FORMAT(SVSF.Qty, '0.######') as Qty,
																	case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
																					when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
																					when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
																					else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end   as PartNo, --'M'+
																	SVSF.COO as COO, --'C' +
																	@pCPN as CPN,
																	FORMAT(CAST(@FormattedDate AS DATE), 'yyyyMMdd') AS DateCode
						 FROM STB_VN_STAMP_FOXCONN SVSF
						 LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON SVSF.MaterialCode = MM.MaterialCode
						where   SVSF.ParentPackingID = @Id and 
						 TypeBox = 2

						  --raiserror(@Id,16,1)
				end





	--select * from STB_MaterialLotInfo where lotno ='VVOT153R850602'
END

--delete FROM STB_VN_STAMP_FOXCONN
--SELECT * FROM STB_VN_STAMP_FOXCONN where LotNo ='VVPJ232R740605'

 





