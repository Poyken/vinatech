-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlStituation_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@ptype			 varchar (20) = NULL,
	@pdecisiondate	 datetime  = NULL,
	@pholding_Date	 datetime  = NULL,
	@pmodelcode			 varchar (20)= NULL,
	@pmodelname			 varchar (200)= NULL,
	@plotno				 varchar (20) = NULL,
	@ppic				 varchar (50) =NULL,
	@preason			 nvarchar (max)= NULL,
	@plocation			 varchar (30)= NULL,
	@pwip				  nvarchar (max)= NULL,
	@ppackingid			  varchar (20)= NULL,
	@pcreatedatetime			  datetime  =NULL,
	@pcreateuserid			 varchar (50) =NULL
	       , @pline           varchar (50) =NULL
           , @ptechnical 	  varchar (50) =NULL
           , @pquantity 	  INT =NULL
           , @pDeptIC 		  varchar (50) =NULL
           , @pExpecteddate   datetime =NULL
           , @pRealdate 	  datetime =NULL
           , @pDeptProcess 	  varchar (50) =NULL
           , @pProcedures 	  nvarchar (MAX) =NULL
           , @pOkQty 		  INT =NULL
           , @pNgQty 		  INT =NULL
           , @pOther  		 nvarchar (max)= NULL
           , @pStatus		 varchar (50) =NULL
		   , @pSize		 varchar (50) =NULL
	,@pFileName NVARCHAR(255) = null
	,@pFileSize BIGINT  = null
    ,@pFileData VARBINARY(MAX) = null
	,@pHoldFileID INT = null
	,@poldlotno				 varchar (20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	declare @count INT = 0
	set @plotno = ltrim(rtrim(@plotno))

	declare @siextint1 INT = 0
	if (@ptype='Hold' or @ptype='Reject') begin
		select @siextint1 = 1
	end


	DECLARE @LotNoneww VARCHAR(20) = ''
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@plotno 
	
	select @LotNonew2 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1 

	select @LotNonew3 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2 

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 


	select @count=count(*) , @LotNoneww = Barcode
	from STB_SetInfo 
	where Barcode in (@plotno,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
	group by barcode;

	if(@count=0 and @plotno not like '%.')begin	
		declare  @eee1 nvarchar(500) = N'Mã Lót không có trong hệ thống, nếu bạn vẫn muốn lưu lại, thì thêm 1 dấu chấm (.) vào sau mã Lót này'+@plotno;
		raiserror (@eee1,16,1);
		return;
	end


	if(isnull(@pline,'')='') begin
		select count(*) from STB_SetInfo 
		where Barcode =@LotNoneww;
		if(@@ROWCOUNT>0)select @pline=InputLineCode from STB_SetInfo 
		where Barcode  =@LotNoneww;
	end

	if(isnull(@pmodelcode,'')='') begin
		select count(*)  from STB_SetInfo 
		where Barcode  =@LotNoneww;
		if(@@ROWCOUNT>0)select @pmodelcode=MaterialCode from STB_SetInfo 
		where Barcode  =@LotNoneww;
	end

	if(isnull(@pmodelname,'')='') begin
		select count(*)  from STB_ModelBasicInfo where ModelCode=@pmodelcode;
		if(@@ROWCOUNT>0)select @pmodelname=ModelName from STB_ModelBasicInfo where ModelCode=@pmodelcode;
	end

	if(isnull(@ptechnical,'')='') begin  
		select count(*) 
		from STB_ModelBasicInfo where ModelCode = (select MaterialCode from STB_SetInfo  where Barcode  =@LotNoneww)

		if(@@ROWCOUNT>0)select @ptechnical=(MBIExtText04+'V - '+MBIExtText05+'F')
		from STB_ModelBasicInfo where ModelCode = (select MaterialCode from STB_SetInfo  where Barcode  =@LotNoneww)
	end
	
	if(isnull(@pSize,'')='') begin
		select count(*) 
		from STB_ModelBasicInfo where ModelCode = (select MaterialCode from STB_SetInfo  where Barcode  =@LotNoneww)

		if(@@ROWCOUNT>0)select @pSize=('' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '')
		from STB_ModelBasicInfo where ModelCode = (select MaterialCode from STB_SetInfo  where Barcode  =@LotNoneww)
	end


	if(@pFileData is not null) begin
		EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'stb_hodl_situationVVT',
							@pFileContents = @pFileData,
							@pFileName = @pFileName,
							@pFileSize = @pFileSize,
							@pUserID = @pProcessUserID,
							@pFileID = @pHoldFileID OUTPUT
	end

	if(@plotno<>@poldlotno and @poldlotno is not null and ltrim(rtrim(@poldlotno))<>'' ) begin
		update stb_hodl_situationVVT
		set [type]			= isnull(@ptype			,[type]			)	,
		[decisiondate]	= isnull(isnull(@pholding_Date,@pdecisiondate)	,[decisiondate]	),
		[modelcode]		= isnull(@pmodelcode		,[modelcode]		),
		[modelname]		= isnull(isnull(@pSize,@pmodelname) ,[modelname]		),
		[lotno]			= isnull(@plotno			,[lotno]			)	,
		[pic]			= isnull(@ppic			,[pic]			),
		[reason]		= isnull(@preason		,[reason]		),
		[location]		= isnull(@plocation		,[location]		),
		[wip]			= isnull(@pwip			,[wip]			),
		[packingid]		= isnull(@ppackingid		,[packingid]		),
		[createdatetime]= getdate(),

		[createuserid]	  = isnull(@pProcessUserID,[createuserid]  )
		   ,[line]		  = isnull(@pline        , [line]		  )
           ,[technical]	  = isnull(@ptechnical 	 ,[technical]	  )
           ,[quantity]	  = isnull(@pquantity 	 ,[quantity]	  )
           ,[DeptIC]	  = isnull(@pDeptIC 	 ,	[DeptIC]	  )
           ,[Expecteddate]= isnull(@pExpecteddate, [Expecteddate])
           ,[Realdate]	  = isnull(@pRealdate 	 ,[Realdate]	  )
           ,[DeptProcess] = isnull(@pDeptProcess , [DeptProcess] )
           ,[Procedures]  = isnull(@pProcedures  ,	[Procedures]  )
           ,[OkQty]		  = isnull(@pOkQty 		 ,[OkQty]		  )
           ,[NgQty]		  = isnull(@pNgQty 		 ,[NgQty]		  )
           ,[Other]		  = isnull(@pOther  	 ,	[Other]		  )
           ,[Status]	  = isnull(@pStatus		 ,[Status]	  )
		   ,HoldFileID	  = isnull(@pHoldFileID  ,HoldFileID	  )
		where lotno=@poldlotno and id = (select max(id) from stb_hodl_situationVVT where lotno=@poldlotno )

		update stb_hodl_situationVVT 
		set lotno='del_'+lotno
		where lotno=@poldlotno

	end
	else begin
	SET IDENTITY_INSERT dbo.stb_hodl_situationVVT OFF;  
	insert into stb_hodl_situationVVT(
		[type]			,
		[decisiondate]	,
		[modelcode]		,
		[modelname]		,
		[lotno]			,
		[pic]			,
		[reason]		,
		[location]		,
		[wip]			,
		[packingid]		,
		[createdatetime],
		[createuserid]	
		   ,[line]
           ,[technical]
           ,[quantity]
           ,[DeptIC]
           ,[Expecteddate]
           ,[Realdate]
           ,[DeptProcess]
           ,[Procedures]
           ,[OkQty]
           ,[NgQty]
           ,[Other]
           ,[Status]
		   ,HoldFileID
		)
	values (
		@ptype			,
		isnull(@pholding_Date,@pdecisiondate)	,
		@pmodelcode		,
		isnull(@pSize,@pmodelname) ,
		@plotno			,
		@ppic			,
		@preason		,
		@plocation		,
		@pwip			,
		@ppackingid		,
		getdate(),
		@pProcessUserID
		, @pline         
		, @ptechnical 	
		, @pquantity 	
		, @pDeptIC 		
		, @pExpecteddate 
		, @pRealdate 	
		, @pDeptProcess 	
		, @pProcedures 	
		, @pOkQty 		
		, @pNgQty 		
		, @pOther  		
		, @pStatus		
		, @pHoldFileID
	);
	end
	--SET IDENTITY_INSERT dbo.stb_hodl_situationVVT ON; 

	update STB_SetInfo
	set SIExtInt01 = @siextint1
	where Barcode   =@LotNoneww and (Barcode like 'V%' or Barcode like 'MV%');

	select @count = count(*) from STB_MaterialQcInfo
	where MaterialQcNo   =@LotNoneww or MaterialQcNo=@plotno;

	if(@count=0  and @plotno not like '%.' and @plotno not like '%-')
		exec usp_DoCreateOqcInfoForLotByOne_VNT 
					@pProcessUserID=@pProcessUserID,
					@pProcessLanguage=@pProcessLanguage,
					@pBarcode =@LotNoneww;

	update STB_MaterialQcInfo
	set DecisionDateTime = getdate(), 
	DecisionResult = case when  @ptype='Reject' then 'Reject' when @ptype='Hold' then 'Hold' else 'None' end, 
	DecisionUserID = @ppic
	where   ( (MaterialQcNo  =@LotNoneww and InspectionDocType='OQC' ) or  
			(stuff(MaterialQcNo,1,1,'')   =@LotNoneww and InspectionDocType='FOQC' )  )
	and (MaterialQcNo  like 'V%' or MaterialQcNo  like 'MV%');

END


--SELECT*FROM
--STB_MaterialQcInfo
--WHERE  MaterialQcNo='VVMQ133R033511'

