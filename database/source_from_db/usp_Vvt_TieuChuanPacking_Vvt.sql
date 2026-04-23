--select * from STB_SetInfo where MaterialCode='ECVT30-277'
--exec usp_Vvt_TieuChuanPacking_Vvt 'VVPK222R710627'
--exec usp_Vvt_TieuChuanPacking_Vvt 'VVPO303R010516'
--exec usp_Vvt_TieuChuanPacking_Vvt 'VVON233R010626'
/*
EDVTMD-198
EDVTMD-222
RDMD00-272


select * from stb_MaterialMaster where MaterialName like '%VET10252R7106QG%'
*/
CREATE PROC [dbo].[usp_Vvt_TieuChuanPacking_Vvt]       
	@pBarCode varchar(20)
AS
BEGIN

	SET NOCOUNT ON;
	
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
	 


	declare @modelcode varchar(30)= (select materialcode from stb_setinfo WITH(NOLOCK) 
									 where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) 
								or Barcode in (case 
										when 	 @pBarcode like 'L%'
											then RIGHT(@pBarcode, 14)
										else ''
										end
										)
										-- Triều thêm để không cần cài lại chương trình và set up lại trên các máy tính ở đóng gói
										-- Trường hợp nếu mà tem in là VJ thay vì VV như mọi lần thì phải bắt buộc phải sửa tem in VJ trên B523 
										-- Thứ 2 là cập nhật lại Cột LotNumberRW lot từ VV-> VJ để có thể check được hàng trước khi vào kho
										-- Tiếp tục nếu mà băn mã VJ nếu là Lot Lẻ thì phải tự tính toán số lượng thùng được tạo ra để kiểm tra dựa vào số lượng thùng ngoài chị Phương Út cung cấp
										or LotNumberRW=@pBarCode 
									  )

	/* không ai đi xét 1 lot cả
	declare @modelcode varchar(30) = NULL

	IF (@pBarCode = 'LVVPN033R010629' ) 
		BEGIN 
			SET @modelcode = 'ECVT30-338'  -- DinhManh update 2025-05-05 following Ms.Phuong request
		END
	ELSE 
		BEGIN
			SET @modelcode = (select materialcode from stb_setinfo WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6) )
		END
		*/
	;with alldata as 
	(
select 'ECVT30-344'  as modelcode,8000	as thungNgoai,4000		as thungtrong,100	as soluongsetting,500	as tuibong,16	as sotuibong,3 as tieuchuanthua union all 
select 'ECVT27-322',8000	,4000,100,500,16,2 union all 
select 'EDVTMD-235',1800,900,100,150,12,1 union all  -- DinhManh update 2025-06-20
select 'RDMD00-347',2400,1200,100,200,12,2 union all
select 'ECVT27-398',8000	,4000,100,500,16,2 union all 
select 'ECVT27-388',3000	,1500,100,250,12,1 union all
select 'RDMD00-378',2400,1200,100,200,6,0 union all --update 2025-11-20
--select 'ECVT30-347',1680,560,0,0,0,0 union all --update 2025-11-27

select 'ECVT30-347',237,237,0,0,0,0 union all 

select 'ECVT30-292',3000	,1500,100,250,12,2 union all
select 'ECVT30-354',1800	,900,100,150,12,0 union all
--select 'ECVT30-354',1800	,900,100,150,6,0 union all
select 'RDMD00-334',1800	,900,100,150,12,0 union all --update 2025-08-08
select 'RDMD00-332',1400	,700,100,100,14,0 union all --update 2025-08-09
select 'EDVTMD-226',1400	,700,100,100,14,0 union all 

select 'ECVT30-219',8000	,4000,100,500,16,2 union all 
select 'ECVT30-330',8000	,4000,100,500,16,2 union all 
select 'ECVT27-399',3000	,1500,100,250,12,0 union all 
select 'ECVT27-323',8000	,4000,100,500,16,2 union all 
select 'ECVT30-220',8000	,4000,100,500,16,2 union all 
select 'ECVT30-371',8000	,4000,100,500,16,2 union all  -- add 2025-11-17
select 'RE3000-100',8000	,4000,100,500,16,2 union all
select 'ECVT30-331',6000	,3000,100,500,12,1 union all 
select 'ECVT27-372',6000	,3000,100,500,12,1 union all 
select 'ECVT30-278',6000	,3000,100,500,12,1 union all 
select 'ECVT27-373',6000	,3000,100,500,12,1 union all 

select 'ECVT30-276',6000	,3000,100,500,12,1 union all 
select 'ECVT30-268',6000	,3000,100,500,12,1 union all  -- add 2025-05-05
select 'ECVT30-360',6000	,3000,100,500,12,1 union all  -- add 2025-06-10

select 'RDMD00-301',4000	,2000,100,250,16,1 union all  -- add 2025-05-21

select 'RDMD00-322',800		,400,50	,50	,16	,0 union all   -- add 2025-05-26


select 'ECVT27-374',4000	,2000,100,250,16,1 union all 
select 'ECVT30-279',4000	,2000,100,250,16,1 union all 
select 'ECVT30-275',4000	,2000,100,250,16,1 union all 
select 'ECVT30-280',4000	,2000,100,250,16,1 union all 
select 'ECVT30-281',4000	,2000,100,250,16,1 union all 
select 'ECVT27-334',4000	,2000,100,250,16,1 union all 
select 'ECVT27-376',4000	,2000,100,250,16,1 union all 
select 'ECVT30-234',4000	,2000,100,250,16,1 union all 
select 'ECVT30-282',4000	,2000,100,250,16,1 union all 
select 'ECVT27-335',4000	,2000,100,250,16,1 union all 
select 'ECVT30-235',4000	,2000,100,250,16,1 union all 
select 'ECVT30-283',4000	,2000,100,250,16,1 union all 
select 'ECVT27-367',3000	,1500,100,250,12,1 union all 
select 'ECVT30-269',3000	,1500,100,250,12,1 union all 
select 'ECVT27-368',3000	,1500,100,250,12,1 union all 
select 'ECVT30-270',3000	,1500,100,250,12,1 union all 
select 'ECVT30-295',3000	,1500,100,250,12,1 union all 
select 'ECVT25-116',3000	,1500,100,250,12,1 union all 
select 'ECVT27-366',3000	,1500,100,250,12,1 union all 
select 'ECVT27-343',3000	,1500,100,250,12,1 union all 
select 'ECVT27-272',3000	,1500,100,250,12,1 union all 
select 'ECVT27-370',3000	,1500,100,250,12,1 union all 
select 'ECVT30-367',3000	,1500,100,250,12,1 union all 
select 'ECVT28-001',3000	,1500,100,250,12,1 union all 
select 'ECVT30-293',3000	,1500,100,250,12,1 union all 
select 'ECVT30-246',3000	,1500,100,250,12,1 union all 
select 'ECVT30-277',1680	,560,0	,0,0	,0       union all 
select 'ECVT27-344',3000	,1500,100,250,12,1 union all 
select 'ECVT30-247',3000	,1500,100,250,12,1 union all 
select 'ECVT30-325',3000	,1500,100,250,12,1 union all 
select 'ECVT30-345',3000	,1500,100,250,12,1 union all 
select 'ECVT30-346',3000	,1500,100,250,12,1 union all  -- add 2025-04-28
select 'ECVT27-346',2400	,1200,100,200,12,0 union all 
select 'ECVT30-249',2400	,1200,100,200,12,0 union all 
select 'ECVT27-347',2400	,1200,100,200,12,0 union all 
select 'ECVT30-250',2400	,1200,100,200,12,0 union all 
select 'ECVT30-338',2400	,1200,100,200,12,0 union all 
select 'ECVT27-383',2400	,1200,100,200,12,0 union all 
select 'ECVT27-349',2400	,1200,100,200,12,0 union all 
select 'ECVT30-332',2400	,1200,100,200,12,0 union all 
select 'ECVT30-290',2400	,1200,100,200,12,0 union all 
select 'ECVT30-251',2400	,1200,100,200,12,0 union all 
select 'ECVT27-350',2400	,1200,100,200,12,0 union all 
select 'ECVT30-262',2400	,1200,100,200,12,0 union all
select 'ECVT30-309',2400	,1200,100,200,12,0 union all   -- comment 2025-11-11
--select 'ECVT30-309', 3000, 1500, 100, 250, 12, 1 union all

--select 'ECVT30-262',1800	,900,100,150,12,0 union all     -- update 2025-04-14 following Ms.Phuong request type -L
select 'ECVT30-252',2400	,1200,100,200,12,0 union all 
select 'ECVT27-382',1200	,600,100,100,12	,0 union all 
select 'ECVT30-333',1200	,600,100,100,12	,0 union all 
select 'ECVT27-352',1400	,700,100,100,14	,0 union all 
select 'ECVT27-396',1400	,700,100,100,14	,0 union all 
select 'ECVT30-254',1400	,700,100,100,14	,0 union all 
select 'ECVT27-353',1400	,700,100,100,14	,0 union all 
select 'ECVT30-255',1400	,700,100,100,14	,0 union all 
select 'ECVT30-297',1400	,700,100,100,14	,0 union all 
select 'ECVT30-317',1400	,700,100,100,14	,0 union all 
select 'RDMD00-358',1400	,700,100,100,14	,0 union all 
select 'HCVT23-061',780	,260,0	,0,0	,0        union all 
select 'ECVT30-188',1200	,600,100,100,12	,0 union all 
select 'ECVT30-284',1200	,600,100,100,12	,0 union all 
select 'ECVT27-355',1000	,500,100,100,10	,0 union all 
select 'ECVT27-369',500	,250,0	,0,0	,0 union all 
select 'ECVT30-257',500	,250,0	,0,0	,0 union all 
select 'ECVT30-260',500	,250,0	,0,0	,0 union all 
select 'ECVT27-359',500	,250,0	,0,0	,0 union all 
select 'ECVT30-258',363	,150,0	,0,0	,0 union all 
select 'ECVT30-343',750	,250,0	,0,0	,0 union all 
select 'ECVT30-261',500	,250,0	,0,0	,0 union all 
select 'ECVT30-319',500	,250,0	,0,0	,0 union all 
select 'ECVT27-361',500	,250,0	,0,0	,0 union all 
select 'ECVT30-271',500	,250,0	,0,0	,0 union all 
select 'EDVTMD-153',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-206',3200	,1600,100,200,16,0 union all 
select 'ECVT54-057',3200	,1600,100,200,16,0 union all 
select 'ECVT54-055',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-142',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-161',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-151',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-186',3200	,1600,100,200,16,0 union all 
select 'RDMD00-237',3200	,1600,100,200,16,0 union all 
select 'RDMD00-287',4000	,2000,100,250,16,0 union all   -- DinhManh update 2025-04-10 tuibong 200->250
select 'EDVTMD-203',3200	,1600,100,200,16,0 union all 
select 'EDVTMD-152',3200	,1600,100,200,16,0 union all 
--select 'EDVTMD-237',3200	,1600,100,200,16,0 union all	
select 'EDVTMD-237',2400,1200,100,200,12,0 union all
select 'EDVTMD-146',2400	,1200,100,200,12,0 union all 
select 'ECVT54-060',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-165',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-175',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-174',2400	,1200,100,200,12,0 union all 
select 'RDMD00-238',2400	,1200,100,200,12,0 union all 
select 'RDMD00-239',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-145',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-187',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-204',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-159',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-190',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-214',2400	,1200,100,200,12,0 union all -- DinhManh add 2025-03-27 following Ms.Phuong request
select 'EDVTMD-238',2400	,1200,100,200,12,0 union all -- DinhManh add 2025-12-23 following Ms.Phuong request
select 'EDVTMD-095',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-182',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-169',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-217',1600	,800,100,100,16	,0 union all 
select 'ECVT54-054',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-193',2400	,1200,100,200,12,0 union all 
select 'EDVTMD-207',2400	,1200,100,200,12,0 union all 
select 'ECVT60-013',1600	,800,100,100,16	,0 union all 
select 'ECVT54-009',1600	,800,100,100,16	,0 union all 
select 'ECVT54-056',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-177',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-184',1600	,800,100,100,16	,0 union all 
select 'ECVT60-011',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-179',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-191',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-181',1600	,800,100,100,16	,0 union all 
select 'RDMD00-217',1600	,800,100,100,16	,0 union all 
select 'EDVTMD-149',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-163',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-157',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-158',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-180',1400	,700,100,100,14	,0 union all 
select 'RDMD00-228',1400	,700,100,100,14	,0 union all 
select 'RDMD00-121',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-200',1400	,700,100,100,14	,0 union all 
select 'ECVT60-020',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-195',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-116',1680	,560,0	,0,0	,0 union all 
select 'EDVTMD-185',1680	,560,0	,0,0	,0 union all 
select 'EDVTMD-148',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-167',1400	,700,100,100,14	,0 union all 
select 'ECVT54-059',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-202',1400	,700,100,100,14	,0 union all 
select 'RDMD00-123',1400	,700,100,100,14	,0 union all 
select 'ECVT60-009',1200	,600,100,100,12	,0 union all 
select 'ECVT60-010',1400	,700,100,100,14	,0 union all 
select 'EDVTMD-194',1400	,700,100,100,14	,0 union all 
select 'RDMD00-282',1400	,700,100,100,14	,0 union all  -- add 2025-10-18
select 'RDMD00-261',1400	,700,100,100,14	,0 union all 
select 'RDMD00-282',2400	,1200,200,100,12	,0 union all 
select 'EDVTMD-205',3200	,1600,100,200,16	,0 union all 

--select 'RDMD00-292',1400	,700,100,100,14	,0 union all 
select 'RDMD00-292',2400	,1200,100,200,12	,0 union all  -- DinhManh update 2025-05-07 
select 'EDVTMD-230',2400	,1200,100,200,12	,0 union all -- DinhManh add 2025-07-28 following Ms.Phuong request

select 'RDMD00-339',1800	,900,100,150,12	,0 union all -- DinhManh add 2025-04-02 following Ms.Phuong request


select 'EDVTMD-192',1400	,700,100,100,14	,0 union all 
--select 'ECVT54-061',800	,400,50	,50	,16	,0 union all 
select 'EDVTMD-173',800	,400,50	,50	,16	,0 union all 
select 'ECVT60-012',800	,400,50	,50	,16	,0 union all 
--select 'EDVTMD-198',800	,400,50	,50	,16	,0 union all 
select 'RDMD00-283',800	,400,50	,50	,16	,0 union all		-- 2025-10-13
select 'EDVTMD-156',800	,400,50	,50	,16	,0 union all 
select 'EDVTMD-155',800	,400,50	,50	,16	,0 union all 
select 'EDVTMD-183',120	,60	,0	,0	,0	,0 union all 
select 'RDMD00-368',120	,60	,10	,10	,12	,0 union all    -- 2025-10-28
select 'EDVTMD-160',100	,50	,0	,0	,0	,0 union all 
select 'EDVTMD-144',250	,125,0	,0	,0	,0 union all 
select 'EDVTMD-082',15	,5	,0	,0	,0	,0  union all
select 'RDMD00-266',250	,125,0	,0	,0	,0 union all
select 'RDMD00-272',320	,100,0	,0	,0	,0 union all
select 'EDVTMD-198',85	,85,0	,0	,0	,0 union all
select 'ECVT27-386', 3000, 1500, 100, 250, 12, 1 union all
select 'ECVT30-272', 2400, 1200, 100, 200, 12, 1 union all
select 'ECVT30-214', 2400, 1200, 100, 200, 12, 1 union all
select 'ECVT30-288', 2400, 1200, 100, 200, 12, 1 union all
select 'ECVT30-289', 2400, 1200, 100, 200, 12, 1 union all
select 'ECVT30-264', 2400, 1200, 100, 200, 12, 1 union all
select 'ECVT27-356', 1000, 500, 80, 100, 10, 1 union all
select 'ECVT27-358', 500, 250, 0, 0, 0, 0 union all
select 'HCVT23-059', 500, 250, 0, 0, 0, 0 union all
select 'ECVT30-287', 500, 250, 0, 0, 0, 0 union all
select 'ECVT27-247', 420, 140, 0, 0, 0, 0 union all
select 'ECVT30-115', 420, 140, 0, 0, 0, 0 union all
select 'ECVT30-113', 420, 140, 0, 0, 0, 0 union all
select 'HCVT23-049', 420, 140, 0, 0, 0, 0 union all
select 'ECVT30-316', 420, 140, 0, 0, 0, 0 union all
select 'ECVT30-300', 420, 140, 0, 0, 0, 0 union all
select 'ECVT30-215', 260, 130, 0, 0, 0, 0 union all
select 'ECVT30-357', 102, 51, 0, 0, 0, 0 union all
select 'ECVT30-098', 120, 60, 0, 0, 0, 0 union all
select 'ECVT27-213', 120, 60, 0, 0, 0, 0 union all
select 'ECVT30-116', 120, 60, 0, 0, 0, 0 union all
select 'ECVT30-197', 120, 60, 0, 0, 0, 0 union all
select 'ECVT30-104', 111, 56, 0, 0, 0, 0 union all
select 'ECVT30-076', 120, 60, 0, 0, 0, 0 union all
select 'ECVT30-358', 120, 60, 0, 0, 0, 0 union all
select 'ECVT30-117', 120, 60, 0, 0, 0, 0 union all
select 'RE3000-120', 750, 250, 0, 0, 0, 0 union all
select 'ECVT54-061', 300, 100, 0, 0, 0, 0 union all
select 'ECVT30-373', 500, 250, 0, 0, 0, 0 union all
select 'EDVTMD-222', 280, 140, 0, 0, 0, 0 union all
select 'ECVT30-373', 500, 250, 0, 0, 0, 0 union all
select 'EDVTMD-247',168,168,0	,0	,0	,0 union all
select 'RDMD00-340',115,115,0	,0	,0	,0
)
select top 1 * from alldata
where modelcode=@modelcode
	 
END


