-- Procedure: GetInfomationWorker
CREATE PROCEDURE [dbo].[GetInfomationWorker](
  @p_userId nvarchar(20)=null,
  @p_language nvarchar(20)=null,
  @p_companyCode nvarchar(20)=null,  -- đây là trường option
  @p_workCenterCode nvarchar(20)=null -- đây là trường option
)
as
begin
-- kiểm tra xem nếu biến đầu vào có rỗng hay không nêu rỗng thìg gán thêm % còn không lấy giá trị truyền vào
  declare @companyCode nvarchar(20)=
     case
	   when isnull(@p_companyCode,' ')=' '
	      then '%'
		  else @p_companyCode
	  end;
  declare @workCenterCode nvarchar(20)=
     case 
	   when isnull(@p_workCenterCode,' ')=' '
	     then '%'
		 else @p_workCenterCode
	  end;
	  select CompanyCode,CompanyName,WorkCenterCode,WorkCenterName,EmpNo  from STB_ProdWorkerInfo_Test_forLap where CompanyCode=@p_companyCode and WorkCenterCode=@p_workCenterCode;

end
GO

