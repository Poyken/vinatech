CREATE PROC [dbo].[usp_new_Tapping_VVT_get]
@pLOTNO NVARCHAR(50) = NULL,
@pLotNo2 NVARCHAR(50) = NULL,
@pLotNo3 NVARCHAR(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;
			
		declare @m1 varchar(10)='',
				@m2 varchar(10)='',
				@m3 varchar(10)='',
				@m4 varchar(10)='',
				@m5 varchar(10)=''


		select 
		@m1= replace(substring(ltrim(MAX(SI.SIExtText07)),1,5),'-','') ,
		@m2= replace(substring(ltrim(MAX(SI.SIExtText07)),6,45),'-','')		
		from STB_SetInfo SI with(nolock) 
		where Barcode = dbo.fn_VVT_getLastestBarCode(@pLOTNO)
		group by SI.SIExtText07

		
		select 
		@m3= replace(substring(ltrim(MAX(SI.SIExtText07)),1,5),'-','') ,
		@m4= replace(substring(ltrim(MAX(SI.SIExtText07)),6,45),'-','')	
		from STB_SetInfo SI with(nolock) 
		where Barcode = dbo.fn_VVT_getLastestBarCode(@pLotNo2)
		group by SI.SIExtText07

		select 
		@m5 = SI.SIExtText07
		from STB_SetInfo SI with(nolock) 
		where Barcode = dbo.fn_VVT_getLastestBarCode(@pLotNo3)
		group by SI.SIExtText07



		-- Mr.Manh UPDATE 2025-11-20 for QC & Production print Marking Label
		declare @pmark1 VARCHAR(20),
				 @pmark2 VARCHAR(20),
				 @pmark3 VARCHAR(20),
				 @pmark4 VARCHAR(20),
				 @pmark5 VARCHAR(20)


		set @pmark1 = case when len(@m1)>3 then @m1 else '' end
		set @pmark2 = case when len(@m2)>3 then '-' + @m2 else '' end
		set @pmark3 = case when len(@m3)>3 then '-' + @m3 else '' end
		set @pmark4 = case when len(@m4)>3 then '-' + @m4 else '' end
		set @pmark5 = case when len(@m5)>3 then '-' + @m5 else '' end
		
		declare @MarkingLetters varchar(50) =  @pmark1 + replace(@pmark2,@pmark1,'') 
												+ replace(replace(@pmark3,@pmark1,''),@pmark2,'')
												+ replace(replace(replace(@pmark4,@pmark1,''),@pmark2,''),@pmark3,'')
												+ replace(replace(replace(replace(@pmark5,@pmark1,''),@pmark2,''),@pmark3,''),@pmark4,'')
							
		SET @MarkingLetters =  replace(@MarkingLetters, ' ', '')					
									
		SET @MarkingLetters= replace(replace(@MarkingLetters, '--','-'), '--','-')

		SET @MarkingLetters = case when right(@MarkingLetters,1)='-' then substring(@MarkingLetters,1,len(@MarkingLetters)-1) else @MarkingLetters end

		SET @MarkingLetters =  replace(@MarkingLetters, '-', ' - ')
		-- END UPDATE

		;with dat as(
		SELECT top 1
				vbt.ID,
				vbt.CODEPRODUCTION,
				--mm.MaterialName as CODEPRODUCTION,
				vbt.FWAL,
				vbt.Vol,
				vbt.CODEERROR,
				'' as NAMEERROR,
				vbt.QTYERROR,
				vbt.LOTNO,
				vbt.MachineName,   ----
				vbt.ModelCode,     ----
				vbt.TYPESS,
				QTYLOTNO,
				@m1 mark1,
				@m2 mark2,
				@m3 mark3,
				@m4 mark4,
				@m5 mark5,
				@MarkingLetters AS MarkingLetters,
				1 AS LabelQty,
				'Report' AS CommandType,
				'' AS TypePrint,
				vbt.CreateDateTime,
				vbt.CreateUserID,
				vbt.ChangeDateTime,
				vbt.ChangeUserID,
			--(select isnull(QTYERROR,0)  from STB_VN_BENDING_TAPPING with(nolock) where lotno=vbt.lotno and NAMEERROR=N'')
				0  as	[RÁCH_VỎ],
				0  as	[XƯỚC_CHÂN],
				0  as	[TANCHA_BIẾN_SẮC],
				0  as	[BẸP_VỎ_NHÔM],
				0  as	[NGƯỢC_CỰC],
				0  as	[CONG_CHÂN],
				0  as	[DỊ_VẬT],
				0  as	[TRÀN_DỊCH],
				0  as	[BIẾN_SẮC_ĐÁY],
				0  as	[RÁCH_CAO_SU],
				0  as	[LỒI_ĐÁY],
				0  as	[BẸP_ĐÁY],
				0  as	[NG_MARKING],
				0  as	[THIẾU_SỐ_LƯỢNG],
				0  as	[NG_TAPE],
				0  as	[LỖI_KHÁC],
				0 as    [NG_ESR]

		FROM
			 STB_VN_BENDING_TAPPING  vbt  WITH(NOLOCK)
			 left outer join stb_setinfo  si  WITH(NOLOCK) on vbt.lotno = si.barcode
			 left outer join stb_materialmaster  mm   WITH(NOLOCK) on si.materialcode = mm.materialcode
		WHERE
			 LOTNO = @pLOTNO
		union all
			SELECT 
				100000000 as ID,
				'' as CODEPRODUCTION,
				'' as FWAL,
				'' as Vol,
				'' as CODEERROR,
				'' as NAMEERROR,
				0 as QTYERROR,
				@pLOTNO as LOTNO,
				'' as MachineName,   
				'' as ModelCode,     
				'Sorting' as TYPESS,
				null as QTYLOTNO,
				@m1 mark1,
				@m2 mark2,
				@m3 mark3,
				@m4 mark4,
				@m5 mark5,
				@MarkingLetters AS MarkingLetters,
				1 AS LabelQty,
				'Report' AS CommandType,
				'' AS TypePrint,
				getdate() as CreateDateTime,
				'' as CreateUserID,
				null as ChangeDateTime,
				null as ChangeUserID,
				0  as	[RÁCH_VỎ],
				0  as	[XƯỚC_CHÂN],
				0  as	[TANCHA_BIẾN_SẮC],
				0  as	[BẸP_VỎ_NHÔM],
				0  as	[NGƯỢC_CỰC],
				0  as	[CONG_CHÂN],
				0  as	[DỊ_VẬT],
				0  as	[TRÀN_DỊCH],
				0  as	[BIẾN_SẮC_ĐÁY],
				0  as	[RÁCH_CAO_SU],
				0  as	[LỒI_ĐÁY],
				0  as	[BẸP_ĐÁY],
				0  as	[NG_MARKING],
				0  as	[THIẾU_SỐ_LƯỢNG],
				0  as	[NG_TAPE],
				0  as	[LỖI_KHÁC],
				0 as    [NG_ESR]
			)
			select top 1 * from dat
END
