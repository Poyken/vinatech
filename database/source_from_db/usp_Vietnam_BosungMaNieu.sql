
CREATE PROCEDURE [dbo].[usp_Vietnam_BosungMaNieu]
			@MaterialCode VARCHAR(30),
			@BomVersion VARCHAR(30),
			@MaterialName varchar(50),
			@BomHeaderDesc VARCHAR(30),
			@ChildMaterialCode1 VARCHAR(30), @ChildMaterialCode2 VARCHAR(30), @ChildMaterialCode3 VARCHAR(30), @ChildMaterialCode4 VARCHAR(30), @ChildMaterialCode5 VARCHAR(30), @ChildMaterialCode6 VARCHAR(30), @ChildMaterialCode7 VARCHAR(30), @ChildMaterialCode8 VARCHAR(30), @ChildMaterialCode9 VARCHAR(30),
			@ChildBomVersion1 VARCHAR(30), @ChildBomVersion2 VARCHAR(30), @ChildBomVersion3 VARCHAR(30), @ChildBomVersion4 VARCHAR(30), @ChildBomVersion5 VARCHAR(30), @ChildBomVersion6 VARCHAR(30), @ChildBomVersion7 VARCHAR(30), @ChildBomVersion8 VARCHAR(30), @ChildBomVersion9 VARCHAR(30), 
			@BomUnit1 VARCHAR(30), @BomUnit2 VARCHAR(30), @BomUnit3 VARCHAR(30), @BomUnit4 VARCHAR(30), @BomUnit5 VARCHAR(30), @BomUnit6 VARCHAR(30), @BomUnit7 VARCHAR(30), @BomUnit8 VARCHAR(30), @BomUnit9 VARCHAR(30),
			@UsedQty1 VARCHAR(30), @UsedQty2 VARCHAR(30), @UsedQty3 VARCHAR(30), @UsedQty4 VARCHAR(30), @UsedQty5 VARCHAR(30), @UsedQty6 VARCHAR(30), @UsedQty7 VARCHAR(30), @UsedQty8 VARCHAR(30), @UsedQty9 VARCHAR(30),
			@RouteCode1 VARCHAR(30), @RouteCode2 VARCHAR(30), @RouteCode3 VARCHAR(30), @RouteCode4 VARCHAR(30), @RouteCode5 VARCHAR(30), @RouteCode6 VARCHAR(30), @RouteCode7 VARCHAR(30), @RouteCode8 VARCHAR(30), @RouteCode9 VARCHAR(30),
			@BomDetailDesc1 VARCHAR(30), @BomDetailDesc2 VARCHAR(30), @BomDetailDesc3 VARCHAR(30), @BomDetailDesc4 VARCHAR(30), @BomDetailDesc5 VARCHAR(30), @BomDetailDesc6 VARCHAR(30), @BomDetailDesc7 VARCHAR(30), @BomDetailDesc8 VARCHAR(30), @BomDetailDesc9 VARCHAR(30)
AS
BEGIN

	SET NOCOUNT ON;
		
--select*from 
--STB_BomDetail
--where MaterialCode='ECVT30-290'

--parameter : 
--usp_Vietnam_BosungMaNieu
			--'',
			--'',
			--'',
			--'','','','','','','','','',
			--'',
			--'','','','','','','','','',
			--'','','','','','','','','',
			--'','','','','','','','','',
			--'','','','','','','','',''



if (@MaterialCode is  null or @MaterialCode='' or @BomVersion is  null or @BomVersion='')
begin
print 'thieu @MaterialCode, @BomVersion';
 raiserror ('thieu @MaterialCode, @BomVersion',16,1)
 return;
end




--return;





-- láy bom ver tự động
begin tran
begin try






--insert into STB_MaterialMaster(
--MaterialCode,	
--MaterialName,	
--MaterialNameL,
--MaterialTypeCode,	
--ProductGroupCode,	
--MaterialUnit,
--IsInternalProd,	
--IsProdPlan,	
--IsPurchase,	
--IsOrder,
--MMExtInt01,
--CreateDateTime,	
--CreateUserID
--)
--values (
--@MaterialCode,
--@MaterialName,
--@BomHeaderDesc,
--'HALB',
--'JELLY-ROLL',
--null,
--0,
--1,
--1,
--1,
--3,
--getdate(),
--'nguyentung'
--);



--INSERT INTO [dbo].[STB_BomHeader]
--           ([MaterialCode]
--           ,[BomVersion]
--           ,[RouteCode]
--           ,[IsBasic]
--           ,[BomHeaderDesc]
--           ,[BasicRoutingCode]
--           ,[BomUnit]
--           ,[IsUsed]
--           ,[CreateDateTime]
--           ,[CreateUserID]
--           ,[ChangeDateTime]
--           ,[ChangeUserID])
--     VALUES
--           (
--		    @MaterialCode   
--           ,@BomVersion     -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
--           ,null--@RouteCode       =null
--           ,0--@IsBasic         =0
--           ,@BomHeaderDesc  -- ='mô tả bom ver  - nhap tay'
--           ,null--@BasicRoutingCode=null
--           ,null--@BomUnit         =null
--           ,1--@IsUsed          =1
--           ,getdate()--@CreateDateTime  =getdate()
--           ,'nguyentung'--@CreateUserID    ='nguyentung'
--           ,null--@ChangeDateTime  =null
--           ,null--@ChangeUserID    =null
--		  );
















