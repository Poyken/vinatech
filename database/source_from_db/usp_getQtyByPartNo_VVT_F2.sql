-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-24
-- Description:	Lấy ra số lượng cần in theo model
-- exec usp_getQtyByPartNo_VVT_F2 '','','VVPT282R740608'
-- =============================================
CREATE PROCEDURE [dbo].[usp_getQtyByPartNo_VVT_F2]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		
	SET NOCOUNT ON;

	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	DECLARE @ext_partno VARCHAR(50) = ''
	DECLARE @Barcode VARCHAR(20) = ISNULL(@pBarcode,'')
	DECLARE @PartNo VARCHAR(200) = '' 
	DECLARE @MaterialName VARCHAR(200) = '' 
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
	-- Lấy các barcode mới thay thế
	SELECT @LotNonew1 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @pBarcode;

	SELECT @LotNonew2 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @LotNonew1;

	SELECT @LotNonew3 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @LotNonew2;

	SELECT @LotNonew4 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @LotNonew3;

	SELECT @LotNonew5 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @LotNonew4;

	SELECT @LotNonew6 = NewBarcode
	FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	WHERE OldBarcode = @LotNonew5;

	-- Xác định barcode cuối cùng thực sự tồn tại
	SELECT @Barcode = Barcode
	FROM STB_SetInfo WITH(NOLOCK)
	WHERE Barcode IN (
		@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6
	);
	DECLARE @MaterialCod0 VARCHAR(200) = '' 


	-- Lấy MaterialName
	SELECT @MaterialName = MaterialName,@MaterialCod0=MaterialCode
	FROM STB_MaterialMaster
	WHERE MaterialCode = (
		SELECT MaterialCode 
		FROM STB_SetInfo WITH(NOLOCK)
		WHERE Barcode = @Barcode
	);

	-- Cắt chuỗi đúng rule
  SET @PartNo = case 
    -- Thêm điều kiện này nếu bạn muốn tách rõ ràng HY-CAP và WEC/VEC
    when CHARINDEX('WEC', @MaterialName) > 0 OR CHARINDEX('VEC', @MaterialName) > 0 then 
        RTRIM(LTRIM(SUBSTRING(
            @MaterialName, 
            CHARINDEX('WEC', @MaterialName),  -- Bắt đầu từ 'WEC'
            11                                -- Lấy 11 ký tự
        )))

    when substring(@MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(@MaterialName,1,11))) 
    when substring(@MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(@MaterialName,1,14))) 
    when substring(@MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(@MaterialName, CHARINDEX(' ', @MaterialName)+1, 12))))
    else (RTRIM(LTRIM(SUBSTRING(@MaterialName, CHARINDEX(' ', @MaterialName), 12)))) 
