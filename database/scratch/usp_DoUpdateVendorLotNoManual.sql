
-- =============================================
-- Author: Jackaraoe(yjyu@vina.co.kr)
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 자재관리
-- Description: 업체바코드 수기입력처리
-- Modified:
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoUpdateVendorLotNoManual]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20),
	@pLotNo VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	declare @companycode varchar(10) ='';
	select @companycode = companycode from STB_UserInfo
	where UserID=@pProcessUserID

	Declare @MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo
	Declare @LotNo VARCHAR(500) = @pLotNo
	Declare @VendorLotNoCount INT = 0
	Declare @MDLISeqNo INT
	DECLARE @ErrorMessage NVARCHAR(500)=''
	declare @materialcode varchar(20)=''
	DECLARE @SourceCustomerCode            VARCHAR(100)

	SELECT @VendorLotNoCount = COUNT(*)
	  FROM STB_MaterialDocLotInfo
	 WHERE MaterialDocDetailNo = @MaterialDocDetailNo
	   AND RTRIM(ISNULL(LotNo, '')) = ''


	 IF @VendorLotNoCount = 0 BEGIN
		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
										'^모든 업체바코드가 입력되었습니다.^',
										@ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1,'')
		RETURN
	 END


	 SELECT TOP 1 @MDLISeqNo = MDLISeqNo , @materialcode = MaterialCode
	   FROM STB_MaterialDocLotInfo
	  WHERE MaterialDocDetailNo = @MaterialDocDetailNo
	    AND RTRIM(ISNULL(LotNo, '')) = ''
	  ORDER BY MDLISeqNo


	  UPDATE STB_MaterialDocLotInfo
	     SET LotNo = @LotNo
	   WHERE MaterialDocDetailNo = @MaterialDocDetailNo
	     AND MDLISeqNo = @MDLISeqNo
		 	

		
	-- Mr.Tung add LotID for Vietnam Site  on 2023-sep-21
	set @LotNo =   case when @LotNo like @materialcode+'#%' then replace(@LotNo, left(@LotNo,len(@materialcode)+1),'')  
						when @LotNo like @materialcode+'%'  then replace(@LotNo, left(@LotNo,len(@materialcode)),'')
						else @LotNo end

	select @SourceCustomerCode= mdi.SourceCustomerCode from 
			STB_MaterialdocLotInfo mdli with(nolock)
			left outer join STB_MaterialDocInfo mdi  with(nolock) on mdli.MaterialDocNo = mdi.MaterialDocNo
			where  mdli.LotNo=@LotNo
		
	if(@companycode='VVT')  begin 
			   		   
		   	DECLARE @PackDate VARCHAR(12) =''; 

		   --	set @PackDate =  [dbo].[fn_VVT_getdatebyVendorLot](@materialcode,@LotNo) 
				set @PackDate =  [dbo].[fn_VVT_getdatebyVendorLot_MergeCode](@materialcode,@LotNo,isnull(@SourceCustomerCode,'')) 	   			
			if( @PackDate is not null) 
					begin try
										
					 if(replace(isnull(@LotNo,''),' ','')<>'')
						set @ErrorMessage = convert(datetime,@PackDate,120) 
												
						
						UPDATE STB_MaterialDocLotInfo  
						 SET   LotAttr10 =  @PackDate 
						where MaterialDocDetailNo = @MaterialDocDetailNo 
						AND MDLISeqNo = @MDLISeqNo
						


						set @ErrorMessage=''


					end try
					begin catch

						set @ErrorMessage =N'__Không thể chuyển đổi mã Vendor Lot thành ngày tháng. Vui lòng kiểm tra lại: '+isnull(@LotNo,'')
						
					end catch								

			SELECT CONVERT(VARCHAR(900),(CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY MDLISeqNo)) + ' : ' + LotID +' : '+ isnull(LotNo,'')+ isnull(@ErrorMessage,''))) AS BarcodeList
				FROM STB_MaterialDocLotInfo
				WHERE MaterialDocDetailNo = @MaterialDocDetailNo 
												
		end 
	else 
		begin		
		  SELECT CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY MDLISeqNo)) + ' : ' + LotNo AS BarcodeList
			FROM STB_MaterialDocLotInfo
		   WHERE MaterialDocDetailNo = @MaterialDocDetailNo
		end
		
END