--lấy bom ver tự động

if (@ChildMaterialCode1 is not null and @ChildMaterialCode1<>''
and @ChildBomVersion1 is not null and @ChildBomVersion1<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty1 is not null and @UsedQty1<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode1-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion1  -- = '>51'
           ,@BomUnit1		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty1		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode1		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc1	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end

	   		   	   





if (@ChildMaterialCode2 is not null and @ChildMaterialCode2<>''
and @ChildBomVersion2 is not null and @ChildBomVersion2<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty2 is not null and @UsedQty2<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode2-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion2  -- = '>51'
           ,@BomUnit2		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty2		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode2		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc2	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end










if (@ChildMaterialCode3 is not null and @ChildMaterialCode3<>''
and @ChildBomVersion3 is not null and @ChildBomVersion3<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty3 is not null and @UsedQty3<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode3-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion3  -- = '>51'
           ,@BomUnit3		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty3		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode3		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc3	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end










if (@ChildMaterialCode4 is not null and @ChildMaterialCode4<>''
and @ChildBomVersion4 is not null and @ChildBomVersion4<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty4 is not null and @UsedQty4<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode4-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion4  -- = '>51'
           ,@BomUnit4		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty4		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode4		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc4	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end









if (@ChildMaterialCode5 is not null and @ChildMaterialCode5<>''
and @ChildBomVersion5 is not null and @ChildBomVersion5<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty5 is not null and @UsedQty5<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode5-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion5 -- = '>51'
           ,@BomUnit5		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty5		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode5		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc5	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end








if (@ChildMaterialCode6 is not null and @ChildMaterialCode6<>''
and @ChildBomVersion6 is not null and @ChildBomVersion6<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty6 is not null and @UsedQty6<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode6-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion6  -- = '>51'
           ,@BomUnit6		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty6		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode6		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc6	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end









if (@ChildMaterialCode7 is not null and @ChildMaterialCode7<>''
and @ChildBomVersion7 is not null and @ChildBomVersion7<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty7 is not null and @UsedQty7<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode7-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion7  -- = '>51'
           ,@BomUnit7		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty7		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode7		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc7	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end








if (@ChildMaterialCode8 is not null and @ChildMaterialCode8<>''
and @ChildBomVersion8 is not null and @ChildBomVersion8<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty8 is not null and @UsedQty8<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode8-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion8  -- = '>51'
           ,@BomUnit8		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty8		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode8		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc8	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end









if (@ChildMaterialCode9 is not null and @ChildMaterialCode9<>''
and @ChildBomVersion9 is not null and @ChildBomVersion9<>''
--and BomUnit is not null and BomUnit<>''
and @UsedQty9 is not null and @UsedQty9<>''
--and @ChildMaterialCode is not null and @ChildMaterialCode<>''
)
begin
				
INSERT INTO [dbo].[STB_BomDetail]
           ([MaterialCode]
           ,[BomVersion]
           ,[ChildMaterialCode]
           ,[ChildBomVersion]
           ,[BomUnit]
           ,[UsedQty]
           ,[RouteCode]
           ,[IsOptionItem]
           ,[BomDetailDesc]
           ,[StdCombSec]
           ,[CreateDateTime]
           ,[CreateUserID]
           ,[ChangeDateTime]
           ,[ChangeUserID])
     VALUES
           (
		    @MaterialCode     -- =' - nhap tay'
           ,@BomVersion		  -- ='max bom split .  > 50  tu dong' + 'product code viet nam'
           ,@ChildMaterialCode9-- ='ma lieu tho hoặc dien cuc - nhap tay' 
           ,@ChildBomVersion9  -- = '>51'
           ,@BomUnit9		  -- ='doen vi NVL hơạc null - lay tu dong '
           ,@UsedQty9		  -- ='so luong su dung  - nhap tay'
           ,@RouteCode9		  -- ='ma V22 V24 tuy theo tung cong doạn - nhap tay'
           ,0--@IsOptionItem	  -- =0
           ,@BomDetailDesc9	  -- ='mô tả bom ver  - nhap tay'
           ,null--@StdCombSec		  -- =null
           ,getdate()--@CreateDateTime	  -- =getdate()
           ,'nguyentung'--@CreateUserID	  -- ='nguyentung'
           ,null--@ChangeDateTime   -- =null
           ,null--@ChangeUserID     -- =null
		   );	
end



		commit;

	end try
	begin catch

		rollback;
		--raiserror ('khong thuc hien duoc',16,1)

	end catch
--s--elect*from STB_BomHeader VVLJ193R070517
		  
END
