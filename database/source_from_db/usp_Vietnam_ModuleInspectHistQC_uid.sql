
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-13
-- =============================================

CREATE PROCEDURE [dbo].[usp_Vietnam_ModuleInspectHistQC_uid]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20),
						@pLotNo varchar(50)=null,
						@p고객사 varchar(MAX)=null,
						@pModule_Prod_Date datetime=null,
						@ppartnumber varchar(50)=null,
						@pSize_Cell_ varchar(20)=null,
						@pQuantity int=null,

						@pS_JARVIS datetime=null,
						@pS_Quality_Outsourcing_ datetime=null,
						@pS_EMP varchar(50)=null,
						@pS_NG_QTY varchar(20)=null,

						@pE_JARVIS datetime=null,
						@pE_Quality_Outsourcing_ datetime=null,
						@pE_Quality_VN_ nvarchar(MAX)=null,
						@pE_EMP varchar(50)=null,
						@pE_NG_QTY varchar(20)=null,

						@pSD_Quality_VN_ datetime=null,
						@pSD_QTY varchar(20)=null,
						@pSD_NG_QTY varchar(20)=null,
						@pSD_EMP varchar(50)=null
								
AS
BEGIN

	SET NOCOUNT ON;

	--declare @tung varchar(200) = convert(varchar(20), @pLotNo, 120 ) + '-' + convert(varchar(20), @pS_Quality_Outsourcing_, 120 )
	--raiserror (@tung, 16 , 1)
	declare @cnt INT=0
	
	--select*from stb_vietnam_module_inpectionhist
	
	if(@pLotNo is null or @pLotNo ='' or @pProcessUserID='nguyentung')
		begin
			declare @tung1 varchar(MAX) = 'LotNo is empty, please input the LotNo' +  convert(varchar(20), @pS_JARVIS, 120 ) + '-' + convert(varchar(20), @pS_Quality_Outsourcing_, 120 )
			--raiserror(@tung1, 16, 1)
			--return
		end
	

	select @cnt = count(*) 
	from stb_vietnam_module_inpectionhist with(nolock)
	where Lotno = @pLotNo
	

	declare  @result varchar(10) = (case when @pS_JARVIS is not null 
								and @pS_Quality_Outsourcing_  is not null 
								and  @pE_JARVIS is not null 
								and @pE_Quality_Outsourcing_  is not null 
								and  @pSD_Quality_VN_ is not null then 'PASS' else '' end )


	if(@cnt=0)

		INSERT INTO [dbo].[STB_Vietnam_Module_InpectionHist] 
		       ([LotNo], [고객사] ,[S_JARVIS] ,[S_Quality_Outsourcing_] ,[E_JARVIS] ,[E_Quality_Outsourcing_] ,[E_Quality_VN_] ,[SD_Quality_VN_] ,[SD_QTY], Result
			   ,Module_Prod_Date, partno , size , lotqty ,  S_EMP , S_NG_QTY ,  E_EMP , E_NG_QTY ,  SD_NG_QTY , SD_EMP ) 
		VALUES (@pLotNo, @p고객사, @pS_JARVIS, @pS_Quality_Outsourcing_, @pE_JARVIS, @pE_Quality_Outsourcing_, @pE_Quality_VN_, @pSD_Quality_VN_, @pSD_QTY, @result
				,@pModule_Prod_Date , @ppartnumber , @pSize_Cell_ , @pQuantity  , @pS_EMP , @pS_NG_QTY  , @pE_EMP , @pE_NG_QTY  , @pSD_NG_QTY , @pSD_EMP )

	else 		

		UPDATE [dbo].[STB_Vietnam_Module_InpectionHist]
		   SET 
			   [S_JARVIS] = @pS_JARVIS
			  ,[고객사] = @p고객사
			  ,[S_Quality_Outsourcing_] = @pS_Quality_Outsourcing_
			  ,[E_JARVIS] = @pE_JARVIS
			  ,[E_Quality_Outsourcing_] = @pE_Quality_Outsourcing_
			  ,[E_Quality_VN_] = @pE_Quality_VN_
			  ,[SD_Quality_VN_] = @pSD_Quality_VN_
			  ,[SD_QTY] = @pSD_QTY
			  ,Result = @result
			  ,	Module_Prod_Date	 = @pModule_Prod_Date 
			,	partno			 = @ppartnumber		
			,	size			 = 	@pSize_Cell_			
			,	lotqty			 = @pQuantity		
					   
			,	S_EMP			 = 	@pS_EMP			
			,	S_NG_QTY		 = 	@pS_NG_QTY		
							   
			,	E_EMP			 = 	@pE_EMP			
			,	E_NG_QTY		 = 	@pE_NG_QTY		
					   
			,	SD_NG_QTY		 = 	@pSD_NG_QTY		
			,	SD_EMP			 = @pSD_EMP		
			  --,[Result] = case when () then 'PASS' else Result end 
		 WHERE  Lotno = @pLotNo;


		 --update [STB_Vietnam_Module_InpectionHist] 
		 --set Result = (case when S_JARVIS is not null 
			--					and S_Quality_Outsourcing_  is not null 
			--					and  E_JARVIS is not null 
			--					and E_Quality_Outsourcing_  is not null 
			--					and  SD_Quality_VN_ is not null then 'PASS' else Result end)
			

END

