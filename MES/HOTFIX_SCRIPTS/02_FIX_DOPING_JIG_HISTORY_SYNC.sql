-- =============================================
-- Hotfix ID: 02_FIX_DOPING_JIG_HISTORY_SYNC
-- Target Object: usp_Vietnam_DopingJIG_uid
-- Author: Antigravity (Advanced Agentic Coding)
-- Date: 2026-06-10
-- Description: Sửa lỗi thời gian tương lai khiến mất dữ liệu log lịch sử autoend của đồ gá Doping.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;

PRINT 'Starting Hotfix: 02_FIX_DOPING_JIG_HISTORY_SYNC...';

-- 1. Định nghĩa lại stored procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_Vietnam_DopingJIG_uid')
BEGIN
    EXEC('
    ALTER PROCEDURE [dbo].[usp_Vietnam_DopingJIG_uid]
                            @pLotNo VARCHAR(20)=null, 
                            @plistJIGs VARCHAR(4000)=null
    AS
    BEGIN
            declare @ccount INT=0,
                    @ccount2 INT=0;

            if(@pLotNo is null or rtrim(ltrim(isnull(@pLotNo,'''')))='''') begin
                select N''Thiếu dữ liệu mã LotNo'' as errinfo
                return;
            end 

            DECLARE @LotNonew1 VARCHAR(20) = ''''
            DECLARE @LotNonew2 VARCHAR(20) = ''''
            DECLARE @LotNonew3 VARCHAR(20) = ''''
            DECLARE @LotNonew4 VARCHAR(20) = ''''
            DECLARE @LotNonew5 VARCHAR(20) = ''''
            DECLARE @LotNonew6 VARCHAR(20) = ''''
            
            select @LotNonew1 = NewBarcode
            from STB_LotChangeMaterialHistory  WITH(NOLOCK)
            where OldBarcode=@pLotNo; 
            
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
                
            select @ccount = count(*) 
            from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
               
            if(@ccount=0)begin 
                select N''Mã LotNo không đúng, không tìm thấy trong hệ thống!'' as errinfo
                return;
            end

            if(@plistJIGs is null or rtrim(ltrim(isnull(@plistJIGs,'''')))='''')begin
                select N''Thiếu dữ liệu mã Lot hoặc JIG QR Code'' as errinfo
                return;
            end 
                        
            -- Cập nhật tự động kết thúc nếu quá giờ nạp doping (6 giờ)
            update Stb_VVT_DopingJIG
            set Status=''autoend'', ChangeDateTime=getdate()	
            where status like ''%run%'' and EndDateTime <= getdate();

            -- FIX: Ghi nhận lịch sử autoend sửa thời gian so sánh từ +5s sang -5s
            insert into Stb_VVT_DopingJIG_History
            select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
            from Stb_VVT_DopingJIG
            where status like ''%autoend%''
            and ChangeDateTime > dateadd(second,-5,getdate()); -- Sửa dấu +5 thành -5 giây để lấy các bản ghi vừa cập nhật
            
            select @ccount = COUNT(*)
            from Stb_VVT_DopingJIG
            where status like ''%run%''
            and JigID in  (select value from dbo.fn_split_string(@plistJIGs,''^'') )
            and EndDateTime>= getdate();

            select @ccount2 = COUNT(*)
            from Stb_VVT_DopingJIG
            where status like ''%run%''
            and JigID in  (select value from dbo.fn_split_string(@plistJIGs,''^'') )
            and EndDateTime>= getdate() and LotInUsed<>@pLotNo ;
            
            if(@ccount>0 and @ccount2=0) begin
                select @ccount2=count(*) from dbo.fn_split_string(@plistJIGs,''^'')
                
                if( @ccount2 > @ccount) begin
                    insert into Stb_VVT_DopingJIG_History
                    select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
                    from Stb_VVT_DopingJIG
                    where status like ''%run%'';

                    update Stb_VVT_DopingJIG
                    set  LotInUsed=@pLotNo, 
                    status=''run'',  
                    BeginDateTime = getdate(), 
                    EndDateTime = DATEADD(hour,6,getdate()),
                    ChangeDateTime = getdate()
                    where JigID in (select value from dbo.fn_split_string(@plistJIGs,''^'') ) 
                    and EndDateTime<=getdate();
                 end

                    select N''OK, xử lý thành công. ''  + 
                            N''JIG đã bắt đầu chạy từ: ''+
                                ( select  N''LẦN ''+convert(varchar(3),row_number() over(order by begindate ))+'':  ''+begindate +'',  '' 
                                    from (select distinct convert(varchar(19),dateadd(hour,-2,isnull((BeginDateTime),'''')),120) 
                                                as begindate
                                            from Stb_VVT_DopingJIG
                                            where status like ''%run%''
                                            and JigID in  (select value from dbo.fn_split_string(@plistJIGs,''^'') )
                                          ) 
                                    begintable
                                    for xml path ('''')	
                                )
                            as errinfo 
                    return;
            end

            if(@ccount>0) begin
                    select *, N''JIG đang trong tình trạng hoạt động, cần Hủy bỏ với Lot trước đó!'' as errinfo
                    from Stb_VVT_DopingJIG
                    where status like ''%run%'' 	and EndDateTime>= getdate()
                    and JigID in  (select value from dbo.fn_split_string(@plistJIGs,''^'') ) ;

                    return;
            end
               
            insert into Stb_VVT_DopingJIG_History
            select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
            from Stb_VVT_DopingJIG
            where status like ''%run%'';
            
            update Stb_VVT_DopingJIG
            set  LotInUsed=@pLotNo, 
            status=''run'',  
            BeginDateTime = getdate(), 
            EndDateTime = DATEADD(hour,6,getdate()),
            ChangeDateTime = getdate()
            where JigID in (select value from dbo.fn_split_string(@plistJIGs,''^'') ) ;
            
            select N''OK, xử lý thành công!''  as errinfo
    end
    ');
    PRINT 'Procedure usp_Vietnam_DopingJIG_uid altered successfully.';
END
ELSE
BEGIN
    PRINT 'Error: Procedure usp_Vietnam_DopingJIG_uid not found!';
END

-- 2. Chạy thử nghiệm Simulation Test
-- Tạo Lot test
IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WHERE Barcode = 'TEST_DOPING_LOT')
BEGIN
    INSERT INTO STB_SetInfo (Barcode, MaterialCode, ProdQty, CreateDateTime, CreateUserID)
    VALUES ('TEST_DOPING_LOT', 'ECVT30-333', 100, GETDATE(), 'vinaadmin');
END

-- Thêm JIG test quá hạn (đã chạy > 6 tiếng) để test tự động kết thúc và ghi log
IF NOT EXISTS (SELECT 1 FROM Stb_VVT_DopingJIG WHERE JigID = 'JIG_TEST_01')
BEGIN
    INSERT INTO Stb_VVT_DopingJIG (JigID, LotInUsed, Status, BeginDateTime, EndDateTime, ChangeDateTime)
    VALUES ('JIG_TEST_01', 'OLD_LOT_01', 'run', DATEADD(hour, -7, GETDATE()), DATEADD(hour, -1, GETDATE()), DATEADD(hour, -7, GETDATE()));
END
ELSE
BEGIN
    UPDATE Stb_VVT_DopingJIG
    SET LotInUsed = 'OLD_LOT_01', Status = 'run', BeginDateTime = DATEADD(hour, -7, GETDATE()), EndDateTime = DATEADD(hour, -1, GETDATE()), ChangeDateTime = DATEADD(hour, -7, GETDATE())
    WHERE JigID = 'JIG_TEST_01';
END

-- Thực thi gán JIG mới cho Lot test (sẽ kích hoạt autoend cho JIG_TEST_01)
BEGIN TRY
    PRINT 'Executing doping jig assignment...';
    
    -- Xóa lịch sử cũ của JIG_TEST_01 để đối soát chính xác
    DELETE FROM Stb_VVT_DopingJIG_History WHERE JigID = 'JIG_TEST_01';
    
    EXEC usp_Vietnam_DopingJIG_uid 'TEST_DOPING_LOT', 'JIG_TEST_01';

    -- Kiểm tra xem JIG_TEST_01 cũ có được đẩy vào history với trạng thái autoend không
    IF EXISTS (SELECT 1 FROM Stb_VVT_DopingJIG_History WHERE JigID = 'JIG_TEST_01' AND Status = 'autoend')
    BEGIN
        PRINT 'Test: PASSED. History sync for autoend works correctly.';
    END
    ELSE
    BEGIN
        PRINT 'Test: FAILED. History log for autoend is missing!';
    END
END TRY
BEGIN CATCH
    PRINT 'Test: FAILED. Error: ' + ERROR_MESSAGE();
END CATCH;

-- Dọn dẹp dữ liệu test
DELETE FROM STB_SetInfo WHERE Barcode = 'TEST_DOPING_LOT';
DELETE FROM Stb_VVT_DopingJIG WHERE JigID = 'JIG_TEST_01';
DELETE FROM Stb_VVT_DopingJIG_History WHERE JigID = 'JIG_TEST_01';

-- 3. Hủy bỏ thay đổi để an toàn
ROLLBACK TRAN;
PRINT 'Transaction ROLLBACK successfully. DB remains untouched.';
