-- =================================================================================
-- Author: vanduc
-- Date: 2026-06-15
-- Description: Fix multi-barcode save truncation error for Model 3510 Electrode Input.
--              Extends STB_InputMaterialHistory.RawMaterialBarcode column size to NVARCHAR(1000)
--              and updates usp_Vietnam_RawMaterialInputHist_uid to allow NVARCHAR(1000).
-- Safety Warning: Wrapped in a Transaction. Verify changes and change ROLLBACK to COMMIT.
-- =================================================================================

USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY

    -- 1. Alter column length of STB_InputMaterialHistory.RawMaterialBarcode to NVARCHAR(1000)
    PRINT 'Altering STB_InputMaterialHistory.RawMaterialBarcode column size...';
    ALTER TABLE STB_InputMaterialHistory
    ALTER COLUMN RawMaterialBarcode NVARCHAR(1000) NULL;

    -- 2. Alter Stored Procedure [usp_Vietnam_RawMaterialInputHist_uid]
    PRINT 'Altering Stored Procedure [usp_Vietnam_RawMaterialInputHist_uid]...';
    
    -- We will execute the ALTER PROCEDURE command dynamically or directly
    -- To keep it clean, we can execute the ALTER statement directly.
    EXEC('
    ALTER PROCEDURE [dbo].[usp_Vietnam_RawMaterialInputHist_uid]
        @pProcessUserID VARCHAR(20), 
        @pProcessLanguage VARCHAR(20), 
        @pRawMaterialInputHistNo VARCHAR(20)= NULL, 
        @pBarcode VARCHAR(20)			    = NULL ,	 
        @pProductGroupCode VARCHAR(20)	    = NULL , 
        @pRawMaterialBarcode NVARCHAR(1000)   = NULL, 
        @pLotID_Warehouse_Created VARCHAR(20)	    = NULL ,  
        @pCreateDateTime DATETIME		    = NULL , 
        @pChangeDateTime DATETIME		    = NULL  ,
        @pMaterialCode VARCHAR(50)	    = NULL 
    AS
    BEGIN
        Declare @err nvarchar(2000)=''''; 

        declare @validDate varchar(20);
        declare @MaterialCode varchar(50)=''''
        Declare @count int=0; 
        DECLARE @RawMaterialBarcode NVARCHAR(1000) =  @pRawMaterialBarcode

        DECLARE @LotMaterialBarcode NVARCHAR(1000) =  @pRawMaterialBarcode	
        DECLARE @BarcodeInsert NVARCHAR(1000) =  @pBarcode 

        declare @ChildMaterialCode varchar(50)=@pMaterialCode 

        DECLARE @LotNonew1 VARCHAR(20) = ''''
        DECLARE @LotNonew2 VARCHAR(20) = ''''
        DECLARE @LotNonew3 VARCHAR(20) = ''''
        DECLARE @LotNonew4 VARCHAR(20) = ''''
        DECLARE @LotNonew5 VARCHAR(20) = ''''
        DECLARE @LotNonew6 VARCHAR(20) = ''''
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
            
        declare @bangcode varchar(30)= @pBarcode;
        DECLARE @checkWorkCenterCode VARCHAR(10) = NULL
        
        select @pBarcode = Barcode , @MaterialCode=SI.MaterialCode, @checkWorkCenterCode = DPP.WorkCenterCode
        from STB_SetInfo SI  WITH(NOLOCK) 
        LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON SI.DayPlanNo = DPP.DayPlanNo
        where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);

        IF @checkWorkCenterCode NOT IN (''VVT_F4'')
        BEGIN

        declare @check varchar(10)
        if(@MaterialCode in (''EDVTMD-082'')
        and @pRawMaterialBarcode  in (''0000000000'')
        and @pProductGroupCode in ( ''SLEEVE'',''MODULESLEEVE'' )
        )
        begin
            set @check =''a''
        end 

        if(
        (
        @pBarcode not in (''VVPL072R7106051'',''VVNP313R015602'',''MVVOS236R035501'',''VVPS283R010704'',''VE241102-001'',''VE250210-005'',''VE250221-004'',''VVPU223R825703'',
        ''VE250114-008'',
        ''VE250304-006'',
        ''VE250205-007''
        ) 
        or @bangcode not in (''VVPL072R7106051'',''VVNP313R015602'',''MVVOS236R035501'',''VVPS283R010704'',''VE241102-001'',''VE250210-005'',''VE250221-004'',
        ''VE250114-008'',
        ''VE250304-006'',
        ''VE250205-007''
        )
        )
        and @check is null
        ) 
        BEGIN
            set @pRawMaterialBarcode = ltrim(rtrim(isnull(@pRawMaterialBarcode,''''))); 
            set @pLotID_Warehouse_Created =ltrim(rtrim( isnull(@pLotID_Warehouse_Created,'''')));

            IF CHARINDEX('';'', @pRawMaterialBarcode) > 0
            BEGIN
                DECLARE @TempHoldBarcodes NVARCHAR(1000) = @pRawMaterialBarcode
                DECLARE @SingleHoldBarcode NVARCHAR(100)
                DECLARE @PosHold INT

                WHILE LEN(@TempHoldBarcodes) > 0
                BEGIN
                    SET @PosHold = CHARINDEX('';'', @TempHoldBarcodes)
                    IF @PosHold > 0
                    BEGIN
                        SET @SingleHoldBarcode = LTRIM(RTRIM(SUBSTRING(@TempHoldBarcodes, 1, @PosHold - 1)))
                        SET @TempHoldBarcodes = SUBSTRING(@TempHoldBarcodes, @PosHold + 1, LEN(@TempHoldBarcodes) - @PosHold)
                    END
                    ELSE
                    BEGIN
                        SET @SingleHoldBarcode = LTRIM(RTRIM(@TempHoldBarcodes))
                        SET @TempHoldBarcodes = ''''
                    END

                    IF @SingleHoldBarcode <> ''''
                    BEGIN
                        EXEC usp_VVT_checkHOLD_Material @lotid = @SingleHoldBarcode
                    END
                END
            END
            ELSE
            BEGIN
                EXEC usp_VVT_checkHOLD_Material @lotid = @pRawMaterialBarcode
            END
            
            EXEC usp_VVT_checkHOLD_Material @lotid = @pLotID_Warehouse_Created

            DECLARE @IsConcat INT = 0
            IF CHARINDEX('';'', @pRawMaterialBarcode) > 0
                SET @IsConcat = 1

            IF @IsConcat = 1
            BEGIN
                DECLARE @TempCountBarcodes NVARCHAR(1000) = @pRawMaterialBarcode
                DECLARE @SingleCountBarcode NVARCHAR(100)
                DECLARE @PosCount INT
                SET @count = 0

                WHILE LEN(@TempCountBarcodes) > 0
                BEGIN
                    SET @PosCount = CHARINDEX('';'', @TempCountBarcodes)
                    IF @PosCount > 0
                    BEGIN
                        SET @SingleCountBarcode = LTRIM(RTRIM(SUBSTRING(@TempCountBarcodes, 1, @PosCount - 1)))
                        SET @TempCountBarcodes = SUBSTRING(@TempCountBarcodes, @PosCount + 1, LEN(@TempCountBarcodes) - @PosCount)
                    END
                    ELSE
                    BEGIN
                        SET @SingleCountBarcode = LTRIM(RTRIM(@TempCountBarcodes))
                        SET @TempCountBarcodes = ''''
                    END

                    IF @SingleCountBarcode <> ''''
                    BEGIN
                        DECLARE @c1 INT = 0
                        SELECT @c1 = COUNT(*) FROM stb_materialdoclotinfo WHERE lotid = @SingleCountBarcode
                        IF @c1 < 1 AND (@SingleCountBarcode LIKE ''%SP%'' OR @SingleCountBarcode LIKE ''%SL%'' OR @SingleCountBarcode LIKE ''%SM%'')
                        BEGIN
                            SELECT @c1 = COUNT(*) FROM STB_MaterialLotInfo WHERE lotid = @SingleCountBarcode
                        END
                        SET @count = @count + @c1
                    END
                END
            END
            ELSE
            BEGIN
                SELECT @count = COUNT(*) FROM stb_materialdoclotinfo
                WHERE lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
                
                IF (@count < 1 AND (@RawMaterialBarcode LIKE ''%SP%'' OR @RawMaterialBarcode LIKE ''%SL%'' OR @RawMaterialBarcode LIKE ''%SM%''))
                BEGIN
                    SELECT @count = COUNT(*) FROM STB_MaterialLotInfo
                    WHERE lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
                END
            END
            
            if(@count>0) begin   
                declare @OpenExpired bit = 0 
                ;with data1 as (
                    select LotID,max(createdatetime) as createdatetime
                    from stb_vvt_OpenExpiredMaterial  with(nolock) 
                    where (LotID=@pRawMaterialBarcode)
                    group by lotid
                )
                select top 1 @OpenExpired = voem.OpenExpired 
                from stb_vvt_OpenExpiredMaterial voem with(nolock) 
                join data1 on voem.lotid = data1.lotid and voem.createdatetime = data1.createdatetime

                declare @mmmaterialcode varchar(30)='''';
                select top 1  @validDate=isnull(LotAttr10,''2010-01-01''),@mmmaterialcode=isnull(MaterialCode,''''),@RawMaterialBarcode= isnull(LotNo ,'''')
                from stb_materialdoclotinfo
                where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''

                if(@mmmaterialcode ='''' and  (@RawMaterialBarcode like ''%SP%'' or @RawMaterialBarcode like ''%SL%''or @RawMaterialBarcode like ''%SM%''))
                begin 
                    select top 1  @validDate=isnull(LotAttr10,''2010-01-01''),@mmmaterialcode=isnull(MaterialCode,''''),@RawMaterialBarcode= isnull(LotNo ,'''')
                    from stb_materiallotinfo
                    where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
                end
                 
                set @pRawMaterialBarcode =  @mmmaterialcode +''#''+ @RawMaterialBarcode +'' ; ''+ @pRawMaterialBarcode +'';''+@pLotID_Warehouse_Created
                set @RawMaterialBarcode = @pRawMaterialBarcode
                 
                if((isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0) and @mmmaterialcode not in (''TRAY1320-B015''))
                begin try	
                    if  isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@validDate)  from STB_MaterialMaster where MaterialCode= @mmmaterialcode),getdate()-1)
                        < getdate()
                    begin 
                        set @err=N''Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: '' + 
                                                @pProductGroupCode+'' _ ''+ @RawMaterialBarcode +'' _ ''+
                                                @validDate + N''. Vui lòng kiểm tra lại!'';
                        RAISERROR (@err,16,1);
                        return;
                    end
                end try
                begin catch
                    set @err=N''Không thể chuyển đổi kí tự thành Ngày tháng,  (Lotattr10)Đặc tính 10 màn hình F330:'' + 
                                    @pProductGroupCode+'' _ ''+ @RawMaterialBarcode +'' _ ''+
                                    @validDate ;
                    SET @err = isnull(ERROR_MESSAGE(),'''')  +''_...............................''+ @err;
                    RAISERROR (@err,16,1);
                    return;
                end catch
            end
            else 
            begin
                if(isnull(@RawMaterialBarcode,'''')<>'''' and UPPER(isnull(@pProductGroupCode,'''')) not in ( ''ELECTRODEP'',''ELECTRODEM'' ) and UPPER(isnull(@pProductGroupCode,'''')) not like ''MODULE%''  and UPPER(isnull(@pProductGroupCode,'''')) not like ''SINGLE%''
                or isnull(@RawMaterialBarcode,'''')<>'''' and UPPER(isnull(@pProductGroupCode,''''))=''MODULESLEEVE'' 		
                )  
                begin
                    set @err=N''Không được sử dụng mã Vendor Lót không phải của Kho Nguyên liệu bắt đầu = kí tự   ML.... '' + 
                                        isnull(@pProductGroupCode,'''') +'' _ '' + isnull(@RawMaterialBarcode,'''') +'' _ ''+
                                        isnull(@validDate,'''') ;
                    RAISERROR (@err,16,1);
                    return;
                end
            end

            Declare @company varchar(10)=''''; 
            select @company= companycode from STB_UserInfo  with(nolock)  
            where UserID=isnull(@pProcessUserID,'''') 
                
            DECLARE 
                @ProductGroupCode VARCHAR(20) = @pProductGroupCode,
                @Barcode VARCHAR(20) = @pBarcode
                       
            if(ltrim(rtrim(isnull(@pRawMaterialBarcode,'''')))='''') begin
                if(ltrim(rtrim(isnull(@pRawMaterialInputHistNo,'''')))='''')
                    UPDATE STB_RawMaterialInputHist
                    SET
                        RawMaterialBarcode =  '''',				
                        ChangeDateTime = GETDATE(),
                        ChangeUserID = @pProcessUserID
                    WHERE   RawMaterialInputHistNo = @pRawMaterialInputHistNo
                return;
            end

            exec GetDatefromVENDORLOT1840 
                                @pBarCode = @BarCode,
                                @pProductGroupCode = @ProductGroupCode,
                                @pRawMaterialBarcode = @RawMaterialBarcode

            declare @ModelSize VARCHAR(10) = '''';
            declare @ModelName NVARCHAR(200) = '''';

            select @ModelSize =RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
            from STB_ModelBasicInfo with(nolock)
            where modelcode  = (select MaterialCode from STB_SetInfo WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
            
            select  @ModelName = replace(replace(replace(replace(replace(replace(replace(ModelName,@ModelSize,''''),''('',''''),'')'',''''),'' '',''''),''HY-CAP '',''''),''HY-CAP'',''''),''-'',''%'')
            from STB_ModelBasicInfo with(nolock)
            where modelcode  = (select MaterialCode from STB_SetInfo WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
                
            declare @cterminal1			nVARCHAR(300)='''',
                @cterminal2			nVARCHAR(300)='''',
                @crubber		nVARCHAR(300)='''',
                @celectrolyte	nVARCHAR(300)='''',
                @ccase			nVARCHAR(300)='''',
                @csleeve		nVARCHAR(300)='''',
                @ctape			nVARCHAR(300)='''',
                @cseparator			nVARCHAR(300)='''',
                @cElectrode1	nVARCHAR(300)='''',
                @cElectrode2	nVARCHAR(300)=''''
                
            select @cterminal1 = ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%terminal%+%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @cterminal2= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%terminal%-%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @crubber= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%rubber%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @celectrolyte= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%electrolyte%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @ccase= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%case%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @csleeve= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%sleeve%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @ctape= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%tape%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @cseparator= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%separator%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @cElectrode1= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%electrode%+%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''

            select  @cElectrode2= ''  <<>>  ''+materialcode+''  ''+semiProductname  from stb_vvt_materialbo with(nolock)
            where part like ''%electrode%-%'' and size = @ModelSize and semiProductname  like ''%''+@ModelName+''%''
                      
            if( UPPER(isnull(@pProductGroupCode,'''')) in ( ''TERMINALP'',''TERMINALM'',''ATLTERMINAL'' )  ) begin	
                if( ltrim(@pRawMaterialBarcode) like ''15166-21.3%'') set @pRawMaterialBarcode = ''GBYCTT-003''+@pRawMaterialBarcode
                if( ltrim(@pRawMaterialBarcode) like ''15166-17.8%'') set @pRawMaterialBarcode = ''GBYCTT-002''+@pRawMaterialBarcode
                            
                select @count=count(*) from STB_SetInfo where barcode = @pBarcode and (MaterialCode like ''LIVT%'') 
                if(@count=0) begin
                    select  @count=count(*) from STB_MaterialMaster with(nolock) where MaterialCode= (select MaterialCode from STB_SetInfo where barcode = @pBarcode)
                    and (
                    MaterialName like ''%VEC2R7506QG%'' or
                    MaterialName like ''%VEC3R0606QG%'' or
                    MaterialName like ''%WEC2R7506QG%'' or
                    MaterialName like ''%WEC3R0506QG%'' or
                    MaterialName like ''%WEC3R0606QG%'' or
                    MaterialName like ''%VHC2R3127QG%'' 
                    )
                end
            
                if(1=1 or @count>0) begin
                    ;with Termi1 as (
                        select materialcode as Terminal,  replace(replace(replace(replace(replace(replace(semiProductname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'','''') as model, replace(size,''-L'','''') as size 
                        from stb_vvt_materialbo with(nolock)
                        where part like ''%terminal%'' and size is not null and semiProductname not like ''%Element%''
                        union all 
                        select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'',''''),
                        RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
                        from STB_BomDetail bd with(nolock) 
                        join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                        where   modelname like ''%HY-CAP%'' or  modelname like ''VEL%''  
                    )
                    ,Termi as (
                        select Terminal, 
                        replace(replace(model,'' '',''''),''(''+size+'')'','''') model, size 
                        from Termi1
                        where len(size)=4 or len(size)=5
                        union all
                        select ''GBHB00-042'' as Terminal , ''VEC2R7506QG'' as model,''1840'' as size  union all
                        select ''GBHB00-042'' as Terminal , ''VEC3R0606QG'' as model,''1840'' as size  union all
                        select ''GBHB00-042'' as Terminal , ''WEC2R7506QG'' as model,''1840'' as size  union all
                        select ''GBHB00-042'' as Terminal , ''WEC3R0506QG'' as model,''1840'' as size  union all
                        select ''GBHB00-042'' as Terminal , ''WEC3R0606QG'' as model,''1840'' as size  union all
                        select ''GBHB00-042'' as Terminal , ''VHC2R3127QG'' as model,''1840'' as size  union all
                        select ''GBYCTT-003'' as Terminal , ''VEL08253R8506G-B034'' as model,''0825'' as size  union all
                        select ''GBYCTT-002'' as Terminal , ''VEL08253R8506G-B034'' as model,''0825'' as size  union all
                        select ''GBYCTT-003'' as Terminal , ''VEL08253R8506G''		as model,''0825'' as size  union all
                        select ''GCSAAT-002'' as Terminal , ''VEC3R0107QG''		as model,''2245'' as size  union all			
                        select ''GBHB00-042'' as Terminal , ''VEC3R0606QG''		as model,''1840'' as size  union all			
                        select ''GBHB00-S05'' as Terminal , ''VEC3R0606QG''		as model,''1840'' as size  union all			
                        select ''GBHB00-033'' as Terminal , ''VEC3R0406QC''		as model,''1346'' as size  union all	
                        select ''GBHB00-036'' as Terminal , ''WEC3R0205QA''     as model,''0816'' as size union all 
                        select ''GBHB00-049'' as Terminal , ''WEC3R0205QA''     as model,''0816'' as size union all 
                        select ''GBYCTT-002'' as Terminal , ''VEL08253R8506G''		as model,''0825'' as size union all
                        select ''GBNN00-002'' as Terminal , ''WEC3R0105QD'' as model,''0612'' as size union all
                        SELECT ''GBNN00-001'' AS Terminal, ''WEC3R0105QD'' AS model, ''0612'' AS size union all
                        select ''GBHB00-034'' as Terminal , ''VET10252R7106G''		as model,''1025'' as size
                    )
                    ,								
                    checkLotNo as (
                        select N''1.Không đúng LotNo'' as infoe
                    )
                    ,
                    checkElectrolyte as (
                        select si.barcode,mm.MaterialCode,MaterialName,N''2.Chưa thiết lập mã code Tancha cho sản phẩm này: ''+mm.MaterialCode+'' -> ''+MaterialName as infoe 
                        from STB_SetInfo si with(nolock) 
                        join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
                        where barcode=isnull(@pBarcode,'''') 
                    ),
                    checkQRCode as (
                        select barcode,MaterialCode,MaterialName,Termi.model,Terminal,N''3.Mã Tancha được thiết lập, khác với mã QRCODE nhập vào B597: ''+@pRawMaterialBarcode as infoe 
                        from checkElectrolyte
                        join   Termi on  checkElectrolyte.MaterialName like  ''%'' + Termi.model + ''%'' and @ModelSize = Termi.size 		 
                    ),
                    chk as (
                        select barcode,checkQRCode.MaterialCode,checkQRCode.MaterialName,model,Terminal,N''3.1. Không đúng loại Tancha (Dương)(+) hoặc (Âm)(-): ''+@pProductGroupCode as infoe 			
                        from checkQRCode 
                        join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Terminal				 
                           and Terminal = substring(isnull(@pRawMaterialBarcode,''''),1,10) 
                           and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''''))=''ATLTERMINAL'' then ''%'' else  (case when  UPPER(isnull(@pProductGroupCode,''''))=''TERMINALP'' then ''%(+)%'' else ''%(-)%'' end ) end
                           and  UPPER(isnull(mm2.ProductGroupCode,'''')) like ''%TERMINAL%''				
                    ),
                    checkQRProduct as (
                        select ''4.OK'' as infoe from checkQRCode 					
                        join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Terminal				 
                       and Terminal = substring(isnull(@pRawMaterialBarcode,''''),1,10)
                           and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''''))=''ATLTERMINAL'' then ''%'' else  (case when  UPPER(isnull(@pProductGroupCode,''''))=''TERMINALP'' then ''%(+)%'' else ''%(-)%'' end ) end
                       and  UPPER(isnull(mm2.ProductGroupCode,''''))  like ''%TERMINAL%'' 
                    )
                    ,
                    collectErr as (
                       select infoe from checkLotNo
                       union all
                       select infoe from checkElectrolyte
                       union all
                       select infoe from checkQRCode
                       union all
                       select infoe from chk
                       union all
                       select infoe from checkQRProduct
                    )
                    select @err = max(infoe) from collectErr
                  
                    if(@err <> ''4.OK'' or @err not like ''%.OK''  )begin	
                        set @err = @pBarcode+''_''+substring(@RawMaterialBarcode,1,20)+''...'' +'' : ''+  @err + case when @pProductGroupCode=''TERMINALM'' then isnull(@cterminal2,''.-'')  else isnull(@cterminal1,''.+'')  end				
                        raiserror (@err ,16,1) ;
                        return;					
                    end			

                    if( ltrim(@pRawMaterialBarcode) like ''GBYCTT-00%'') set @pRawMaterialBarcode = substring(@pRawMaterialBarcode,11,len(@pRawMaterialBarcode))
                end 
            end

            if( UPPER(isnull(@pProductGroupCode,'''')) = ''ELECTROLYTE'' ) begin
                if( ltrim(@pRawMaterialBarcode) like ''PEVN62-001%'') set @pRawMaterialBarcode = ''GBEC00-008''+@pRawMaterialBarcode
            
                ;with eleclyte1 as ( 
                  select materialcode as electrolyte, replace(replace(replace(replace(replace(replace(semiProductname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'','''') as model, replace(size,''-L'','''') as size 
                  from stb_vvt_materialbo with(nolock)
                  where part like ''%electrolyte%'' and size is not null and semiProductname not like ''%Element%''
                  union all select ''GBCP00-001'' as electrolyte , ''VEB2R8126HC'' as model ,''1030'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''WEC2R7106QG-L'' as model ,''1030'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0505QG'' as model ,''1020'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0705QG'' as model ,''1020'' as size  
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0227QG'' as model ,''2570'' as size  
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0705QG'' as model ,''1020'' as size  
                  union all select ''GBCP00-004'' as electrolyte , ''VEC2R7705QG'' as model ,''1020'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''WEC2R7105QG'' as model ,''0813'' as size  
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0126HC'' as model ,''1030'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0705QD'' as model ,''0830'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0356QG'' as model ,''1635'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''VEC2R7505QA'' as model ,''0825'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0507QG'' as model ,''3582'' as size
                  union all select ''GBCP00-004'' as electrolyte , ''VEC2R7505QG'' as model ,''1020'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''WEC2R7335QG'' as model ,''0820'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0107QD'' as model ,''1859'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0705QD'' as model ,''0830'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0105QD'' as model ,''0612'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0106QG'' as model ,''1030'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0335QG'' as model ,''0820'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0505QG'' as model ,''1020'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEC2R7106ZG'' as model ,''1030'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0205QA'' as model ,''0816'' as size   
                  union all select ''GBCP00-004'' as electrolyte , ''VEP3R0367QG'' as model ,''3562'' size 
                  union all select ''GBCP00-004'' as electrolyte , ''VEC3R0105QG'' as model ,''0813'' size 
                  union all select ''GBCP00-004'' as electrolyte , ''WEC3R0106QD'' as model, ''1320'' size 
                  union all select ''GBCP00-004'' as electrolyte , ''VEC2R7107QG'' as model, ''2245'' size 
                  union all select ''GBCP00-004'' AS electrolyte , ''VEC2R7105QG''  as model, ''0813'' size 
                  union all select ''GBCP00-004'' AS electrolyte , ''WEC3R0156QD''  as model, ''1035'' size 
                  UNION ALL select ''GBCP00-004'' AS electrolyte , ''WEC2R7106QG''  as model, ''1030'' size 
                  UNION ALL select ''PD-MMST00-002'' AS electrolyte , ''VEC3R0606QG''  as model, ''1840'' size 
                  UNION ALL select ''GBCP00-004'' AS electrolyte , ''WEC3R0107QD''  as model, ''1859'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0727QG''  as model, ''35105'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0367QG''  as model, ''3562'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0107QG''  as model, ''2245'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0606QG''  as model, ''1840'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC2R7406QC''  as model, ''1346'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0406QC''  as model, ''1346'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC3R0387QG''  as model, ''3562'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''WEC3R0106QD''  as model, ''1320'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''WEC3R0186QC''  as model, ''1325'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC2R7506QG''  as model, ''1840'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''WEC3R0156QG''  as model, ''1325'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''WEC3R0506QG''  as model, ''1840'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEP3R0367QG''  as model, ''3562'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''WEC3R0256QG''  as model, ''1625'' size 
                  UNION ALL select ''GBCP00-004'' AS electrolyte , ''WEC2R7346QA''  as model, ''1830'' size 
                  UNION ALL select ''GBEC00-011'' AS electrolyte , ''VEC2R7107QG''  as model, ''2245'' size  UNION ALL
                  select ''GBEC00-011'' AS electrolyte , ''WEC3R0156QG''  as model, ''1325'' size  UNION ALL 
                  select ''GBEC00-S01'' AS electrolyte , ''VET18402R7506G''  as model, ''1840'' size  UNION ALL 
                  select ''GBEC00-011'' AS electrolyte , ''WEC3R0606QG''  as model, ''1840''
                  union all
                  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'',''''),
                  RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
                  from STB_BomDetail bd with(nolock) 
                  join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                  where   modelname like ''%HY-CAP%'' or  modelname like ''VEL%''
                  union all
                  select distinct replace(ChildMaterialCode,''GBCP00-001'',''GBEC00-007''),replace(replace(replace(replace(replace(replace(mbi.modelname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'',''''),
                  RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
                  from STB_BomDetail bd with(nolock) 
                  join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                  where   modelname like ''%HY-CAP%'' or  modelname like ''VEL%''
                )
                ,eleclyte as (
                  select electrolyte, replace(replace(model,'' '',''''),''(''+size+'')'','''') model, size 
                  from eleclyte1
                  where len(size)=4 or len(size)=5
                )
                ,
                checkLotNo as (
                    select N''1.Không đúng LotNo'' as infoe
                )
                ,
                checkElectrolyte as (
                    select si.barcode,mm.MaterialCode,MaterialName,N''2.Chưa thiết lập mã code Electrolyte/ DUNG DỊCH cho sản phẩm này: ''+mm.MaterialCode+'' -> ''+MaterialName as infoe 
                    from STB_SetInfo si with(nolock) 
                    join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
                    where barcode=isnull(@pBarcode,'''') 
                ),
                checkQRCode as (
                    select barcode,MaterialCode,MaterialName,eleclyte.model,electrolyte,N''3.Mã Electrolyte/ DUNG DỊCH được thiết lập, khác với mã QRCODE nhập vào B597: ''+@pRawMaterialBarcode as infoe 
                    from checkElectrolyte
                    join   eleclyte on  checkElectrolyte.MaterialName like  ''%'' + eleclyte.model + ''%''  and @ModelSize = eleclyte.size 
                ),
                checkQRProduct as (
                    select ''4.OK'' as infoe from checkQRCode 					
                    join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.electrolyte				 
                   and electrolyte = substring(isnull(@pRawMaterialBarcode,''''),1,10) 
                   and  UPPER(isnull(mm2.ProductGroupCode,'''')) = UPPER(isnull(@pProductGroupCode,''''))
                )
                ,
                collectErr as (
                   select infoe from checkLotNo
                   union all
                   select infoe from checkElectrolyte
                   union all
                   select infoe from checkQRCode
                   union all
                   select infoe from checkQRProduct
                )
                select @err = max(infoe) from collectErr

                if(@err <> ''4.OK'' or @err not like ''%.OK''  )begin 
                    set @err = @err +  isnull(@celectrolyte,''.'') 
                    set @err = @pBarcode+''_''+substring(@RawMaterialBarcode,1,20)+''...''  +'' : ''+ @err
                    raiserror (@err ,16,1) ; 
                    return; 
                end	 

                if( ltrim(@pRawMaterialBarcode) like ''GBEC00-008%PEVN62%'') set @pRawMaterialBarcode = substring(@pRawMaterialBarcode,11,len(@pRawMaterialBarcode))
            end

            if( UPPER(isnull(@pProductGroupCode,'''')) in ( ''SLEEVE'',''MODULESLEEVE'' ) ) begin	
                select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
                DECLARE @MateriaCodeGroupSLEEVE NVARCHAR(50)
                SELECT  @MateriaCodeGroupSLEEVE=PG.ProductGroupCode from STB_MaterialMaster MM 
                        LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
                        LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON MM.ProductGroupCode = PG.ProductGroupCode
                where MM.MaterialCode=@pRawMaterialBarcode
                if((isnull( @MateriaCodeGroupSLEEVE,'''')) not in ( ''SLEEVE'',''MODULESLEEVE'' ))
                begin
                   set @err = N''Mã này không phải là vỏ bọc của LotNo: '' +@pBarcode+  N''với mã nguyên vật liệu: ''  + @pRawMaterialBarcode ;
                   raiserror (@err ,16,1) ;
                   return;
                end

                declare @excluded INT=0 ;
                select @excluded = count(*) from STB_MaterialMaster
                where MaterialCode = (select MaterialCode from STB_SetInfo where Barcode=@pBarcode)
                and MaterialCode in (''EDVTMD-082'','''EDVTMD-160'',''EDVTMD-220'');

                ;with Sleev1 as ( 				
                  select materialcode as Sleeving, replace(replace(replace(replace(replace(replace(semiProductname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'','''') as model, replace(size,''-L'','''') as size 
                  from stb_vvt_materialbo with(nolock)
                  where part like ''%sleeve%'' and size is not null and semiProductname not like ''%Element%''
                  union all select ''GCMDPT-380'' as Sleeving , ''VEB2R8126HC'' as model,''1030'' as size 
                  union all
                  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,''HY-CAP '',''''),''HY-CAP'',''''),''-C'',''''),''-M'',''''),''MSP'',''''),''(CY)'',''''),
                  RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
                  from STB_BomDetail bd with(nolock) 
                  join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                  where   modelname like ''%HY-CAP%'' or  modelname like ''VEL%''   or  modelname like ''WEC%''  or  modelname like ''VEC%''
                )
                ,Sleev as (
                  select Sleeving, replace(replace(model,'' '',''''),''(''+size+'')'','''') model, size 
                  from Sleev1
                  where len(size)=4 or len(size)=5
                  union all select ''GCMDPT-200'' as Sleeving , ''VEC2R7105QG'' as model,''0813'' as size  union all
                  select ''GCMDPT-358'' as Sleeving , ''VEC3R0105QG'' as model,''0813'' as size  union all
                  select ''GCMDPT-421'' as Sleeving , ''WEC2R7105QG'' as model,''0813'' as size  union all
                  select ''GCMDPT-379'' as Sleeving , ''WEC3R0105QG'' as model,''0813'' as size  union all
                  select ''GCMDPT-201'' as Sleeving , ''VEC2R7335QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-300'' as Sleeving , ''VEC3R0205QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-216'' as Sleeving , ''VEC3R0335QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-235'' as Sleeving , ''VEC2R7305QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-430'' as Sleeving , ''VEC3R0305QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-393'' as Sleeving , ''WEC2R7335QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-402'' as Sleeving , ''WEC3R0205QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-382'' as Sleeving , ''WEC3R0335QG%C'' as model,''0820'' as size  union all
                  select ''GCMDPT-382'' as Sleeving , ''WEC3R0335QG%M'' as model,''0820'' as size  union all
                  select ''GCMDPT-382'' as Sleeving , ''WEC3R0335QG%M0.6T'' as model,''0820'' as size  union all
                  select ''GCMDPT-234'' as Sleeving , ''VEC2R7155QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-344'' as Sleeving , ''VEC3R0155QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-400'' as Sleeving , ''WEC2R7155QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-401'' as Sleeving , ''WEC3R0155QG'' as model,''0820'' as size  union all
                  select ''GCMDPT-340'' as Sleeving , ''WEC3R0335QG'' as model,''0820'' as size  union all    
                  select ''GCMDPT-196'' as Sleeving , ''VEC2R7505QA'' as model,''0825'' as size  union all
                  select ''GCMDPT-196'' as Sleeving , ''VEC2R7505QA'' as model,''0825'' as size  union all
                  select ''GCMDPT-298'' as Sleeving , ''VEC3R0505QD'' as model,''0825'' as size  union all
                  select ''GCMDPT-501'' as Sleeving , ''WEC2R7505QA'' as model,''0825'' as size  union all
                  select ''GCMDPT-419'' as Sleeving , ''WEC3R0505QD'' as model,''0825'' as size  union all
                  select ''GCMDPT-369'' as Sleeving , ''VEC3R0705QD'' as model,''0830'' as size  union all
                  select ''GCMDPT-416'' as Sleeving , ''WEC3R0705QD'' as model,''0830'' as size  union all
                  select ''GCMDPT-197'' as Sleeving , ''VEC2R7505QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-198'' as Sleeving , ''VEC2R7705QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-275'' as Sleeving , ''VEC3R0505QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-340'' as Sleeving , ''VEC3R0705QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-408'' as Sleeving , ''WEC2R7505QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-390'' as Sleeving , ''WEC2R7705QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-409'' as Sleeving , ''WEC3R0505QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-391'' as Sleeving , ''WEC3R0705QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-194'' as Sleeving , ''VHC2R3106QG'' as model,''1020'' as size  union all
                  select ''GCMDPT-352'' as Sleeving , ''VEC2R7705QG'' as model,''1025'' as size  union all
                  select ''GCMDPT-257'' as Sleeving , ''VEC2R7905VA'' as model,''1025'' as size  union all
                  select ''GCMDPT-259'' as Sleeving , ''VEC2R7106QA'' as model,''1025'' as size  union all
                  select ''GCMDPT-256'' as Sleeving , ''VEC3R0106QA'' as model,''1025'' as size  union all
                  select ''GCMDPT-386'' as Sleeving , ''WEC2R7106QA'' as model,''1025'' as size  union all
                  select ''GCMDPT-406'' as Sleeving , ''WEC3R0106QA'' as model,''1025'' as size  union all
                  select ''GCMDPT-391'' as Sleeving , ''WEC3R0705QG'' as model,''1025'' as size  union all
                  select ''GCMDPT-202'' as Sleeving , ''VEC2R7106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-202'' as Sleeving , ''VEC2R7106QG%L'' as model,''1030'' as size  union all
                  select ''GCMDPT-317'' as Sleeving , ''VEC2R7106ZG'' as model,''1030'' as size  union all 
                  select ''GCMDPT-470'' as Sleeving , ''VEL13353R8257G'' as model,''1335'' as size  union all 
                  select ''GCMDPT-220'' as Sleeving , ''VEC3R0106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-265'' as Sleeving , ''VEC2R5106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-399'' as Sleeving , ''WEC2R7106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-399'' as Sleeving , ''WEC2R7106QG%L'' as model,''1030'' as size  union all
                  select ''GCMDPT-399'' as Sleeving , ''WEC3R0106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-399'' as Sleeving , ''WEC3R0106QG%L'' as model,''1030'' as size  union all
                  select ''GCMDPT-380'' as Sleeving , ''WEC3R0106QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-380'' as Sleeving , ''WEC3R0106QG%L'' as model,''1030'' as size  union all
                  select ''GCMDPT-459'' as Sleeving , ''WEC3R0126HC'' as model,''1030'' as size  union all
                  select ''GCMDPT-211'' as Sleeving , ''VHC2R3226QG'' as model,''1030'' as size  union all
                  select ''GCMDPT-452'' as Sleeving , ''WEC3R0156QD'' as model,''1035'' as size  union all
                  select ''GCMDPT-288'' as Sleeving , ''VEC2R7106QC'' as model,''1320'' as size  union all
                  select ''GCMDPT-288'' as Sleeving , ''VEC2R7106QC'' as model,''1320'' as size  union all
                  select ''GCMDPT-307'' as Sleeving , ''VEC3R0106QD'' as model,''1320'' as size  union all
                  select ''GCMDPT-420'' as Sleeving , ''WEC2R7106QC'' as model,''1320'' as size  union all
                  select ''GCMDPT-424'' as Sleeving , ''WEC3R0106QD'' as model,''1320'' as size  union all
                  select ''GCMDPT-204'' as Sleeving , ''VEC2R7156QG'' as model,''1325'' as size  union all
                  select ''GCMDPT-223'' as Sleeving , ''VEC2R7186QC'' as model,''1325'' as size  union all
                  select ''GCMDPT-227'' as Sleeving , ''VEC3R0156QG'' as model,''1325'' as size  union all
                  select ''GCMDPT-365'' as Sleeving , ''VEC3R0156HG'' as model,''1325'' as size  union all
                  select ''GCMDPT-405'' as Sleeving , ''WEC2R7156QG'' as model,''1325'' as size  union all
                  select ''GCMDPT-442'' as Sleeving , ''WEC2R7186QC'' as model,''1325'' as size  union all
                  select ''GCMDPT-392'' as Sleeving , ''WEC3R0156QG'' as model,''1325'' as size  union all
                  select ''GCMDPT-371'' as Sleeving , ''VEC3R0186QC'' as model,''1325'' as size  union all
                  select ''GCMDPT-384'' as Sleeving , ''WEC3R0186QC'' as model,''1325'' as size  union all
                  select ''GCMDPT-415'' as Sleeving , ''WEC2R7406QC'' as model,''1346'' as size  union all
                  select ''GCMDPT-301'' as Sleeving , ''VEC2R7406QC'' as model,''1346'' as size  union all
                  select ''GCMDPT-208'' as Sleeving , ''VEC2R7256QG'' as model,''1625'' as size  union all
                  select ''GCMDPT-240'' as Sleeving , ''VEC3R0256QG'' as model,''1625'' as size  union all
                  select ''GCMDPT-504'' as Sleeving , ''WEC2R7256QG'' as model,''1625'' as size  union all
                  select ''GCMDPT-383'' as Sleeving , ''WEC3R0256QG'' as model,''1625'' as size  union all
                  select ''GCMDPT-422'' as Sleeving , ''VHC2R3506QG'' as model,''1625'' as size  union all
                  select ''GCMDPT-376'' as Sleeving , ''VEC3R0356QG'' as model,''1635'' as size  union all
                  select ''GCMDPT-S07'' as Sleeving , ''WEC6R0126QG-H'' as model,'''' as size  union all 
                  select ''GCMDPT-241'' as Sleeving , ''VEC2R7346QA'' as model,''1830'' as size  union all
                  select ''GCMDPT-403'' as Sleeving , ''WEC2R7346QA'' as model,''1830'' as size  union all
                  select ''GCMDPT-199'' as Sleeving , ''VEC2R7506QG'' as model,''1840'' as size  union all 
                  select ''GCMDPT-276'' as Sleeving , ''VEC3R0606QG'' as model,''1840'' as size  union all
                  select ''GCMDPT-378'' as Sleeving , ''WEC2R7506QG'' as model,''1840'' as size  union all
                  select ''GCMDPT-388'' as Sleeving , ''WEC3R0506QG'' as model,''1840'' as size  union all
                  select ''GCMDPT-404'' as Sleeving , ''WEC3R0606QG'' as model,''1840'' as size  union all
                  select ''GCMDPT-210'' as Sleeving , ''VHC2R3127QG'' as model,''1840'' as size  union all
                  select ''GCMDPT-S01'' as sleeving, ''VEC6R0306QG%WC'' as model, '''' as size	union all 
                  select ''GCMDPT-S01'' as sleeving, ''VEC6R0306QG'' as model, '''' as size	union all 
                  select ''GCMDPT-370'' as Sleeving , ''VEC2R7107QD'' as model,''1859'' as size  union all
                  select ''GCMDPT-410'' as Sleeving , ''WEC2R7107QD'' as model,''1859'' as size  union all
                  select ''GCMDPT-308'' as Sleeving , ''VEC3R0107QD'' as model,''1859'' as size  union all
                  select ''GCMDPT-242'' as Sleeving , ''VEC2R7107QG'' as model,''2245'' as size  union all
                  select ''GCMDPT-277'' as Sleeving , ''VEC3R0107QG%L'' as model,''2245'' as size  union all
                  select ''GCMDPT-368'' as Sleeving , ''VEB3R0107QG'' as model,''2245'' as size  union all
                  select ''GCMDPT-277'' as Sleeving , ''VEC3R0107QG'' as model,''2245'' as size  union all
                  select ''GCMDPT-262'' as Sleeving , ''VHC2R3307QG'' as model,''2245'' as size  union all
                  select ''GCMDPT-258'' as Sleeving , ''VHC2R3227QG'' as model,''2245'' as size  union all
                  select ''GCMDPT-407'' as Sleeving , ''VEC3R0227QG'' as model,''2570'' as size  union all
                  select ''GCMDPT-285'' as Sleeving , ''VEC2R7367QG'' as model,''3562'' as size  union all
                  select ''GCMDPT-218'' as Sleeving , ''VEC3R0367QG'' as model,''3562'' as size  union all
                  select ''GCMDPT-427'' as Sleeving , ''VEP3R0367QG'' as model,''3562'' as size  union all
                  select ''GCMDPT-435'' as Sleeving , ''VEC3R0387QG'' as model,''3562'' as size  union all
                  select ''GCMDPT-362'' as Sleeving , ''VEC3R0407QA'' as model,''3567'' as size  union all
                  select ''GCMDPT-273'' as Sleeving , ''VEC2R7507QG'' as model,''3582'' as size  union all
                  select ''GCMDPT-353'' as Sleeving , ''VEC3R0507QG'' as model,''3582'' as size  union all
                  select ''GCMDPT-443'' as Sleeving , ''VEP3R0507QG'' as model,''3582'' as size  union all
                  select ''GCMDPT-217'' as Sleeving , ''VEC3R0357QG'' as model,''3562'' as size  union all
                  select ''GCMDPT-445'' as sleeving, ''WEC6R0505QA-I'' as model, '''' as size union all 
                  select ''GCMDPT-205'' as sleeving, ''VEC5R4504QG-I'' as model, '''' as size union all 
                  select ''GCMDPT-205'' as sleeving, ''VEC5R4504QG-H'' as model, '''' as size union all 
                  select ''GCMDPT-205'' as sleeving, ''VEC5R4504QG-O'' as model, '''' as size union all 
                  select ''GCMDPT-432'' as sleeving, ''WEC5R4504QG-I'' as model, '''' as size union all 
                  select ''GCMDPT-432'' as sleeving, ''WEC5R4504QG-H'' as model, '''' as size union all 
                  select ''GCMDPT-355'' as sleeving, ''VEC6R0504QG-I'' as model, '''' as size union all 
                  select ''GCMDPT-387'' as sleeving, ''WEC6R0504QG-I'' as model, '''' as size union all 
                  select ''GCMDPT-387'' as sleeving, ''WEC6R0504QG-O'' as model, '''' as size union all 
                  select ''GCMDPT-355'' as sleeving, ''VEC6R0504QG-H'' as model, '''' as size union all 
                  select ''GCMDPT-355'' as sleeving, ''VEC6R0504QG-O'' as model, '''' as size union all 
                  select ''GCMDPT-432'' as sleeving, ''WEC5R4504QG-O'' as model, '''' as size union all 
                  select ''GCMDPT-387'' as sleeving, ''WEC6R0504QG-H'' as model, '''' as size 
                  select ''PBDM00-185'' as sleeving, ''VEC5R4155QG-I (23x17x9)'' as model, '''' as size union all
                  select ''PBDM00-186'' as sleeving, ''WEC6R0255QG-IL'' as model, '''' as size union all
                  select ''PBDM00-186'' as sleeving, ''WEC6R0505QG-I'' as model, '''' as size union all
                  select ''PBDM00-186'' as sleeving, ''WEC6R0505QA-I-L'' as model, '''' as size union all
                  select ''PBDM00-184'' as sleeving, ''WEC6R0505QA-O'' as model, '''' as size union all
                  select ''PBDM00-184'' as sleeving, ''WEC5R4505QG-O'' as model, '''' as size union all
                  select ''PBDM00-184'' as sleeving, ''WEC6R0355QG-OL'' as model, '''' as size union all
                  select ''PBDM00-171'' as sleeving, ''WCI(62mm)'' as model, '''' as size union all
                  select ''PBDM00-171'' as sleeving, ''WCI(35mm)'' as model, '''' as size union all
                  select ''PBDM00-171'' as sleeving, ''WCI(50mm)'' as model, '''' as size union all
                  select ''GCMDPT-206'' as sleeving, ''VEC5R4155QG-I'' as model, '''' as size union all 
                  select ''GCMDPT-206'' as sleeving, ''VEC5R4155QG-H'' as model, '''' as size 
                )
                ,Sleev as (
                  select Sleeving, replace(replace(model,'' '',''''),''(''+size+'')'','''') model, size 
                  from Sleev1
                  where len(size)=4 or len(size)=5
                )

                declare @OpenExpiredSleeve bit = 0 
                ;with data1 as (
                    select LotID,max(createdatetime) as createdatetime
                    from stb_vvt_OpenExpiredMaterial  with(nolock) 
                    where (LotID=@pRawMaterialBarcode)
                    group by lotid
                )
                select top 1 @OpenExpiredSleeve = voem.OpenExpired 
                from stb_vvt_OpenExpiredMaterial voem with(nolock) 
                join data1 on voem.lotid = data1.lotid and voem.createdatetime = data1.createdatetime

                declare @validDateSleeve varchar(20);
                declare @mmmaterialcodeSleeve varchar(30)='''';
                select top 1  @validDateSleeve=isnull(LotAttr10,''2010-01-01''),@mmmaterialcodeSleeve=isnull(MaterialCode,''''),@pRawMaterialBarcode= isnull(LotNo ,'''')
                from stb_materialdoclotinfo
                where lotid=@pRawMaterialBarcode
                 
                if(@mmmaterialcodeSleeve ='''' and  (@pRawMaterialBarcode like ''%SP%'' or @pRawMaterialBarcode like ''%SL%''or @pRawMaterialBarcode like ''%SM%''))
                begin 
                    select top 1  @validDateSleeve=isnull(LotAttr10,''2010-01-01''),@mmmaterialcodeSleeve=isnull(MaterialCode,''''),@pRawMaterialBarcode= isnull(LotNo ,'''')
                    from stb_materiallotinfo
                    where lotid=@pRawMaterialBarcode
                end

                if((isnull(@OpenExpiredSleeve,0)=0 or @OpenExpiredSleeve=0 or convert(bit,@OpenExpiredSleeve)=0) )
                begin try	
                    if  isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@validDateSleeve)  from STB_MaterialMaster where MaterialCode= @mmmaterialcodeSleeve),getdate()-1)
                        < getdate()
                    begin 
                        set @err=N''Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: '' + 
                                                @pProductGroupCode+'' _ ''+ @pRawMaterialBarcode +'' _ ''+
                                                @validDateSleeve + N''. Vui lòng kiểm tra lại!'';
                        RAISERROR (@err,16,1);
                        return;
                    end
                end try
                begin catch
                    set @err=N''Không thể chuyển đổi kí tự thành Ngày tháng,  (Lotattr10)Đặc tính 10 màn hình F330:'' + 
                                    @pProductGroupCode+'' _ ''+ @pRawMaterialBarcode +'' _ ''+
                                    @validDateSleeve ;
                    SET @err = isnull(ERROR_MESSAGE(),'''')  +''_...............................''+ @err;
                    RAISERROR (@err,16,1);
                    return;
                end catch

                ;with checkLotNo as (
                    select N''1.Không đúng LotNo'' as infoe
                )
                ,
                checkElectrolyte as (
                    select si.barcode,mm.MaterialCode,MaterialName,N''2.Chưa thiết lập mã code Sleeve/ VỎ BỌC cho sản phẩm này: ''+mm.MaterialCode+'' -> ''+MaterialName as infoe 
                    from STB_SetInfo si with(nolock) 
                    join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
                    where barcode=isnull(@pBarcode,'''') 
                ),
                checkQRCode as (
                    select barcode,MaterialCode,MaterialName,Sleev.model,Sleeving,N''3.Mã Sleeve/ VỎ BỌC được thiết lập, khác với mã QRCODE nhập vào B597: ''+@pRawMaterialBarcode as infoe 
                    from checkElectrolyte
                    join   Sleev on  checkElectrolyte.MaterialName like  ''%'' + Sleev.model + ''%''  and @ModelSize = Sleev.size 
                ),
                checkQRProduct as (
                    select ''4.OK'' as infoe from checkQRCode 					
                    join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Sleeving				 
                   and Sleeving = substring(isnull(@pRawMaterialBarcode,''''),1,10) 
                   and  UPPER(isnull(mm2.ProductGroupCode,'''')) = UPPER(isnull(@pProductGroupCode,''''))
                )
                ,
                collectErr as (
                   select infoe from checkLotNo
                   union all
                   select infoe from checkElectrolyte
                   union all
                   select infoe from checkQRCode
                   union all
                   select infoe from checkQRProduct
                )
                select @err = max(infoe) from collectErr

                if(@err <> ''4.OK'' or @err not like ''%.OK''  )begin
                    if(@excluded = 0) begin
                        set @err = @err +  isnull(@csleeve,''.'') 
                        set @err = @pBarcode+''_''+substring(@RawMaterialBarcode,1,20)+''...''  +'' : ''+ @err
                        raiserror (@err ,16,1) ;
                        return;
                    end
                end	
            end

            declare @NameVVT nvarchar(100) = ''''
            declare @pRawMaterialBarcode1 nvarchar(1000) = @pRawMaterialBarcode
            if( UPPER(isnull(@pProductGroupCode,'''')) in ( ''LEAD-WIRE-1'','''LEAD-WIRE-2'' )  ) begin	
                set @NameVVT = N''LEAD-WIRE''
                declare @ChildMaterialCode1 varchar(50)='''';
                select distinct ChildMaterialCode1=ChildMaterialCode 
                from STB_BomDetail bd with(nolock) 
                join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                where mbi.ModelCode = @MaterialCode 
                  and ChildMaterialCode = substring(isnull(@pRawMaterialBarcode,''''),1,10)
                
                if(isnull(@ChildMaterialCode1,'''')<>'''')
                    set @ChildMaterialCode = @ChildMaterialCode1

                set @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)

                ;with getListMaterialBom as ( 				
                  select distinct ChildMaterialCode,bd.materialcode,replace(mbi.modelname,''Polymer '','''') as models,
                    RIGHT(''0''+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) as size
                    from STB_BomDetail bd with(nolock) 
                    join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
                    where  modelname like ''%Polymer%'' or modelname like ''%Hybrid%''
                )
                 ,getSizeCode as (
                  select ChildMaterialCode, materialcode,
                  replace(replace(models,'' '',''''),''(''+size+'')'','''') models, size 
                  from getListMaterialBom
                 where len(size)=3 or len(size)=4 or len(size)=5 
                ),
                checkInfomationBarcode as ( 
                    select si.barcode,mm.MaterialCode,MaterialName,N''1.Chưa thiết lập mã code ''+@NameVVT+ N''cho sản phẩm này: ''+mm.MaterialCode+'' -> ''+MaterialName as infoe 
                    from STB_SetInfo si with(nolock) 
                    join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
                    where barcode=isnull(@pBarcode,'''') 
                ),
                checkConfigBOMBarode as ( 
                    select barcode,cibc.MaterialCode,MaterialName,gsc.models,ChildMaterialCode,N''2.''+@NameVVT+ N'' được thiết lập, khác với mã QRCODE nhập vào B597: ''+@pRawMaterialBarcode1 as infoe 
                    from checkInfomationBarcode cibc
                    join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
                ),
                checkConfigBOMBarode1 as ( 
                    select barcode,cibc.MaterialCode,cibc.MaterialName,gsc.models,ChildMaterialCode,mm2.ProductGroupCode
                        ,N''3.''+@NameVVT+N'' được thiết lập, khác với mã QRCODE nhập vào B597: ''+ CHAR(10) 
                        +N''Mã đúng sẽ là :''+@ChildMaterialCode as infoe
                    from checkInfomationBarcode cibc
                    join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
                    join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = gsc.ChildMaterialCode
                    where mm2.ProductGroupCode = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'''')) 
                     and @ChildMaterialCode <> @pRawMaterialBarcode
                ),
                checkQRProduct as ( 
                     select ''4.OK'' as infoe from checkConfigBOMBarode  ccgbb					
                        join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = ccgbb.ChildMaterialCode			 
                       and @ChildMaterialCode = @pRawMaterialBarcode 
                       and  UPPER(isnull(mm2.ProductGroupCode,'''')) = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'''')) 
                        and @ChildMaterialCode = @pRawMaterialBarcode
                )
                ,
                collectErr as (
                   select infoe from checkInfomationBarcode
                   union all
                   select infoe from checkConfigBOMBarode
                   union all
                   select infoe from checkConfigBOMBarode1
                   union all
                   select infoe from checkQRProduct
                )
                select @err = max(infoe) from collectErr

                if(@err <> ''4.OK'' or @err not like ''%.OK''  )begin
                    set @err = @pBarcode +''_''+substring(@RawMaterialBarcode,1,20)+''...'' + CHAR(10) +@err 
                    raiserror (@err ,16,1) ;
                    return;
                end		
            end 

            set @RawMaterialBarcode  = substring(case when @pLotID_Warehouse_Created <>'''' and @pLotID_Warehouse_Created is not null
                                                then isnull(@pLotID_Warehouse_Created,'''') +''~''+isnull(@pRawMaterialBarcode,'''')
                                                else @RawMaterialBarcode
                                                end, 1, 1000) 
        END 
        END
        ELSE IF @checkWorkCenterCode IN (''VVT_F4'')
        BEGIN		-- BEGIN BG2
            set @pRawMaterialBarcode = ltrim(rtrim(isnull(@pRawMaterialBarcode,''''))); 
            set @pLotID_Warehouse_Created =ltrim(rtrim( isnull(@pLotID_Warehouse_Created,'''')));

            exec usp_VVT_checkHOLD_Material @lotid=@pRawMaterialBarcode        
            exec usp_VVT_checkHOLD_Material @lotid=@pLotID_Warehouse_Created   

            select @count=count(*) from stb_materialdoclotinfo
            where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
            if(@count <1 and (@RawMaterialBarcode like ''%SP%'' or @RawMaterialBarcode like ''%SL%'' or @RawMaterialBarcode like ''%SM%''))
            begin
                select @count=count(*) from STB_MaterialLotInfo
                where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
            end
            
            if(@count>0) begin   
                ;with data1 as (
                    select LotID,max(createdatetime) as createdatetime
                    from stb_vvt_OpenExpiredMaterial  with(nolock) 
                    where (LotID=@pRawMaterialBarcode)
                    group by lotid
                )
                select top 1 @OpenExpired = voem.OpenExpired 
                from stb_vvt_OpenExpiredMaterial voem with(nolock) 
                join data1 on voem.lotid = data1.lotid and voem.createdatetime = data1.createdatetime

                select top 1  @validDate=isnull(LotAttr10,''2010-01-01''),@mmmaterialcode=isnull(MaterialCode,''''),@RawMaterialBarcode= isnull(LotNo ,'''')
                from stb_materialdoclotinfo
                where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''

                if(@mmmaterialcode ='''' and  (@RawMaterialBarcode like ''%SP%'' or @RawMaterialBarcode like ''%SL%''or @RawMaterialBarcode like ''%SM%''))
                begin 
                    select top 1  @validDate=isnull(LotAttr10,''2010-01-01''),@mmmaterialcode=isnull(MaterialCode,''''),@RawMaterialBarcode= isnull(LotNo ,'''')
                    from stb_materiallotinfo
                    where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'''')<>''''
                end
                 
                set @pRawMaterialBarcode =  @mmmaterialcode +''#''+ @RawMaterialBarcode +'' ; ''+ @pRawMaterialBarcode +'';''+@pLotID_Warehouse_Created
                set @RawMaterialBarcode = @pRawMaterialBarcode
                 
                if((isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0) and @mmmaterialcode not in (''TRAY1320-B015''))
                begin try	
                    if  isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@validDate)  from STB_MaterialMaster where MaterialCode= @mmmaterialcode),getdate()-1)
                        < getdate()
                    begin 
                        set @err=N''Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: '' + 
                                                @pProductGroupCode+'' _ ''+ @RawMaterialBarcode +'' _ ''+
                                                @validDate + N''. Vui lòng kiểm tra lại!'';
                        RAISERROR (@err,16,1);
                        return;
                    end
                end try
                begin catch
                    set @err=N''Không thể chuyển đổi kí tự thành Ngày tháng,  (Lotattr10)Đặc tính 10 màn hình F330:'' + 
                                    @pProductGroupCode+'' _ ''+ @RawMaterialBarcode +'' _ ''+
                                    @validDate ;
                    SET @err = isnull(ERROR_MESSAGE(),'''')  +''_...............................''+ @err;
                    RAISERROR (@err,16,1);
                    return;
                end catch
            end
            else 
            begin
                 IF isnull(@RawMaterialBarcode,'''')<>'''' and UPPER(isnull(@pProductGroupCode,''''))=''PWB164180''
                 begin
                    set @err=N''Không được sử dụng mã Vendor Lót không phải của Kho Nguyên liệu bắt đầu = kí tự   ML.... '' + 
                                        isnull(@pProductGroupCode,'''') +'' _ '' + isnull(@RawMaterialBarcode,'''') +'' _ ''+
                                        isnull(@validDate,'''') ;
                    RAISERROR (@err,16,1);
                    return;
                 end
            end

            select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
            declare @MaterialWarehouse VARCHAR(20) = null
            SELECT @MaterialWarehouse = MaterialWarehouseCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
            IF @MaterialWarehouse <> ''ROUTE_BG2_WH''
            begin
               raiserror (N''Lot này chưa được xuất ra sản xuất. Hãy kiểm tra lại'' ,16,1) ;
               return;
            end

            declare @MaterialBG2 VARCHAR(20) = null,
                    @TrueMaterialBG2 VARCHAR(20) = NULL
            if(isnull(@pProductGroupCode,'''') in (
                ''Capacitor35105'',
                ''Header145354'',
                ''Header145355'',
                ''Header145802'',
                ''Label029766'',
                ''MiscElectrical135474'',
                ''PWB164180'',
                ''TerminalBlock135474'',
                ''Cable166555'',
                ''Insulator165275'',
                ''Label021111'',
                ''Label021112'',
                ''Label021113'',
                ''Label102536'',
                ''Label130298'',
                ''Screw112752'',
                ''Screw126611'',
                ''Screw136544'',
                ''SheetMetalPart164081'',
                ''SheetMetalPart164083'',
                ''SheetMetalPart164085''
             )  ) 
             begin	
                 select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
                 SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
                 SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (RIGHT(@pProductGroupCode, 6))

                 if(@MaterialBG2 <> @TrueMaterialBG2)
                 begin
                    set @err = N''Mã lot đã nhập '' +@pRawMaterialBarcode+ '' - '' + @MaterialBG2 +  N'' khác NVL hệ thống: ''  + @TrueMaterialBG2 + N''. Vui lòng kiểm tra lại'';
                    raiserror (@err ,16,1) ;
                    return;
                 end
            end

            if(isnull(@pProductGroupCode,'''') in (
                ''Nut17412'',
                ''Screw18496'',
                ''Screw18501'',
                ''Screw18502'',
                ''Washer21121'',
                ''Washer21122''
             )  ) 
             begin	
                select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
                SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
                SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (RIGHT(@pProductGroupCode, 5))

                if(@MaterialBG2 <> @TrueMaterialBG2)
                begin
                   set @err = N''Mã lot đã nhập '' +@pRawMaterialBarcode+ '' - '' + @MaterialBG2 +  N'' khác NVL hệ thống: ''  + @TrueMaterialBG2 + N''. Vui lòng kiểm tra lại'';
                   raiserror (@err ,16,1) ;
                   return;
                end
            end

            if(isnull(@pProductGroupCode,'''') in ( ''RTVCoating'' )  ) 
            begin	
                select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
                SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
                SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE ''DOWSIL™ 3140 RTV Coating''

                if(@MaterialBG2 <> ''153_CHATPHUBM-02'')
                begin
                   set @err = N''Mã lot đã nhập '' +@pRawMaterialBarcode+ '' - '' + @MaterialBG2 +  N'' khác NVL hệ thống: ''  + @TrueMaterialBG2 + N''. Vui lòng kiểm tra lại'';
                   raiserror (@err ,16,1) ;
                   return;
                end
            end

            if(isnull(@pProductGroupCode,'''') in ( 
                    ''CapacitorBoard'',
                    ''Fan531'',
                    ''LEDBoard'',
                    ''MonitoringBoard'',
                    ''RelayBoard'',
                    ''SNSBoard'' )  ) 
            begin	
                select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
                SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
                SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (Select ProductGroupName from STB_RawMaterialBaiscInfo where ProductGroupCode LIKE @pProductGroupCode)

                if(@MaterialBG2 <> @TrueMaterialBG2)
                begin
                   set @err = N''Mã lot đã nhập '' +@pRawMaterialBarcode+ '' - '' + @MaterialBG2 +  N'' khác NVL hệ thống: ''  + @TrueMaterialBG2 + N''. Vui lòng kiểm tra lại'';
                   raiserror (@err ,16,1) ;
                   return;
                end
            end
        END		-- END BG2

        DECLARE @existingRawBarcode NVARCHAR(1000) = '''' 
        SELECT @existingRawBarcode = ISNULL(RawMaterialBarcode, '''') FROM STB_RawMaterialInputHist WITH(NOLOCK) WHERE RawMaterialInputHistNo = @pRawMaterialInputHistNo
        
        DECLARE @ShouldAppend INT = 0
        IF @pProductGroupCode IN (''ELECTRODEP'', ''ELECTRODEM'')
        BEGIN
            SET @ShouldAppend = 1
        END
        ELSE IF @pProductGroupCode = ''Case'' AND @ModelSize IN (''3562'', ''3582'', ''35105'')
        BEGIN
            SET @ShouldAppend = 1
        END

        IF @ShouldAppend = 1
        BEGIN
            IF @existingRawBarcode <> '''' AND CHARINDEX(ISNULL(@RawMaterialBarcode, ''''), @existingRawBarcode) = 0
                SET @RawMaterialBarcode = @existingRawBarcode + '' ; '' + ISNULL(@RawMaterialBarcode, '''')
        END
                    
        UPDATE STB_RawMaterialInputHist
        SET
            RawMaterialInputHistNo =   ISNULL(@pRawMaterialInputHistNo,RawMaterialInputHistNo),
            Barcode =   ISNULL(@pBarcode,@pBarcode),
            ProductGroupCode =   ISNULL(@pProductGroupCode,ProductGroupCode),
            RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
            LotMaterialCode =  ISNULL(@LotMaterialBarcode,@LotMaterialBarcode),
            CreateDateTime =   ISNULL(CreateDateTime,@pCreateDateTime),
            CreateUserID =   ISNULL(CreateUserID,@pProcessUserID),
            ChangeDateTime = GETDATE(),
            ChangeUserID = @pProcessUserID
        WHERE   RawMaterialInputHistNo = @pRawMaterialInputHistNo

        IF @@ROWCOUNT > 0
        BEGIN 
            IF @pProductGroupCode IN (''ELECTRODEP'', ''ELECTRODEM'') OR (@pProductGroupCode = ''Case'' AND @ModelSize IN (''3562'', ''3582'', ''35105''))
            BEGIN
                IF NOT EXISTS (
                   SELECT 1 
                   FROM STB_InputMaterialHistory
                   WHERE RawMaterialBarcode = @RawMaterialBarcode 
                         AND Barcode = @Barcode
                )
                BEGIN
                   INSERT INTO STB_InputMaterialHistory (Barcode, RawMaterialBarcode,CreateUserID,ProductGroupCode,CreatedDate)
                   VALUES (@Barcode, @RawMaterialBarcode,@pProcessUserID,@pProductGroupCode,GETDATE())
                END
            END
        END
    END
    ');

    -- Safety check: verify that changes took place correctly.
    -- If validation queries run fine, the user can replace ROLLBACK with COMMIT.
    PRINT 'Validation Query:';
    SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'STB_InputMaterialHistory' AND COLUMN_NAME = 'RawMaterialBarcode';

    -- ROLLBACK TRANSACTION by default to avoid accidental production alterations.
    -- The USER must change this to COMMIT TRANSACTION to persist changes.
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back successfully. (Change to COMMIT TRANSACTION to persist changes)';
    
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error encountered, transaction rolled back.';
    THROW;
END CATCH
GO