end
	
		 -- Lấy đuôi của PARTNO , trên là Module , mấy dòng cuối là CEll
	SET	 @ext_partno = 		 
					(  
					case WHEN @Barcode like @VV_perModule and CHARINDEX('-LG (1030)', @MaterialName) > 0 then '-LG'
					   WHEN CHARINDEX('-I-L', @MaterialName) > 0 THEN '-I-L' 
					 --WHEN @LotNo IN (
						--	'VVPK033R010707',
						--	'VVPK033R010708',
						--	'VVPK033R010709',
						--	'VVPK043R010703',
						--	'VVPK043R010707'
						-- ) and CHARINDEX('-L', MM.MaterialName) > 0 THEN '-B036'					--DinhManh update 2025-04-16 following Mr.Long request
						WHEN @Barcode IN (
							'MVVPO206R015501',
							'MVVPO206R015502',
							'MVVPP166R010501'
						) and CHARINDEX('-OT-L',@MaterialName) > 0 then '-OT-L(L&G)' -- 2025-06-20
					 WHEN CHARINDEX('-L', @MaterialName) > 0 THEN '-L' 
					 --WHEN (@LotNo='VVPN163R850605') THEN '-B034 (0825)'
					 WHEN (@Barcode = 'VVOO133R015612') THEN '-L' --DinhManh update 2025-04-14 following Ms.Phuong request
					 WHEN (@Barcode = 'VVPM303R033551') THEN '-C035'   --DinhManh update 2025-05-07 following Ms.Phuong request
					
					 WHEN @Barcode like @VV_perModule and CHARINDEX('-3PLA', @MaterialName) > 0 then '-3PLA'
						WHEN @Barcode like @VV_perModule and CHARINDEX('-WC', @MaterialName) > 0 and @MaterialCod0 = 'EDVTMD-230' then '-WCI(52)'


						WHEN @Barcode like @VV_perModule and CHARINDEX('-B030R', @MaterialName) > 0 then '-B034'
						 WHEN @Barcode in ('VVOT133R850606') and CHARINDEX('-B030R', @MaterialName) > 0 then '-B034'
						 	 WHEN @Barcode in (
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
							)  then '-B050'
							WHEN @Barcode in (
							'MVVPL126R015501',
							'MVVPL126R015502',
							'MVVPL126R015503',
							'MVVPL126R015504',
							'MVVPL126R015505',
							'MVVPL126R015506'
							) and CHARINDEX('-H', @MaterialName) > 0 then '-H(L&G)'
						  WHEN @Barcode in ('VVOT153R850605','VVOT153R850602') then '-B030R'
					 -- WHEN @LotNo like @VV_perModule and CHARINDEX('-OL', MM.MaterialName) > 0 then '-OL'
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-OL', @MaterialName) > 0 then '-OL-C68M42'
					    WHEN @Barcode like @VV_perModule and CHARINDEX('-O-T', @MaterialName) > 0 then '-O-T'
					    WHEN @Barcode like @VV_perModule and CHARINDEX('-OT', @MaterialName) > 0 then '-O-T'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-O', @MaterialName) > 0 then '-O'
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-IL030', @MaterialName) > 0 then '-IL030'
					     WHEN @Barcode like @VV_perModule and CHARINDEX('-IC030', @MaterialName) > 0 then '-IC030'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-ILB', @MaterialName) > 0 then '-ILB'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-IL-ET', @MaterialName) > 0 then '-IL-ET'
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-ILA', @MaterialName) > 0 then '-ILA'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-IL', @MaterialName) > 0 then '-IL(9MM)'
					 
					    WHEN @Barcode like @VV_perModule and CHARINDEX('-I-P', @MaterialName) > 0 then '-I-P'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-I-T', @MaterialName) > 0 then '-I-T'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-I', @MaterialName) > 0 then '-I'

					    WHEN @Barcode like @VV_perModule and CHARINDEX('-HL-104M40', @MaterialName) > 0 then '-HL-104M40'
						 WHEN @Barcode like @VV_perModule and CHARINDEX('-HL', @MaterialName) > 0 then '-HL'


						 WHEN @Barcode in (
							'MVVPM256R015508'
							)  then '-H'   -- 2025-05-05
						
						   WHEN @Barcode like @VV_perModule and CHARINDEX('-H(L&G)', @MaterialName) > 0 then '-H(L&G)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-H', @MaterialName) > 0 then '-H'

					   WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(67)', @MaterialName) > 0 then '-WCI(67MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(80)', @MaterialName) > 0 then '-WCI(80MM)'		
					  
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(40mm)', @MaterialName) > 0 then '-WC(40MM)'
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(40)', @MaterialName) > 0 then '-WC(40)'

					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(100)', @MaterialName) > 0 then '-WC(100MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(60mm)', @MaterialName) > 0 then '-WC(60MM)'	

						WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(35mm)', @MaterialName) > 0 then '-WC(35MM)'

					   WHEN @Barcode like @VV_perModule and CHARINDEX('-WC(50mm)', @MaterialName) > 0 then '-WC(50MM)'					   
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WC (20mm)', @MaterialName) > 0 then '-WC(20MM)'

					 WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(50mm)', @MaterialName) > 0 then '-WCI(50MM)'	
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(25mm)', @MaterialName) > 0 then '-WCI(25MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(35mm)', @MaterialName) > 0 then '-WCI(35MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(40mm)', @MaterialName) > 0 then '-WCI(40MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(67mm)', @MaterialName) > 0 then '-WCI(67MM)'
					   WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(62mm)', @MaterialName) > 0 then '-WCI(62MM)'
					  WHEN @Barcode like @VV_perModule and CHARINDEX('HY-CAP VEM12R0126QG', @MaterialName) > 0 then 'G'
					  	WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(17mm)', @MaterialName) > 0 then '-WCI(17MM)' --Mr.Tung on 2022-01-12
						WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(35)(3)', @MaterialName) > 0 then '-WCI(35)(3)' --Duy Add
						WHEN @Barcode like @VV_perModule and CHARINDEX('-WCI(50)(2)', @MaterialName) > 0 then '-WCI(50)(2)' --Duy Add
					     WHEN @Barcode like @VV_perModule and CHARINDEX('-WC', @MaterialName) > 0 then '-WC'
						 
						 WHEN @Barcode like @VE_per and CHARINDEX('AL-Cap', @MaterialName) > 0 then 'Polymer'
						
							  
					  -- Mr.Tung add on 2023-Feb-13 for TU DONG LAY DUOI TRONG TEN HANG của hàng CELL line  VVOT133R850606
					WHEN CHARINDEX('-', @MaterialName,12) >= 12 
					THEN  substring(	@MaterialName,
										CHARINDEX('-', @MaterialName,12), 
										(case when CHARINDEX(' ', @MaterialName,12)>CHARINDEX('-', @MaterialName,12) 
											  then  CHARINDEX(' ', @MaterialName,12)-CHARINDEX('-', @MaterialName,12) 
											  else (case when CHARINDEX('(', @MaterialName,12)>CHARINDEX('-', @MaterialName,12) 
													then  CHARINDEX('(', @MaterialName,12)-CHARINDEX('-', @MaterialName,12) 
													else len(@MaterialName) - CHARINDEX('-', @MaterialName,12)+1 
													end) 
										end) 
								   )
					-- Mr.Tung add on 2023-Feb-13 for TU DONG LAY DUOI TRONG TEN HANG của hàng CELL line
								   	
					  ELSE '' END 
					)
		
		-- FIX: Replaced undeclared @LotNo with @Barcode
		if @Barcode  not in ( --'VVNS213R012602',--'VVNM243R850608',
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

	-- Trả về kết quả theo PartNo đã cắt
	
	SELECT
	   
		T3.PartNo,
		T3.Qty AS LotQty,
		convert(varchar(10),T3.Qty) AS Seq
	FROM STB_SavePackingQty_VVT_F2 T3 WITH(NOLOCK)
	WHERE T3.PartNo=@pBarcode
		and isUsed = 1
   
END


