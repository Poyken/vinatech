-- ==================================================================
-- Author      : Mr.Tung
-- Create date : 2020-08
-- =========================================================================================================
CREATE PROC [dbo].[usp_Vietnam_ESR_growup_dayByday_uid]
				@pProcessUserID				Varchar(20),
				@pProcessLanguage			Varchar(20),
				@pCompanyCode				Varchar(20),				
				@pLotNo						varchar(50)  = NULL,
				@pFarad						varchar(10) = NULL,
				@pproductdate				datetime = NULL,
				@pprodqty					numeric(10, 0) = NULL,
				@pESR_OQC_Date				datetime = NULL,
				@pESR_Result				varchar(10) = NULL,
				@pmodelcode					varchar(30) = NULL,
				@pmodelname					varchar(200) = NULL,
				@pESR_TQC_Date				datetime = NULL,
				@pT_ESR_Result				numeric(20, 5) = NULL,
				@pInternalSpec				numeric(10, 2) = NULL,
				@pEstimatedArivalDateofIS	datetime = NULL,
				@pCustomerSpec				numeric(10, 2) = NULL,
				@pEstimatedArivalDateofCS	datetime = NULL,
				@pId						INT = Null,
				@pMaterialQcSampleNo		INT = Null,
				@pMaterialQcDetailNo		INT = Null
				--,
				--@pSize             Varchar(20) = null,
				--@pFarad            Varchar(20) = null,
				--@pLotNo            Varchar(20) = null,
				--@pFromDate  Datetime = null,
				--@pFromTo    Datetime = null

AS

BEGIN

	SET NOCOUNT ON;	


	declare @cnt INT=0;
	declare @cnt2 INT=0;

	select @cnt = count(*) 
	from STB_Vietnam_ESRgrowup_dayByday with(nolock)
	where Lotno = @pLotNo AND MaterialQcDetailNo=@pMaterialQcDetailNo AND MaterialQcSampleNo=@pMaterialQcSampleNo;


	--select @cnt2 = count(*)
	--from STB_MaterialQcSampleResult
	--where MaterialQcNo = @pLotNo and MaterialQcDetailNo=@pMaterialQcDetailNo


	if(@cnt<=0)
	begin
		insert STB_Vietnam_ESRgrowup_dayByday
		(LotNo, Farad , productdate , prodqty , ESR_OQC_Date , ESR_Result , modelcode , modelname , ESR_TQC_Date , 	T_ESR_Result , 
		InternalSpec , EstimatedArivalDateofIS , CustomerSpec , EstimatedArivalDateofCS , CreateUserId,MaterialQcSampleNo,MaterialQcDetailNo )
		values 
		(@pLotNo, @pFarad , @pproductdate , @pprodqty , @pESR_OQC_Date , @pESR_Result , @pmodelcode , @pmodelname , @pESR_TQC_Date , @pT_ESR_Result , 
		@pInternalSpec , @pEstimatedArivalDateofIS , @pCustomerSpec , @pEstimatedArivalDateofCS , @pProcessUserID,@pMaterialQcSampleNo,@pMaterialQcDetailNo);
	end
	else
	begin
		select @pInternalSpec = case when @pInternalSpec is null or @pInternalSpec=0  then NULL else @pInternalSpec end
		select @pEstimatedArivalDateofIS = case when @pT_ESR_Result is null or @pT_ESR_Result=0  then NULL else @pEstimatedArivalDateofIS end
		select @pCustomerSpec = case when @pCustomerSpec is null or @pCustomerSpec=0  then NULL else @pCustomerSpec end
		select @pEstimatedArivalDateofCS = case when @pT_ESR_Result is null or @pT_ESR_Result=0  then NULL else @pEstimatedArivalDateofCS end
		--select @pT_ESR_Result = case when @pT_ESR_Result is null or @pT_ESR_Result=0 then NULL else @pT_ESR_Result end

		update STB_Vietnam_ESRgrowup_dayByday
		set
		Farad						= isnull(@pFarad		,Farad			)		,	
		productdate					= isnull(@pproductdate	,productdate	)			,
		prodqty						= isnull(@pprodqty		,prodqty		)			,
		ESR_OQC_Date				= isnull(@pESR_OQC_Date	,ESR_OQC_Date	)	,	
		ESR_Result					= isnull(@pESR_Result	,ESR_Result		)		,
		modelcode					= isnull(@pmodelcode	,modelcode		)		,	
		modelname					= isnull(@pmodelname	,modelname		)		,	
		ESR_TQC_Date				= isnull(@pESR_TQC_Date	,ESR_TQC_Date	)	,	
		T_ESR_Result				= @pT_ESR_Result	,--,T_ESR_Result	)	,	
		InternalSpec				= @pInternalSpec,
		EstimatedArivalDateofIS		= @pEstimatedArivalDateofIS,
		CustomerSpec				= @pCustomerSpec		,	
		EstimatedArivalDateofCS		= @pEstimatedArivalDateofCS,
		CreateUserId				= isnull(@pProcessUserID	,CreateUserId)			
		where LotNo=@pLotNo and id = @pid;
	end	
END




--USE [SmartFactoryV2]
--GO

