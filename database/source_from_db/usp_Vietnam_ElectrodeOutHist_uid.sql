-- =============================================
-- Author: Mr.Tung
-- Create date: 2021-05-03
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeOutHist_uid]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotUniqueNumber INT ,
						@pEmpCreate VARCHAR(30) = NULL,		
						@pVCMLine VARCHAR(30) = NULL
AS

BEGIN
	

	declare @cCount INT  = 0


	--if(@pProcessUserID='nguyentung')
	--begin
	
	--			--declare @errrr varchar(100)=  convert(varchar(100),@NG_flag);

	--			--	raiserror (@errrr,16,1);
	--			--return;

	--			INSERT INTO @MeasureValueList (LotUniqueNumber,EmpCreate,VCMLine) VALUES (@pLotUniqueNumber, @pEmpCreate,@pVCMLine)

	--			declare @tung varchar(max) = ''
	--			select @tung =  (select  ' - '+EmpCreate+' - '+VCMLine from @MeasureValueList for xml path (''))

	--			raiserror (@tung,16,1)
	--			return

	--end


	
	if(@pVCMLine is null or @pLotUniqueNumber = 0 )
	begin
		--declare @test varchar(50)  = convert(varchar(50),@pLotUniqueNumber)
		--raiserror (@test,16,1);
		return;
	end

	SELECT @cCount = count(*) 
	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	   JOIN STB_Vietnam_ElectrodeOutHist SVEOH WITH(NOLOCK) on ESR.LotUniqueNumber = SVEOH.LotUniqueNumber
	where ESR.LotUniqueNumber=@pLotUniqueNumber
	if(@cCount>0)
		begin
			--raiserror ('Không thể sửa Mã Line sau khi đã Chọn và Lưu',16,1);
			return;
		end
		

	SELECT @cCount = count(*) 
	  FROM STB_ElectrodeSlittingResult SVEOH WITH(NOLOCK) 
	where LotUniqueNumber=@pLotUniqueNumber
	if(@cCount=0)
		begin
			--raiserror ('Không có dữ liệu nên ko cần Insert',16,1);
			return;
		end
		

	insert into STB_Vietnam_ElectrodeOutHist (LotUniqueNumber,CreateUserId,VCMLine) values (@pLotUniqueNumber,@pEmpCreate,@pVCMLine);
	--print 'Sửa đổi Hoàn thành';

END
