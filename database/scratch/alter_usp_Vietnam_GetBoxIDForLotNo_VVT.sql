
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : ???? > [B520]???????? > Grid-3 BOX ID ??
-- Description: ???? ?? ??? ?? ??? ??? ?????
-- Modified:

-- exec [usp_Vietnam_GetBoxIDForLotNo_VVT] '','','VVPN113R036708','', ''
--update STB_MaterialLotInfo set Materialcode = 'LIVT38-018' where lotID = 'LIVT38-018OP1700019' ---
-- =============================================
ALTER PROCEDURE [dbo].[usp_Vietnam_GetBoxIDForLotNo_VVT]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL,
						@pLabelType NVARCHAR(30) = NULL
						,@psagemcom VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @LabelType NVARCHAR(30) = @pLabelType 
	DECLARE @LotNo VARCHAR(100) = @pLotNo 

	DECLARE @IsModule BIT = 0 
	DECLARE @ext_partno VARCHAR(50) = ''
	set @psagemcom = isnull(@psagemcom,'');
			
	DECLARE @V_per VARCHAR(20) = 'V%'
	DECLARE @VV_perModule VARCHAR(20) = 'M%'
	DECLARE @VV_per VARCHAR(20) = 'VV%'
	DECLARE @VV_char VARCHAR(20) = 'VV'
	DECLARE @VE_per VARCHAR(20) = 'VE%'

	DECLARE @VJ_per VARCHAR(20) = 'VJ%'
	DECLARE @VJ_char VARCHAR(20) = 'VJ'
	 DECLARE @MJ_char VARCHAR(20) = 'MVJ'
	   
	DECLARE @r27_char VARCHAR(20) = '2R7'
	DECLARE @r30_char VARCHAR(20) = '3R0'

	DECLARE @r27_per VARCHAR(20) = '%2R7%'
	DECLARE @230_per VARCHAR(20) = '%3R0%'

    if(@pLotNo='VEM3562' OR @pLotNo='VVM3562' )
	begin
		


		;WITH LabelInfo AS
				(
					SELECT
							RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
							LI.LabelType,
							LI.FormatName,
							LI.CommandType,
							LI.Dpi,
							LI.PrinterName
					FROM
							SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
					WHERE
							LabelType='VietnamVEM3562Packing'
				)
			SELECT top 1
			'EDVTMD-082' as MaterialCode,
			'HY-CAP VEM16R0606QG' as MaterialName,
			'6S' as LotID,
			'' as PackingID,
			'VietnamVEM3562Packing' as LabelType,
			'VEM3562Packing' as FormatName,
			'Report' as CommandType,
			200 as Dpi,
			'' as PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			
			MLI.CurrentQty,
			
			'16V 60F' AS LotNo,

			'3' AS Voltage, 
			'360' AS Farad,
			'(3562)' AS Rating,		
			
			'VEM16R0606QG'	AS PartNo,
			@IsModule AS IsModule,
			MLI.StockAttrib1,
			'' AS DC,
			'' AS MarkingLetter
			, 5  AS VinylBagQty  -- 2020.10.08 ??
			, 5  AS InnerBoxQty  -- 2020.10.08 ??
			, 15   AS  OutBoxQty   -- 2020.10.08 ??
		--,	'' AS LotQtyTwo
			 ,''  AS ThinkwareBarcode

			FROM
					STB_MaterialLotInfo MLI WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
					LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = 'VietnamVEM3562Packing'
					LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
					LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
					LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
					LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)

					LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 ?? 
			WHERE
					mli.CompanyCode='VVT' and mli.LotNo LIKE @VV_per
		--END

		return;
	end	



	
	--edited by Mr.Tung on 27-March-2021 
	--For Vietnam Factory printing VJ label
	DECLARE @allowVJ BIT = 0 
	DECLARE @allowMJ BIT = 0 
	DECLARE @VJ2VV   BIT = 0 
	
	
	DECLARE @CompanyVal VARCHAR(20) = ''
	
	if(@LotNo in ('')) set @VJ2VV=0


	 --raiserror ( @LotNo ,16,1)
	
	  SELECT @CompanyVal = [CompanyCode]
	  FROM [SmartFactoryV2].[dbo].[STB_UserInfo] WITH(NOLOCK) 
	  where UserID = @pProcessUserID
	  
	  	--raiserror (@LotNo,16,1) 

		 DECLARE @MaterialName VARCHAR(200) = '' 
			DECLARE @PartNo VARCHAR(200) = '' 
			DECLARE @MaterialCod0 VARCHAR(200) = '' 
			DECLARE @PackQty numeric 
			DECLARE @cCount INT 
		 --VEC3R0106QG-B084
		 --VEC3R0106QG
		 select 
		 @MaterialCod0 = MLI.MaterialCode,
		
		--LÃ¡y PARTNO
		@PartNo = case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
						when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
						when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thÃªm t?m 
						else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end , 
	
		 -- L?y duÃ´i c?a PARTNO , trÃªn lÃ  Module , m?y dÃ²ng cu?i lÃ  CEll
		 @ext_partno = 		 
					(  

					case WHEN @LotNo like @VV_perModule and CHARINDEX('-LG (1030)', MM.MaterialName) > 0 then '-LG'
						WHEN @LotNo like @VV_char and CHARINDEX('XLC', MM.MaterialName) > 0 then '-XLC'
					   WHEN CHARINDEX('-I-L', MM.MaterialName) > 0 THEN '-I-L' 
					 --WHEN @LotNo IN (
						--	'VVPK033R010707',
						--	'VVPK033R010708',
						--	'VVPK033R010709',
						--	'VVPK043R010703',
						--	'VVPK043R010707'
						-- ) and CHARINDEX('-L', MM.MaterialName) > 0 THEN '-B036'					--DinhManh update 2025-04-16 following Mr.Long request
						WHEN @LotNo IN (
							'MVVPO206R015501',
							'MVVPO206R015502',
							'MVVPP166R010501'
						) and CHARINDEX('-OT-L', MM.MaterialName) > 0 then '-OT-L(L&G)' -- 2025-06-20
					 WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' 
					 --WHEN (@LotNo='VVPN163R850605') THEN '-B034 (0825)'
					 WHEN (@LotNo = 'VVOO133R015612') THEN '-L' --DinhManh update 2025-04-14 following Ms.Phuong request
					 WHEN (@LotNo = 'VVPM303R033551') THEN '-C035'   --DinhManh update 2025-05-07 following Ms.Phuong request
						WHEN @LotNo like @VV_char and CHARINDEX('XLC', MM.MaterialName) > 0 then '-XLC'
					 WHEN @LotNo like @VV_perModule and CHARINDEX('-3PLA', MM.MaterialName) > 0 then '-3PLA'
						WHEN @LotNo like @VV_perModule and CHARINDEX('-WC', MM.MaterialName) > 0 and @MaterialCod0 = 'EDVTMD-230' then '-WCI(52)'


						WHEN @LotNo like @VV_perModule and CHARINDEX('-B030R', MM.MaterialName) > 0 then '-B034'
						 WHEN @LotNo in ('VVOT133R850606') and CHARINDEX('-B030R', MM.MaterialName) > 0 then '-B034'
						 	 WHEN @LotNo in (
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
							WHEN @LotNo in (
							'MVVPL126R015501',
							'MVVPL126R015502',
							'MVVPL126R015503',
							'MVVPL126R015504',
							'MVVPL126R015505',
							'MVVPL126R015506'
							) and CHARINDEX('-H', MM.MaterialName) > 0 then '-H(L&G)'
						  WHEN @LotNo in ('VVOT153R850605','VVOT153R850602') then '-B030R'
					 -- WHEN @LotNo like @VV_perModule and CHARINDEX('-OL', MM.MaterialName) > 0 then '-OL'
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-OL', MM.MaterialName) > 0 then '-OL-C68M42'
					    WHEN @LotNo like @VV_perModule and CHARINDEX('-O-T', MM.MaterialName) > 0 then '-O-T'
					    WHEN @LotNo like @VV_perModule and CHARINDEX('-OT', MM.MaterialName) > 0 then '-O-T'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-O', MM.MaterialName) > 0 then '-O'
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-IL030', MM.MaterialName) > 0 then '-IL030'
					     WHEN @LotNo like @VV_perModule and CHARINDEX('-IC030', MM.MaterialName) > 0 then '-IC030'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-ILB', MM.MaterialName) > 0 then '-ILB'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-IL-ET', MM.MaterialName) > 0 then '-IL-ET'
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-ILA', MM.MaterialName) > 0 then '-ILA'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-IL', MM.MaterialName) > 0 then '-IL(9MM)'
					  
					 
					    WHEN @LotNo like @VV_perModule and CHARINDEX('-I-P', MM.MaterialName) > 0 then '-I-P'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-I-T', MM.MaterialName) > 0 then '-I-T'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-I', MM.MaterialName) > 0 then '-I'

					    WHEN @LotNo like @VV_perModule and CHARINDEX('-HL-104M40', MM.MaterialName) > 0 then '-HL-104M40'
						 WHEN @LotNo like @VV_perModule and CHARINDEX('-HL', MM.MaterialName) > 0 then '-HL'


						 WHEN @LotNo in (
							'MVVPM256R015508'
							)  then '-H'   -- 2025-05-05
						
						   WHEN @LotNo like @VV_perModule and CHARINDEX('-H(L&G)', MM.MaterialName) > 0 then '-H(L&G)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-H', MM.MaterialName) > 0 then '-H'

					   WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(67)', MM.MaterialName) > 0 then '-WCI(67MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(80)', MM.MaterialName) > 0 then '-WCI(80MM)'		
					  
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(40mm)', MM.MaterialName) > 0 then '-WC(40MM)'
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(40)', MM.MaterialName) > 0 then '-WC(40)'

					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(100)', MM.MaterialName) > 0 then '-WC(100MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(60mm)', MM.MaterialName) > 0 then '-WC(60MM)'	

						WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(35mm)', MM.MaterialName) > 0 then '-WC(35MM)'

					   WHEN @LotNo like @VV_perModule and CHARINDEX('-WC(50mm)', MM.MaterialName) > 0 then '-WC(50MM)'					   
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WC (20mm)', MM.MaterialName) > 0 then '-WC(20MM)'

					 WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(50mm)', MM.MaterialName) > 0 then '-WCI(50MM)'	
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(25mm)', MM.MaterialName) > 0 then '-WCI(25MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(35mm)', MM.MaterialName) > 0 then '-WCI(35MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(40mm)', MM.MaterialName) > 0 then '-WCI(40MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(67mm)', MM.MaterialName) > 0 then '-WCI(67MM)'
					   WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(62mm)', MM.MaterialName) > 0 then '-WCI(62MM)'
					  WHEN @LotNo like @VV_perModule and CHARINDEX('HY-CAP VEM12R0126QG', MM.MaterialName) > 0 then 'G'
					  	WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(17mm)', MM.MaterialName) > 0 then '-WCI(17MM)' --Mr.Tung on 2022-01-12
						WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(35)(3)', MM.MaterialName) > 0 then '-WCI(35)(3)' --Duy Add
						WHEN @LotNo like @VV_perModule and CHARINDEX('-WCI(50)(2)', MM.MaterialName) > 0 then '-WCI(50)(2)' --Duy Add
					     WHEN @LotNo like @VV_perModule and CHARINDEX('-WC', MM.MaterialName) > 0 then '-WC'
						 
						 WHEN @LotNo like @VE_per and CHARINDEX('AL-Cap', MM.MaterialName) > 0 then 'Polymer'
						
							  
					  -- Mr.Tung add on 2023-Feb-13 for TU DONG LAY DUOI TRONG TEN HANG c?a hÃ ng CELL line  VVOT133R850606
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
					-- Mr.Tung add on 2023-Feb-13 for TU DONG LAY DUOI TRONG TEN HANG c?a hÃ ng CELL line
								   	
									
					  ELSE '' END ),
		 @MaterialName = MM.MaterialName,
		 @PackQty = CurrentQty
		 from 		 STB_MaterialLotInfo MLI   WITH(NOLOCK) join  STB_MaterialMaster MM  WITH(NOLOCK)  on  MLI.MaterialCode = MM.MaterialCode
		 where   LotNo = @LotNo

		 if @LotNo  not in ( --'VVNS213R012602',--'VVNM243R850608',
						'VVNL293R850603',
						'VVNM073R850623',
						'VVNM243R850607',
						'VVNM263R850604',
						'VVNM243R850604',
						'VVNL293R850601',
						'VVNM243R850602',
						'VVNM193R850613',
						'VVNM223R850607',
						'VVNM253R850606',
						'VVNM243R850609',
						'VVNL293R850602',
						'VVNM253R850607',
						'VVNM253R850604',
						'VVNM263R850601',
						'VVNM193R850611',
						'VVNM253R850601',
						'VVNM223R850603',
						'VVNM193R850612',
						'VVNM253R850602',
						'VVNM253R850603',
						'VVNM213R850607',
						'VVNM203R850606',
						'VVNM223R850606',
						'VVNM223R850604',
						'VVNM203R850601',
						'VVNM113R850606',
						'VVNM213R850608',
						'VVNM223R850608',
						'VVNM203R850608',
						'VVNM223R850601',
						'VVNM203R850607',
						'VVNM223R850602',
						'VVNM263R850603',
						'VVNO242R750634'
						
						) 
			begin
			--raiserror ( @ext_partno ,16,1)
			set @PartNo = @PartNo+@ext_partno
			end
		 else
			 set @PartNo = @PartNo 
				 
				--raiserror ( @PartNo ,16,1)
			--	select * from STB_Vietnam_PackingPrinting
		-- Cho PhÃ©p in chuy?n t? VV thÃ nh VJ , di?u ki?n PARTNO lÃ m chu?n		-- DinhManh update 2025-06-18 remove VJ for Model VPC 1335 (LIVT38-009), following Mr.Diep BG 's request
		 select  top  1  @allowVJ = PrintVJ
		 from    STB_Vietnam_PackingPrinting WITH(NOLOCK) 
		 where   (MaterialCode = @MaterialCod0 or PartNo = @PartNo) and (PrintVJ=1 or PrintVJ='1')	



		 -- NGo?i l? khÃ´ng in VJ n?a, thÃ¬ cho vÃ o bÃªn du?i dÃ¢y
		if ( @LotNo in (
		----B? in VJ theo Mr.Trung
		'VVOS093R825703',
		'VVOS103R825708',
		'VVOS093R825705',
		'VVOS103R825703',
		'VVOS103R825706',
		'VVOS053R825702',
		'VVOS093R825704',
		'VVOS113R825701',
		'VVOS083R825709',
		'VVOS053R825703',
		'VVOS103R825705',
		'VVOS103R825707',
		'VVOS093R825706',
		'VVOS093R825708',
		'VVOS103R825704',
		'VVOS103R825701',
		'VVOS023R825705',
		'VVOS093R825702',
		'VVOS093R825701',
		'VVOS053R825707',
		'VVOS103R825702',
		'VVOS093R825707',
		'VVOS083R825701',
		'VVOS043R825704',
		'VVOS043R825707',
		'VVOT133R850605',
		'VVOT013R830601',
		'VVOS313R830602',
		'VVOS073R825706', 
		'VVOS083R825711', 
		'VVOS053R825704', 
		'VVOS083R825702', 
		'VVOS073R825704', 
		'VVOS043R825706', 
		'VVOS043R825708', 
		'VVOS023R825707',
		'VVOS033R825708', 
		'VVOS043R825701', 
		'VVOS033R825706', 
		'VVOS033R825707', 
		'VVOS043R825703', 
		'VVOS043R825705',
		 'VVOS053R825706', 
		 'VVOS043R825702', 
		 'VVOS073R825701',
		  'VVOS023R825706',
		 'VVOS053R825701',
		  'VVOS073R825707',
		  'VVOS033R825703', 
		  'VVOS073R825702',
		'VVOS073R825705',
		--2024-12-10
		'VVOU032R725616',
		'VVOU032R725619',
		'VVOU022R725623',
		'VVOU022R725625',
		'VVOU092R725606',
		'VVOU022R725626',
		'VVOS033R825704',
		'VVOS053R825705',
		'VVOS033R825705',
		'VVOS073R825703',
		'VVOU243R825702',
		'VVOU233R825707',
		'VVOU233R825710',
		'VVOU253R850601'
		) 
		)set @allowVJ  = 0

		if(@LotNo in ( --set d? chuy?n module sang MVJ
		'MVVOR206R025501',
		'MVVOR206R025502',
		'MVVOR206R025503',
		'MVVOR206R025504',
		'MVVOR206R025505',
		'MVVOR206R025506',
		'MVVOR236R025501',
		'MVVOR236R025502',
		'MVVOR236R025503',
		'MVVOR246R025501',
		'MVVOR246R025502',
		'MVVOR246R025503',
		'MVVOR236R025504',
		'MVVOR236R025505',
		'MVVOR236R025506',
		'MVVOR246R025504',
		'MVVOR246R025505',
		'MVVOR246R025506',
		'MVVOR246R025507'
		))set @allowMJ  = 1

		--RAISERROR('fds',16,1)
		if(@LotNo in ( --set d? in VJ
		'VVOU032R725613',
		'VVOU092R725606',
		'VVOU133R850605',
		'VVOU133R850623',
		'VVOU133R850624',
		'VVOU133R850625',
		'VVOU173R850601',
		'VVPT063R050505'
		))set @allowVJ  = 1
	if( (@LotNo like @VV_per and @CompanyVal='VVT')  ) 
	begin 			
				 declare @isDisableVJ int = 0
				 exec usp_Vietnam_GetExceptVJ  @LotNo, @isDisableVJ  OUTPUT  --this Procedure for except to print VJ Label

				 if (@isDisableVJ > 0)
				 begin
					select @allowVJ = 0
				 end
		 

		 if(@allowVJ=1  )
		 begin
					--RAISERROR(@PartNo,16,1)
				select  @cCount = count(*)
				from	 STB_SavePackingTime_VVT WITH(NOLOCK) 
				where LotNo = @LotNo

				if (@cCount < 2  )
				begin
				
		 			insert into STB_SavePackingTime_VVT (PackingID, LotNo, MaterialCode, MaterialName, PackQty, PrintTime, EmpNo, isPrinted, isModule, partNo)
					values (STUFF( ( @LotNo ) , 
										1, 
										2,  
										 @VJ_char ) , 
						 @LotNo, @MaterialCod0, @MaterialName, -@PackQty, getdate(), @pProcessUserID, 0, 0,  @PartNo  )
				end
		 end
	end 



	-----Mr.Tung check Duplicate LOT Label
	declare @tmplotno varchar(50)
	SELECT
		@tmplotno=	
			(case when @allowVJ=1 
			then STUFF(  MLI.LotNo  , 
								1, 
								2,  
								 @VJ_char ) 
				
			 else ISNULL(PLS.LotNo, MLI.LotNo) end)
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType			
			LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 ?? 
	WHERE
			MLI.LotNo = @LotNo


	if(@tmplotno<>@LotNo)begin
		declare @countexists int
		select @countexists=count(*) 		from STB_SetInfo		where Barcode=@tmplotno
		if (@countexists>0) begin
			declare @tmpAlert varchar(500)=@tmplotno+' - Ma Lot nay neu in Label se bi trung voi Lot o Han Quoc, khong duoc phep in Label!' 
			raiserror(@tmpAlert,16,1)
			return;
		end
	end
	-----Mr.Tung check Duplicate LOT Label






	-- ch? nÃ y liÃªn quan t?i ph?n m?m cÃ¢nn n?ng trong kho , n?u chua cÃ¢n thÃ¬ khÃ´ng cho in LAngbel
	-- table cÃ¢n n?ng trong kho   STB_VIETNAM_BARCODEWEIGHT
	declare @lotweight float=0;

	select @lotweight = count(*) from stb_modelbasicinfo  mbi with(nolock)
	where modelcode = (select materialcode from STB_SetInfo where Barcode=@LotNo)
	and RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) in ('1840','1859') -- do not need to check weight of 1840 & 1859
	
	if(@lotweight=0)
		set @lotweight =convert(float,(SELECT TOP 1 [WEIGHT] FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE=@LotNo AND [WEIGHT] > 1 ORDER BY CREATEDATETIME DESC))
	
		--declare @lotweight111 varchar(20)=@lotweight;
	--raiserror(@lotweight111,16,1)
	if(@pProcessUserID in ('vvt_worker','vvtworker','huyen','mrchien','mrdiep','trantrung','msphuong','phuongnt','dangchinh','nguyennha','nguyentha','anhduy157','dinhmanh','vvtworker_bg','hoangxuan','worker_hn','ngocanh','HaiTrieu')) set @lotweight =1;

	
	/* T? thay d?i lotno  */
	DECLARE @LotNoFirst VARCHAR(100)
	select @LotNoFirst=OldBarcode from STB_LotChangeMaterialHistory where (newbarcode=@LotNo or OldBarcode=@LotNo)  -- l?y ra lot tru?c khi d?i ma code ? B351

	declare @oldLotid varchar(50),@newLotid varchar(50)
	select @oldLotid=oldLotid,@newLotid=newLotid from [STB_ChangePartNoAndLotNo] where (oldLotid=@LotNoFirst or oldLotid=@LotNo) and isLotID = 1

	declare @oldLotid1 varchar(50),@newLotid1 varchar(50)
	if EXISTS(select * from [STB_ChangePartNoAndLotNo] where (oldLotid=@newLotid  ) and isLotID = 1 )
    begin
		select @oldLotid1=oldLotid,@newLotid1=newLotid from [STB_ChangePartNoAndLotNo] where (oldLotid=@newLotid  ) and isLotID = 1
        select @oldLotid=oldLotid,@newLotid=newLotid from [STB_ChangePartNoAndLotNo] where (oldLotid=@oldLotid1 or oldLotid=@newLotid1) and isLotID = 1
    end
	--end
	--SELECT TOP 5 [WEIGHT] FROM STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE='VJOJ203R018618' AND [WEIGHT] > 1 ORDER BY CREATEDATETIME DESC

	------------------------------------------------------------
	------------------------GENERAL PART------------------------
	------------------------------------------------------------ 
--raiserror(@PartNo,16,1)
	;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()

	)
	SELECT
			MLI.MaterialCode,
			MM.MaterialName,
			--Case when MLI.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else MM.MaterialName end as MaterialName, --Ms Phuong request update audit 2025-11-26
			MLI.LotID,
			MLI.PackingID,

			case when isnull(@lotweight,0)=0 then N'Kho ThÃ nh ph?m chua nh?p cÃ¢n n?ng cho LÃ³t hÃ ng nÃ y!'
				 else  isnull(LI.LabelType,'BoxLabel')  + (case when @psagemcom<>'' then 'VVT' else '' end) end  as LabelType,
			
			case when isnull(@lotweight,0)=0 then N'Kho ThÃ nh ph?m chua nh?p cÃ¢n n?ng cho LÃ³t hÃ ng nÃ y!'
				 else(
					  case 
					  when MLI.WorkCenterCode='VVT_F3'  then LI.FormatName+'NewVietNam_HN' 
					  when LI.FormatName like '%???%' then LI.FormatName+'NewVietNam' 
						  else (
						  case when @psagemcom<>'' then '????Sagecom' 
									else '????NewVietNam' 
									end) 
					  end
					 )
			end as FormatName,

			 isnull(LI.CommandType,'Report')  as CommandType,
			 isnull(LI.Dpi,'200')  as Dpi,
			isnull(LI.PrinterName,'') PrinterName,
			--LI.FormatName,
			--LI.CommandType,
			--LI.Dpi,
			--LI.PrinterName,
			0 AS LabelQty,
			0 AS LotQty,
			--'' AS LotQty,
			MLI.CurrentQty,
			--ISNULL(PLS.LotNo, MLI.LotNo)  AS LotNo,
			(case 
				when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'  -- update 2025-04-24 following Ms.Trinh request
				when @LotNo = 'VVPM153R825714' then 'VVPM153R825714'
				when @LotNo='VVPN163R850617' then 'VVPN163R850617'
			   when (@LotNoFirst = @oldLotid or @oldLotid =@Lotno) then @newLotid --tÃ¹y ch?n chuy?n d?i lotno 
				when @VJ2VV=1 or @VJ2VV=convert(bit,1)  then STUFF(MLI.LotNo,1,2,@VV_char)
				 when @LotNo ='VVOT143R850602' then 'VJOQ143R850602'
				 when @LotNo ='VVOT163R850606' then 'VJOQ163R850606'
				 when @LotNo ='VVOT153R850604' then 'VJOQ153R850604'
				 when @LotNo ='VVOT183R850603' then 'VJOQ183R850603'
				 when @LotNo ='VVOT163R850601' then 'VJOQ163R850601'
				 when @LotNo ='VVOT163R850603' then 'VJOQ163R850603'
				 when @LotNo ='VVOT193R850608' then 'VJOQ193R850608'
				 when @LotNo ='VVOT153R850603' then 'VJOQ153R850603'
				 when @LotNo ='VVOT163R850602' then 'VJOQ163R850602'
				 when @LotNo ='VVOT183R850602' then 'VJOQ183R850602'
				 when @LotNo ='VVOT143R850606' then 'VJOQ143R850606'
				 when @LotNo ='VVOT163R850605' then 'VJOQ163R850605'
				 when @LotNo ='VVOT163R850604' then 'VJOQ163R850604'
				 when @LotNo ='VVOT193R850603' then 'VJOQ193R850603'
				 when @LotNo ='VVOT193R850601' then 'VJOQ193R850601'
				 when @LotNo ='VVOT183R850604' then 'VJOQ183R850604'
				 when @LotNo ='VVOR043R850603' then 'VJOQ043R850603'
				 --when @LotNo ='VVOT123R850601' then 'VVOQ123R850601'
				 when @LotNo ='VVOT123R850601' then 'VJOQ123R850601'
				 when @LotNo ='VVOT183R850601' then ' VJOQ183R850601'
				 when @LotNo ='VVOT123R850601' then ' VJOQ123R850601'
				 when @LotNo = 'VVOT263R850601' then 'VJOQ263R850601'
				when @LotNo = 'VVOT143R850605' then 'VJOQ143R850605'
				when @LotNo = 'VVOT253R850608' then 'VJOQ253R850608'
				when @LotNo = 'VVOT253R850606' then 'VJOQ253R850606'
				when @LotNo = 'VVOT153R850602' then 'VJOQ153R850602'
				when @LotNo = 'VVOT153R850605' then 'VJOQ153R850605'
				when @LotNo = 'VVOT143R850604' then 'VJOQ143R850604'
				when @LotNo = 'VVOT203R850607' then 'VJOQ203R850607'
				when @LotNo = 'VVOT183R850605' then 'VJOQ183R850605'
				when @LotNo = 'VVOT253R850605' then 'VJOQ253R850605'
				when @LotNo = 'VVOT213R850608' then 'VJOQ213R850608'
				when @LotNo = 'VVOT123R850602' then 'VJOQ123R850602'
				when @LotNo = 'VVOT133R850606' then 'VJOQ133R850606'
				when @LotNo = 'VVOT193R850609' then 'VJOQ193R850609'
				when @LotNo = 'VVOT153R850601' then 'VJOQ153R850601'
				when @LotNo = 'VVOK243R010706' then 'VVOQ243R010706'
				when @LotNo = 'VVOK233R010703' then 'VVOQ233R010703'
				when @LotNo = 'VVOU113R850602' then 'VVOU113R850602'
				when @LotNo = 'VVOU243R850603' then 'VJOR243R850603'
				when @LotNo = 'VVOU253R850603' then 'VJOR253R850603'
				when @LotNo = 'VVOU253R850601' then 'VJOR253R850691'
				when @LotNo = 'VVPJ152R710651' then 'VVPJ152R710651'
				--when @LotNo = 'VVPM193R825727' then 'VVPM193R825727'
			  when @LotNo='VVPM233R850601' then 'VVPM233R850601'
			  when @LotNo='VVPM233R825706' then 'VVPM233R825706'
			  when @LotNo='VVPN163R850606' then 'VVPN163R850606'
				 when @LotNo='VVPN163R850605' then 'VVPN163R850605'
				 when @LotNo='VVPM253R850601' then 'VVPM253R850601'
				 when @Lotno='VVPN153R825710' then 'VVPN153R825710'
				 when @LotNo='VVPN153R825711' then 'VVPN153R825711'
				 when @LotNo='VVPN193R825703' then 'VVPN193R825703'
				 when @LotNo='VVPN153R825701' then 'VVPN153R825701'
				 when @LotNo='VVPN173R825710' then 'VVPN173R825710'
				 when @LotNo='VVPN173R825709' then 'VVPN173R825709'
				 when @LotNo='VVPN153R825703' then 'VVPN153R825703'
				 when @LotNo='VVPN153R825702 'then 'VVPN153R825702'
				 when @LotNo='VVPN143R825710' then 'VVPN143R825710'
				 when @LotNo='VVPN163R825711' then 'VVPN163R825711'
				 when @LotNo='VVPN243R825701' then 'VVPN243R825701'
				 when @LotNo='VVPN233R825701' then 'VVPN233R825701'
				 when @LotNo='VVPN243R825705' then 'VVPN243R825705'
				 when @LotNo='VVPN243R825704' then 'VVPN243R825704'
				 when @LotNo='VVPN243R825703' then 'VVPN243R825703'
				 when @Lotno='MVVOR246R025507' then 'MVVOR246R025507'

				 when @Lotno='MVVPO196R011502' then 'MVVPO196R015502'
				 when @LotNo='MVVPO196R011501'  then 'MVVPO196R015501'
				 when @LotNo='VVPP103R850601' then 'VVPO293R850601'
				 when @LotNo='VVPM263R850601' then 'VVPM263R850601'
			     when @LotNo='VVPM243R850605' then 'VVPM243R850605'
				 when @LotNo='VVQK273R010628' then 'VVQK273R012628'
			     when @LotNo='VVQK273R010629' then 'VVQK273R012629'
				 when @LotNo='VVQK273R010630' then 'VVQK273R012630'
				 when @LotNo='VVQK273R010631' then 'VVQK273R012631'
				 when @LotNo='VVQK273R010632' then 'VVQK273R012632'
				 when @LotNo='VVQK273R010633' then 'VVQK273R012633'
				 when @LotNo='VVQK273R010634' then 'VVQK273R012634'
				 when @LotNo='MVVPK046R035501' then 'MVVQL046R035501'
				  WHEN @LotNo='VVQK273R010628' then 'VVQK273R012628'
		 WHEN @LotNo='VVQK273R010629' then 'VVQK273R012629'
		 WHEN @LotNo='VVQK273R010630' then 'VVQK273R012630'
		 WHEN @LotNo='VVQK273R010631' then 'VVQK273R012631'
		 WHEN @LotNo='VVQK273R010632' then 'VVQK273R012632'
		 WHEN @LotNo='VVQK273R010634' then 'VVQK273R012634'
		 WHEN @LotNo='VVQK273R010635' then 'VVQK273R012635'
				 when @LotNo like 'VVPQ132R715%' then REPLACE(@LotNo, 'R715', 'R7156')
				else
					(case when @allowVJ=1  then STUFF( ( MLI.LotNo ) , 
																	1, 
																	2,  
																	 @VJ_char 										 
																	 ) 
						when @allowMJ=1 then STUFF( ( MLI.LotNo ) , 
																	1, 
																	3,  
																	 @MJ_char 										 
																	 ) 

					else ISNULL(PLS.LotNo, MLI.LotNo) 
					end) 
		
			  end ) AS LotNo, --edited by Mr.Tung on 27-March-2021 
			  CASE 
           WHEN @PartNo = 'VEL08203R8306G' THEN '3.8' --Mr.Trieu theo yÃªu c?u c?a ch? nhu(B?c Giang)
		    WHEN @LotNo = 'VVQJ263R060642' THEN '3.0'
              ELSE ISNULL(PLS.Voltage, MBI.MBIExtText04)
          END AS Voltage,

			--ISNULL(PLS.Voltage, MBI.MBIExtText04) AS Voltage, 
			CASE 
                 WHEN @LotNo = 'MVVQJ196R010501' THEN '1'
               ELSE ISNULL(PLS.Farad, MBI.MBIExtText05) 
             END AS Farad,
			--ISNULL(PLS.Farad, MBI.MBIExtText05) AS Farad,
			CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeW)) as MBISizeW,
			CONVERT(VARCHAR, CONVERT(numeric(20,1), MBI.MBISizeH)) as MBISizeH,
			--CASE
			--	WHEN @PartNo='VEL13353R8257G-B0625' THEN '3.8'
				
			--	ELSE ISNULL(PLS.Voltage, MBI.MBIExtText04)
			--END as Voltage,
		
			
			 
			-- CASE
			--	WHEN @PartNo='VEL13353R8257G-B0625' THEN '250'
				
			--	ELSE ISNULL(PLS.Farad, MBI.MBIExtText05)
			--END as Farad,
			--CASE
			--	WHEN @PartNo='VEL13353R8257G-B0625' THEN '(1335)'
				
			--	ELSE ISNULL(PLS.Rating, '(' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) + ')')
			--END as Rating,
			ISNULL(PLS.Rating, '(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')') AS Rating,
			-- ISNULL(PLS.PartNo, RTRIM(LTRIM(SUBSTRING(ModelName, CHARINDEX(' ', ModelName), 12))))  + (CASE WHEN CHARINDEX('-L', ModelName) > 0 THEN '-L' ELSE '' END) AS PartNo,	
			
			CASE
			   WHEN @MaterialCod0='ECVT30-372' THEN 'WEC3R0335QG(LOW)'
			    WHEN @PartNo='VET13252R71' THEN 'VET13252R7156G' --update 2024-08-14
				WHEN @PartNo='VET10252R71' THEN 'VET10252R7106G'
			    when @PartNo='WEC6R0155QG-L' then 'WEC6R0155QG-OT-L'
				when @LotNo IN ('VVPN113R036708','VVPN123R036727','VVPN113R036707','VVPN133R036716','VVPN173R036709',
				'VVPM153R036709','VVPM173R036723','VVPM153R036708','VVPM163R036737','VVPM153R036710','VVPM163R036738', 'VVP0223R036707') then 'VEP3R0367QG' --Mr.Trieu change for Partno
				when @PartNo='VET5R4505QA-WC' then 'VET5R4505QA-WCI(62)'  -- Mr.Trieu change for request Ms.Hoaiii
				when @PartNo='WEC9R0166QG-WC' then 'WEC9R0166QG-WC(130)'
				when @PartNo = 'WEC3R0106Q' then 'WEC3R0106QG'
				when @PartNo = 'WEC6R0105QA-L' then 'WEC6R0105QA-OT-L(L&G)'
				when @PartNo = 'VEC3R0387QG-JIANGHAI)' then 'VEC3R0387QG' --Mr.Trieu change PartNo JIANGHAI
				when @PartNo = 'WEC6R0155QG-WC' then 'WEC6R0155QG-WCI(90)'
				when @LotNo='VVPT213R033538' then 'WEC3R0335QG(LOW)'
				when @LotNo IN ('MVVPS306R015505',
                               'MVVPS306R015507',
                               'MVVPT016R015505',
                               'MVVPS286R015507',
                               'MVVPS306R015502',
                               'MVVPT016R015502',
                               'MVVPT016R015502',
                               'MVVPT016R015504',
                               'MVVPS286R015505',
                              'MVVPT016R015504',
                              'MVVPS306R015501',
                              'MVVPS306R015506',
                              'MVVPT016R015501',
                              'MVVPS286R015506',
                              'MVVPT016R015503'
                            )  then 'WEC6R0155QG-H'
				WHEN @LotNo in('VVQJ293R033545') then 'WEC3R0335QG'
				WHEN @LotNo in('MVVQJ279R033506','MVVQJ279R033501') then 'WEC9R0335QG-LG'
				WHEN @PartNo='WEC9R0335QG-L' then 'WEC9R0335QG-LG'
				WHEN @PartNo='VET13252R71-B092' then 'VET13252R7156G-B092'
				WHEN @PartNo = 'VEL08203R8306G' and @MaterialCod0='LIVT38-013' THEN 'VEL08203R8306G-XLC'
				WHEN @PartNo='WEC3R0256QG-D' THEN 'WEC3R0256QG'
				ELSE @PartNo
			END AS PartNo, 
			 --@PartNo   AS PartNo,
			@IsModule AS IsModule,
			isnull(MLI.StockAttrib1,'')StockAttrib1,
			dbo.fnGetWeekNumber(GETDATE()) AS DC,
			 COALESCE(NULLIF(CML.MarkingName, ''),SI.SIExtText07,'notsave') AS MarkingLetter
			, ISNULL(SPS.VinylBagQty, 0)  AS VinylBagQty  -- 2020.10.08 ??
			, ISNULL(SPS.InnerBoxQty, 0)  AS InnerBoxQty  -- 2020.10.08 ??
			, ISNULL(SPS.OutBoxQty, 0)   AS  OutBoxQty   -- 2020.10.08 ??
	
		   ,''  AS ThinkwareBarcode
		    --, CONVERT(CHAR(10), GetDate(), 121) AS Today
			,CASE
			when @LotNo ='VVPJ223R850610'  then null
			when @LotNo ='VVPJ223R850609'  then null
			when @LotNo ='VVPJ223R850608'  then null
			when @LotNo ='VVPJ223R850611'  then null
			when @LotNo ='VVPJ223R850620'  then null 
			when @LotNo ='VVPM223R850609'  then null 
			when @LotNo='VVPM233R850601' then null	
			when @LotNo='VVPN223R815701' then null
			when @LotNo='VVPN223R815703' then null
			when @LotNo='VVPN223R815702' then null
			when @PartNo='VEL08253R8506G' then null
			when @PartNo='VEL10403R8157G' then null
					ELSE CONVERT(CHAR(10), GetDate(), 121)
				END AS Today

			, MLI.LotAttr08 AS CustomerName
			, MLI.CreateUserID AS WorkerCode
			, @pProcessUserID WorkerName
			, MM.MaterialUnit


			-- Mr.Manh update 2025-03-26
			,CASE WHEN EXISTS (Select 1 from STB_PackingLabelPrintHist PLPH where PLPH.PackingID = MLI.PackingID and PLPH.PrintCount >= 1) THEN N'Da in' ELSE N'Chua in'
				END as PrintStatus
			
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = MLI.MaterialCode AND MLBI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
			LEFT OUTER JOIN STB_ModelBasicInfo MBI	 WITH(NOLOCK) 		                ON MLI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_PackingLabelSpec PLS WITH(NOLOCK) 			            ON MLI.LotID = PLS.LotID
			LEFT OUTER JOIN STB_SetInfo SI  WITH(NOLOCK) ON (SI.Barcode = MLI.LotID OR SI.Barcode = MLI.LotNo)
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode CML ON MLI.MarkingCode = CML.MarkingCode
			LEFT OUTER JOIN STB_PackingStandard SPS		 WITH(NOLOCK) 		     ON  SPS.MaterialTypeCode = MM.MaterialTypeCode And SUBSTRING(MM.MaterialName, CHARINDEX('(', MM.MaterialName, 0) + 1, 4) = SPS.Size	   -- 2020.10.08 ?? 
			
	WHERE
			MLI.LotNo = @LotNo
			
END

--select * from STB_ModelBasicInfo where ModelCode='ECVT30-357'

--SELECT * FROM STB_SetInfo WHERE Barcode = 'VJNO162R750603'

--SELECT * FROM STB_SetInfo WHERE Barcode = 'VVNO162R750603'

--UPDATE STB_SetInfo SET Barcode = 'VJNO162R750603' WHERE Barcode = 'VVNO162R750603'

--SELECT * FROM STB_MaterialLotInfo where packingid='PKPL0600141'

--SELECT * FROM LabelInfo