--/****** Object:  Table [dbo].[STB_Vietnam_ESRgrowup_dayByday]    Script Date: 2021-06-23 오후 1:31:15 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[STB_Vietnam_ESRgrowup_dayByday](
--	[id] [int] IDENTITY(1,1) NOT NULL,
--	[LotNo] [varchar](50) NOT NULL,
--	[Farad] [varchar](10) NULL,
--	[productdate] [datetime] NULL,
--	[prodqty] [numeric](10, 0) NULL,
--	[ESR_OQC_Date] [datetime] NULL,
--	[ESR_Result] [varchar](10) NULL,
--	[modelcode] [varchar](30) NULL,
--	[modelname] [varchar](200) NULL,
--	[ESR_TQC_Date] [datetime] NULL,
--	[T_ESR_Result] [numeric](10, 2) NULL,
--	[InternalSpec] [numeric](10, 2) NULL,
--	[EstimatedArivalDateofIS] [datetime] NULL,
--	[CustomerSpec] [numeric](10, 2) NULL,
--	[EstimatedArivalDateofCS] [datetime] NULL,
--	[CreateDateTime] [datetime] NULL,
--	[CreateUserId] [varchar](20) NULL,
--	[MaterialQcSampleNo] [int] NULL,
--	[MaterialQcDetailNo] [int] NULL
--) ON [PRIMARY]
--GO

--ALTER TABLE [dbo].[STB_Vietnam_ESRgrowup_dayByday] ADD  CONSTRAINT [DF_STB_Vietnam_ESRgrowup_dayByday_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
--GO































--select mli.*from STB_MaterialLotInfo mli
--left outer join STB_MaterialDocLotInfo  mdli on  mli.LotID = mdli.lotid
--left outer join STB_MaterialDocDetail  mdd on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
--left outer join STB_MaterialDocInfo mdi on mdi.MaterialDocNo = mdd.MaterialDocNo
--where mli.MaterialCode in ('GBHNAC-042','GADACB-V01') and MaterialWarehouseCode='ROH_VN_WH'




--select *from STB_MaterialLotInfo
--where MaterialCode in ('GBHNAC-042') and MaterialWarehouseCode='ROH_VN_WH'




--select*from
--STB_MaterialDocLotInfo mli
--where mli.ChangeUserID='nguientung' or mli.lotid in (
--										select lotid from
--											STB_MaterialLotInfo
--											where materialcode in (
--											'GBAKAC-049',
--											'GBAKAC-050',
--											'GBAKAC-052',
--											'GBAKAC-051',
--											'GBAKAC-053',
--											'GBAKAC-048',
--											'GBAKAC-054',
--											'GBAKAC-039',
--											'GBCP00-002' 
--											) and MaterialWarehouseCode='ROUTE_VN_WH' and ChangeDateTime>'2021-05-18 17:00:00')




--update  STB_MaterialDocLotInfo  
--set MaterialCode = mli.materialcode
--from STB_MaterialDocLotInfo mdli
--left outer join  STB_MaterialLotInfo mli  on   mli.LotID = mdli.LotID
--where mli.ChangeUserID='nguientung' or mli.lotid in (
--										select lotid from
--											STB_MaterialLotInfo
--											where materialcode in (
--											'GBAKAC-049',
--											'GBAKAC-050',
--											'GBAKAC-052',
--											'GBAKAC-051',
--											'GBAKAC-053',
--											'GBAKAC-048',
--											'GBAKAC-054',
--											'GBAKAC-039',
--											'GBCP00-002'
--											) and MaterialWarehouseCode='ROUTE_VN_WH' and ChangeDateTime>'2021-05-18 17:00:00')







--select mdd.*
--from STB_MaterialDocLotInfo mdli
--left outer join  STB_MaterialLotInfo mli  on   mli.LotID = mdli.LotID
--left outer join STB_MaterialDocDetail  mdd on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
--where mli.ChangeUserID='nguientung' or mli.lotid in (
--										select lotid from
--											STB_MaterialLotInfo
--											where materialcode in (
--											'GBAKAC-049',
--											'GBAKAC-050',
--											'GBAKAC-052',
--											'GBAKAC-051',
--											'GBAKAC-053',
--											'GBAKAC-048',
--											'GBAKAC-054',
--											'GBAKAC-039',
--											'GBCP00-002'
--											) and MaterialWarehouseCode='ROUTE_VN_WH' and ChangeDateTime>'2021-05-18 17:00:00')


--update  STB_MaterialDocDetail  
--set MaterialCode = mli.materialcode
--from STB_MaterialDocLotInfo mdli
--left outer join  STB_MaterialLotInfo mli  on   mli.LotID = mdli.LotID
--left outer join STB_MaterialDocDetail  mdd on mdd.MaterialDocDetailNo = mdli.MaterialDocDetailNo
--where mli.ChangeUserID='nguientung' or mli.lotid in (
--										select lotid from
--											STB_MaterialLotInfo
--											where materialcode in (
--											'GBAKAC-049',
--											'GBAKAC-050',
--											'GBAKAC-052',
--											'GBAKAC-051',
--											'GBAKAC-053',
--											'GBAKAC-048',
--											'GBAKAC-054',
--											'GBAKAC-039',
--											'GBCP00-002'
--											) and MaterialWarehouseCode='ROUTE_VN_WH' and ChangeDateTime>'2021-05-18 17:00:00')




