-- =============================================
-- Author : Mr.Tung
-- Group : 공통
-- Browsable : true
-- Create date : 2021-05-19
-- Description : 패킹수량 팝업
-- Modified :

----usp_Vietnam_PackingQtySizeTape_popup '','','VVOP123R050503'


-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackingQtySizeTape_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Barcode VARCHAR(20) = isnull(@pBarcode,'2'),
			@ProdSize VARCHAR(10),
			@phaRAT VARCHAR(10),
			@BENDING INT=0,
			@matname varchar(200)=''

    

			
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pBarcode; 
	
	select @LotNonew2 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1 ;

	select @LotNonew3 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2 ;

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 ;

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 ;

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 ;
		
	select @Barcode = Barcode 
	from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);


	declare @count INT=0;
	SELECT @count=count(*) FROM STB_SetInfo with(nolock) WHERE Barcode = @Barcode

	if(@pBarcode like 'VJ%' and @count=0)
		set @Barcode=stuff(@pBarcode,1,2,'VV')


	SELECT @ProdSize = 
		case when modelname not like '%'+ RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))+'%'
		then 'M'+RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
		else RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
		end,
	@phaRAT = MBIExtText05+'F',
	@BENDING = CASE WHEN ModelName LIKE '%-B%' THEN 1 else 0 END,
	@matname = ModelName
	  FROM STB_ModelBasicInfo with(nolock)
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock) WHERE Barcode = @Barcode)


		;with tieuchuan as ( 
		SELECT ''  as model  , '' as qty ,N'TÚI_BÓNG' as type UNION  SELECT ''   , '' ,N'Thùng_Trong' UNION SELECT '' , '' , N'THÙNG_NGOÀI' UNION
		SELECT '0813'   , '1500',N'TÚI_BÓNG' UNION  SELECT '0813'   , '1500' ,N'Thùng_Trong' UNION SELECT '0813' , '4500' , N'THÙNG_NGOÀI' UNION
		SELECT '0813'   , '500' ,N'TÚI_BÓNG' UNION  SELECT '0813'   , '4000' ,N'Thùng_Trong' UNION SELECT '0813' , '8000' , N'THÙNG_NGOÀI' UNION
		SELECT '0612'   , '500' ,N'TÚI_BÓNG' UNION  SELECT '0612'   , '4000' ,N'Thùng_Trong' UNION SELECT '0612' , '8000' , N'THÙNG_NGOÀI' UNION
		SELECT '0816'   , '500' ,N'TÚI_BÓNG' UNION  SELECT '0816'   , '3000' ,N'Thùng_Trong' UNION SELECT '0816' , '6000' , N'THÙNG_NGOÀI' UNION
		SELECT '0820'   , '1500',N'TÚI_BÓNG' UNION  SELECT '0820'   , '1500' ,N'Thùng_Trong' UNION SELECT '0820' , '4500' , N'THÙNG_NGOÀI' UNION
		SELECT '0820'   , '500' ,N'TÚI_BÓNG' UNION  SELECT '0820'   , '3000' ,N'Thùng_Trong' UNION SELECT '0820' , '6000' , N'THÙNG_NGOÀI' UNION
		SELECT '0825 (3.8V-50F)'   , '40' ,N'TÚI_BÓNG' UNION  SELECT '0825 (3.8V-50F)'   , '1440' ,N'Thùng_Trong' UNION SELECT '0825 (3.8V-50F)' , '1440' , N'THÙNG_NGOÀI' UNION
		SELECT '0825'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '0825'   , '1500' ,N'Thùng_Trong' UNION SELECT '0825' , '4500' , N'THÙNG_NGOÀI' UNION
		SELECT '0830'   , '1500' ,N'TÚI_BÓNG' UNION  SELECT '0830'   , '1500' ,N'Thùng_Trong' UNION SELECT '0830' , '4500' , N'THÙNG_NGOÀI' UNION
		SELECT '0830'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '0830'   , '2000' ,N'Thùng_Trong' UNION SELECT '0830' , '4000' , N'THÙNG_NGOÀI' UNION
		SELECT '1020'   , '1000' ,N'TÚI_BÓNG' UNION  SELECT '1020'   , '1000' ,N'Thùng_Trong' UNION SELECT '1020' , '3000' , N'THÙNG_NGOÀI' UNION
		SELECT '1020'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1020'   , '2000' ,N'Thùng_Trong' UNION SELECT '1020' , '4000' , N'THÙNG_NGOÀI' UNION
		SELECT '1025'   , '1000' ,N'TÚI_BÓNG' UNION  SELECT '1025'   , '1000' ,N'Thùng_Trong' UNION SELECT '1025' , '3000' , N'THÙNG_NGOÀI' UNION
		SELECT '1025'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1025'   , '1500' ,N'Thùng_Trong' UNION SELECT '1025' , '3000' , N'THÙNG_NGOÀI' UNION
		SELECT '1030 '   , '1000' ,N'TÚI_BÓNG' UNION  SELECT '1030 '   , '1000' ,N'Thùng_Trong' UNION SELECT '1030 ' , '3000' , N'THÙNG_NGOÀI' UNION
		SELECT '1030'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1030'   , '1500' ,N'Thùng_Trong' UNION SELECT '1030' , '3000' , N'THÙNG_NGOÀI' UNION
		SELECT '1030(2.7V 10F Bending)'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1030(2.7V 10F Bending)'   , '250' ,N'Thùng_Trong' UNION SELECT '1030(2.7V 10F Bending)' , '2250' , N'THÙNG_NGOÀI' UNION
		SELECT '1030(태양유전 向)'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1030(태양유전 向)'   , '1000' ,N'Thùng_Trong' UNION SELECT '1030(태양유전 向)' , '2000' , N'THÙNG_NGOÀI' UNION
		SELECT '1320'   , '200' ,N'TÚI_BÓNG' UNION  SELECT '1320'   , '1200' ,N'Thùng_Trong' UNION SELECT '1320' , '2400' , N'THÙNG_NGOÀI' UNION
		SELECT '1320-B125 (3.0 V-10F)'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '1320-B125 (3.0 V-10F)'   , '1440' ,N'Thùng_Trong' UNION SELECT '1320-B125 (3.0 V-10F)' , '1440' , N'THÙNG_NGOÀI' UNION
		SELECT '1325 (3.0V 15F)'   , '50' ,N'TÚI_BÓNG' UNION  SELECT '1325 (3.0V 15F)'   , '1000' ,N'Thùng_Trong' UNION SELECT '1325 (3.0V 15F)' , '1000' , N'THÙNG_NGOÀI' UNION
		SELECT '1325'   , '200' ,N'TÚI_BÓNG' UNION  --SELECT '1325'   , '1200' ,N'Thùng_Trong' UNION SELECT '1325' , '2400' , N'THÙNG_NGOÀI' UNION
		SELECT '1325'   , '650' ,N'TÚI_BÓNG' UNION  SELECT '1325'   , '650' ,N'Thùng_Trong' UNION SELECT '1325' , '1950' , N'THÙNG_NGOÀI' UNION
		SELECT '1346'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1346'   , '600' ,N'Thùng_Trong' UNION SELECT '1346' , '1200' , N'THÙNG_NGOÀI' UNION
		SELECT '1625 (2.3V 50F)'   , '260' ,N'TÚI_BÓNG' UNION  SELECT '1625 (2.3V 50F)'   , '260' ,N'Thùng_Trong' UNION SELECT '1625 (2.3V 50F)' , '780' , N'THÙNG_NGOÀI' UNION
		SELECT '1625 (3.0V 25F)'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1625 (3.0V 25F)'   , '700' ,N'Thùng_Trong' UNION SELECT '1625 (3.0V 25F)' , '1400' , N'THÙNG_NGOÀI' UNION
		SELECT '1625 (3.0V 25F)'   , '500' ,N'TÚI_BÓNG' UNION  SELECT '1625 (3.0V 25F)'   , '500' ,N'Thùng_Trong' UNION SELECT '1625 (3.0V 25F)' , '1000' , N'THÙNG_NGOÀI' UNION
		SELECT '1625'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1625'   , '700' ,N'Thùng_Trong' UNION SELECT '1625' , '1400' , N'THÙNG_NGOÀI' UNION
		SELECT '1630'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1630'   , '600' ,N'Thùng_Trong' UNION SELECT '1630' , '1200' , N'THÙNG_NGOÀI' UNION
		SELECT '1635'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1635'   , '600' ,N'Thùng_Trong' UNION SELECT '1635' , '1200' , N'THÙNG_NGOÀI' UNION
		SELECT '1830'   , '100' ,N'TÚI_BÓNG' UNION  SELECT '1830'   , '500' ,N'Thùng_Trong' UNION SELECT '1830' , '1000' , N'THÙNG_NGOÀI' UNION
		SELECT '1840'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1840'   , '250' ,N'Thùng_Trong' UNION SELECT '1840' , '500' , N'THÙNG_NGOÀI' UNION
		SELECT '1840(2.7V 50F)'   , '32' ,N'TÚI_BÓNG' UNION  SELECT '1840(2.7V 50F)'   , '640' ,N'Thùng_Trong' UNION SELECT '1840(2.7V 50F)' , '640' , N'THÙNG_NGOÀI' UNION
		SELECT '1840-B135R'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1840-B135R'   , '250' ,N'Thùng_Trong' UNION SELECT '1840-B135R' , '750' , N'THÙNG_NGOÀI' UNION
		SELECT '1859 (3V 100F)'   , '190' ,N'TÚI_BÓNG' UNION  SELECT '1859 (3V 100F)'   , '190' ,N'Thùng_Trong' UNION SELECT '1859 (3V 100F)' , '570' , N'THÙNG_NGOÀI' UNION
		SELECT '1859'   , '250' ,N'TÚI_BÓNG' UNION  SELECT '1859'   , '250' ,N'Thùng_Trong' UNION SELECT '1859' , '500' , N'THÙNG_NGOÀI' UNION
		SELECT '2245'   , '140' ,N'TÚI_BÓNG' UNION  SELECT '2245'   , '140' ,N'Thùng_Trong' UNION SELECT '2245' , '420' , N'THÙNG_NGOÀI' UNION
		SELECT '3562'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '3562'   , '60' ,N'Thùng_Trong' UNION SELECT '3562' , '120' , N'THÙNG_NGOÀI' UNION
		SELECT '3570'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '3570'   , '60' ,N'Thùng_Trong' UNION SELECT '3570' , '120' , N'THÙNG_NGOÀI' UNION
		SELECT '3582'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '3582'   , '60' ,N'Thùng_Trong' UNION SELECT '3582' , '120' , N'THÙNG_NGOÀI' UNION
		SELECT '3060'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '3060'   , '60' ,N'Thùng_Trong' UNION SELECT '3060' , '120' , N'THÙNG_NGOÀI' UNION
		--SELECT '3562,3570, 3582, 3060'   , '60' ,N'TÚI_BÓNG' UNION  SELECT '3562,3570, 3582, 3060'   , '60' ,N'Thùng_Trong' UNION SELECT '3562,3570, 3582, 3060' , '120' , N'THÙNG_NGOÀI' UNION
		--SELECT 'M'   , '' ,N'TÚI_BÓNG' UNION  SELECT 'M'   , '' ,N'Thùng_Trong' UNION SELECT 'M' , '' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0813'   , '200' ,N'TÚI_BÓNG' UNION  SELECT 'M0813'   , '1600' ,N'Thùng_Trong' UNION SELECT 'M0813' , '3200' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0816'   , '200' ,N'TÚI_BÓNG' UNION  SELECT 'M0816'   , '1600' ,N'Thùng_Trong' UNION SELECT 'M0816' , '3200' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0820 (3직렬)'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M0820 (3직렬)'   , '800' ,N'Thùng_Trong' UNION SELECT 'M0820 (3직렬)' , '1600' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0820'   , '200' ,N'TÚI_BÓNG' UNION  SELECT 'M0820'   , '1200' ,N'Thùng_Trong' UNION SELECT 'M0820' , '2400' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0820(3S)'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M0820(3S)'   , '800' ,N'Thùng_Trong' UNION SELECT 'M0820(3S)' , '1600' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0825'   , '200' ,N'TÚI_BÓNG' UNION  SELECT 'M0825'   , '1200' ,N'Thùng_Trong' UNION SELECT 'M0825' , '2400' , N'THÙNG_NGOÀI' UNION
		SELECT 'M0830 (5.4V 3.5F)'   , '900' ,N'TÚI_BÓNG' UNION  SELECT 'M0830 (5.4V 3.5F)'   , '900' ,N'Thùng_Trong' UNION SELECT 'M0830 (5.4V 3.5F)' , '1800' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1020'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M1020'   , '800' ,N'Thùng_Trong' UNION SELECT 'M1020' , '1600' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1025 (5V 3F)'   , '560' ,N'TÚI_BÓNG' UNION  SELECT 'M1025 (5V 3F)'   , '560' ,N'Thùng_Trong' UNION SELECT 'M1025 (5V 3F)' , '1680' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1025'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M1025'   , '700' ,N'Thùng_Trong' UNION SELECT 'M1025' , '1400' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1030 (3직렬) (7.5~3.3F)'   , '120' ,N'TÚI_BÓNG' UNION  SELECT 'M1030 (3직렬) (7.5~3.3F)'   , '120' ,N'Thùng_Trong' UNION SELECT 'M1030 (3직렬) (7.5~3.3F)' , '240' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1030'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M1030'   , '700' ,N'Thùng_Trong' UNION SELECT 'M1030' , '1400' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1030-W'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M1030-W'   , '600' ,N'Thùng_Trong' UNION SELECT 'M1030-W' , '1200' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1325'   , '50' ,N'TÚI_BÓNG' UNION  SELECT 'M1325'   , '400' ,N'Thùng_Trong' UNION SELECT 'M1325' , '800' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1625 (5.4V 12.5F)'   , '100' ,N'TÚI_BÓNG' UNION  SELECT 'M1625 (5.4V 12.5F)'   , '300' ,N'Thùng_Trong' UNION SELECT 'M1625 (5.4V 12.5F)' , '600' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1840 (4직렬) (12V-12.5F)'   , '50' ,N'TÚI_BÓNG' UNION  SELECT 'M1840 (4직렬) (12V-12.5F)'   , '50' ,N'Thùng_Trong' UNION SELECT 'M1840 (4직렬) (12V-12.5F)' , '100' , N'THÙNG_NGOÀI' UNION
		SELECT 'M1840 (5.4V 25F)'   , '125' ,N'TÚI_BÓNG' UNION  SELECT 'M1840 (5.4V 25F)'   , '125' ,N'Thùng_Trong' UNION SELECT 'M1840 (5.4V 25F)' , '250' , N'THÙNG_NGOÀI' UNION

		SELECT '0813'   , '3000' ,N'THÙNG_NGOÀI' UNION  
		SELECT '0820'   , '3000' ,N'THÙNG_NGOÀI' UNION  
		SELECT '0830'   , '3000' ,N'THÙNG_NGOÀI' UNION  
		SELECT '1325'   , '1300' ,N'THÙNG_NGOÀI' 
		)
		, lastdata as (
		select distinct replace(model,'M','Mođun ') model_size,qty LotQty,type 
		from tieuchuan 
	--	CROSS apply(
	--		select 
	--			case when modelname not like '%'+ RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))+'%'
	--then 'Mođun%'+RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
	--else RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
	--end AS ProdSize
	--		from STB_ModelBasicInfo with(nolock)
	--		where 
	--		tieuchuan.model like ('%'+RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))+'%')
	--		--and ModelName like ('%('+RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))+')%')
	--		and (/*tieuchuan.model like '%'+MBIExtText04+'V%' or */ tieuchuan.model like '%'+MBIExtText05+'F%')
	--	) mbi
		where type in (N'THÙNG_NGOÀI',N'Thùng_Trong')
		--and model like '%'+case when mbi.ProdSize is null then '%' else mbi.ProdSize end +'%'
		and model like '%'+@ProdSize+'%'
		and model like case when model like '%F%' then  '%'+@phaRAT+'%' else '%' end
		AND (CASE WHEN model LIKE 'M%' THEN 1 ELSE 0 END) = (CASE WHEN @ProdSize LIKE 'M%' THEN 1 ELSE 0 END)
		AND (CASE WHEN model LIKE '%-B%' OR model LIKE '%Bending%' THEN 1 ELSE 0 END) = @BENDING
		--and (case when @matname like '%WEC3R0335QG%' and qty not in (3000,6000) then 0 
		--	      when @matname like '%WEC3R0105QG%' and qty not in (4000,8000) then 0 
		--		  when @matname like '%WEC3R0106QG%' and qty not in (1000,3000) then 0 
		--		else 1 end)=1
		)
		, lastdata1 as (
		select distinct replace(model,'M','Mođun ') model_size,qty LotQty,type 
		from tieuchuan 
		where type in (N'THÙNG_NGOÀI',N'Thùng_Trong')
		and model like '%'+@ProdSize+'%'
		AND (CASE WHEN model LIKE 'M%' THEN 1 ELSE 0 END) = (CASE WHEN @ProdSize LIKE 'M%' THEN 1 ELSE 0 END)
		and (case when @ProdSize in ('0813','0820') and qty  in (3000) and type=N'THÙNG_NGOÀI' then 1
				  when @matname like '%WEC3R0335QG%' and qty  in (3000,6000) then 0 
			      when @matname like '%WEC3R0105QG%' and qty  in (4000,8000) then 0 
				  when @matname like '%WEC3R0106QG%' and (qty not in (1000,3000) or model like '%(%') then 0 
				else 1 end)=1
		--AND (CASE WHEN model LIKE '%-B%' OR model LIKE '%Bending%' THEN 1 ELSE 0 END) = @BENDING
		)
		select convert(varchar(10),LotQty) AS Seq,model_size,LotQty,type
		from lastdata
		UNION ALL
		select convert(varchar(10),LotQty) AS Seq,model_size,LotQty,type
		from lastdata1 
		WHERE (SELECT COUNT(*) FROM lastdata)=0
		--AND (CASE WHEN lastdata1.model_size LIKE '%Mođun%' THEN 1 ELSE 0 END) = (CASE WHEN @ProdSize LIKE '%Mođun%' THEN 1 ELSE 0 END)
		order by model_size,type desc,LotQty asc
end