

CREATE PROCEDURE [dbo].[usp_Set_VVT_Info_get]
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pUtcOffset INT=null,
				@pPONo VARCHAR(20) = NULL,
				@pDayPlanNo VARCHAR(20) = NULL,
				@pLabelType NVARCHAR(30) = NULL,
				@pLotNo VARCHAR(20) = NULL,
				@pInputLineCode VARCHAR(20) = NULL,
				@pPN VARCHAR(100) = NULL,
				@pDC VARCHAR(100) = NULL,
				@pMPN VARCHAR(100) = NULL,
				@pInvoice VARCHAR(30) = NULL,
				@pDATEe	  VARCHAR(30) = NULL,
				@pLotQty  VARCHAR(30) = NULL,
				@pPktQty  NVARCHAR(100) = NULL,
				@pisOuter BIT=null,
				@pWithrev NVARCHAR(50) = NULL,
				@pSapCode NVARCHAR(50) = NULL
			
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo	
	DECLARE @LotNo VARCHAR(20) = @pLotNo
	DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '%' ELSE @pDayPlanNo END
	DECLARE @LabelType NVARCHAR(30) = 'AssembleLabel'
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''


	if( @pProcessUserID  in ('sieusao','transao','','daohuong','nguyentha','32107013','32210006','nguyennha','HaiTrieu',N'NGUYỄN THỊ XUYÊN','hant-1998','31905002') ) begin
	
		if(@pPN <>'' and @pPN is not null and @pDC is not null and @pMPN is not null ) begin
		  select @pPN as HH,
			@pDC as DC,
			@pMPN as MPN,
			 'Report' as CommandType,
			 'foxconlabel' as FormatName,
			 'VVT_TemKhachH1' as LabelType,			
			 ''PrinterName,
			 1 as LabelQty 
			
	     end
		 else 
		 if(@pInvoice <>''  and @pInvoice is not null and @pDATEe is not null and @pLotQty is not null and @pPktQty is not null AND @pWithrev IS NOT NULL AND @pSapCode IS NOT NULL ) begin
		 	select @pisOuter isOuter,
			    @pInvoice as invoice  ,
				@pDATEe	  as Date1	  ,
				@pLotQty  as LotQty   ,
				@pPktQty  as packqty   ,
				@pWithrev as Withrev  ,
				@pSapCode as SapCode,
			 'Report' as CommandType,
			 'CustomerGenusPower' as FormatName,
			 'CustomerGenusPower' as LabelType,			
			 '' PrinterName,
			 1 as LabelQty 
		 end

		  return;
	end




	if  (@pInputLineCode is not null and @pInputLineCode<>'')   begin 		
		if (@pProcessUserID like '%phuong%' or @pProcessUserID like 'mrluan' or @pProcessUserID like 'punthao' or @pProcessUserID='nguyennha' or @pProcessUserID='dangchinh' or @pProcessUserID='32205024' or @pProcessUserID='anhduy157'or @pProcessUserID=N'NGUYỄN THỊ XUYÊN'or @pProcessUserID='hant-1998'or @pProcessUserID='31905002' or @pProcessUserID='DinhManh') begin 

			update STB_ProdRouteHist 
			set LineCode = @pInputLineCode 
			where ControlNo = (select ControlNo from STB_SetInfo  where Barcode = @pLotNo) 

			update STB_DefectRepairInfo 
			set FindLineCode = @pInputLineCode 
			where ControlNo = (select ControlNo from STB_SetInfo  where Barcode = @pLotNo) 

			update STB_SetInfo 
			set InputLineCode = @pInputLineCode 
			where Barcode = @pLotNo				
			



			DECLARE @oldPONo VARCHAR(20)
			select @oldPONo = PONo
			from STB_SetInfo
			where Barcode = @pLotNo

			DECLARE @validPO VARCHAR(20)
			select @validPO = PONo
			from STB_ProductionOrderInfo
			where PONo = @PONo 
			and CreateDateTime >= dateadd(DAY,-31,getdate()) and CreateDateTime <= dateadd(DAY,31,getdate()) 
			and case when DATEPART(DAY,getdate())>25 then DATEPART(MONTH,getdate())+1 else DATEPART(MONTH,getdate()) end
			 =  case when DATEPART(DAY,CreateDateTime)>25 then DATEPART(MONTH,CreateDateTime)+1 else DATEPART(MONTH,CreateDateTime) end	  
			and MaterialCode = (select MaterialCode from STB_SetInfo  where Barcode = @pLotNo) 



				if(@PONo is not null and @PONo<>'' and @PONo<>@oldPONo and @PONo=@validPO) begin
			
					update
					STB_SetInfo
					set PONo=@PONo
					where barcode = @pLotNo	

					update STB_ProdRouteHist 
					set RouteCode=stuff(RouteCode,1,1,'V'), PONo=@PONo
					where   RouteCode=(
								select max(RouteCode) from  STB_ProdRouteHist  where RouteCode not in ('E-28','V-28','V-28_BG')
								and ControlNo = (select ControlNo from STB_SetInfo  where Barcode = @pLotNo) 
							)
					and ControlNo = (select ControlNo from STB_SetInfo  where Barcode = @pLotNo) 
				end


		end 
		else 
		begin 
			declare @kodcphep varchar(100)= 'Ban khong duoc phep thay doi ma Line'; 
			raiserror (@kodcphep,16,1); 
		end 
		return; 
	end 







	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNo 
	
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
	

	;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()
	), MainAssemble AS
	(
		SELECT
				MAPI.ControlNo,
				COUNT(*) AS AssmCount
		FROM
				STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
		WHERE
				MAPI.ControlNo IN (
									SELECT 
											ControlNo 
									FROM 
											STB_SetInfo SI WITH(NOLOCK) 
									WHERE
											SI.Barcode = @LotNo 
											--AND SI.PONo = @PONo 
											--AND SI.DayPlanNo LIKE @DayPlanNo
								)
		GROUP BY
				MAPI.ControlNo
	)
	SELECT
			@pLotNo AS OldControlNo,
			SI.ControlNo,
			SI.PONo,
			SI.PONo as Now_PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			MM.MaterialName,
			SI.SetSeq,
			SI.IsLineInput,
			SI.IsLoss,
			SI.IsDefect,
			SI.CurrentRouteCode,
			SI.InternalProdNo,
			SI.OutSetNo,
			SI.OutSetNoSeq,
			SI.Barcode,
			--SI.Barcode AS LotNo,
			'VVT' as CompanyCode,
			'VVT_F1' as WorkCenterCode,
			SUBSTRING(SI.Barcode, 16, 3) AS Cutno ,
			SI.InputLineCode,
			LI.LineName,
			dbo.fnGetLocalTime(SI.InputJobDate, @pUtcOffset) AS InputJobDate,
			SI.InputShiftCode,
			dbo.fnGetLocalTime(SI.InputDateTime, @pUtcOffset) AS InputDateTime,
			SI.DefectQty,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.SalesOrderNo,
			SI.SOISequence,
			SI.IsOutboundFinalInspection,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotCreateDateTime,
			SI.LotDecisionResult,
			SI.GradeCode,
			SI.GradeChangeJobDate,
			SI.GradeChangeShiftCode,
			SI.GradeChangeDateTime,
			SI.GradeChangeUserID,
			SI.GradeModelCode,
			SI.GradeChangeSetNo,
			SI.PrintDate,
			SI.LineOutTactTime,
			SI.ProdQty,
			SI.SIExtText01,
			SI.SIExtText02,
			SI.SIExtText03,
			SI.SIExtText04,
			SI.SIExtText05,
			SI.SIExtInt01,
			SI.SIExtInt02,
			SI.SIExtInt03,
			SI.SIExtInt04,
			SI.SIExtInt05,
			SI.SIExtReal01,
			SI.SIExtReal02,
			SI.SIExtReal03,
			SI.SIExtReal04,
			SI.SIExtReal05,
			SI.CreateDateTime,
			--SI.CreateUserID,
			( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU  WITH(NOLOCK) WHERE SU.UserID = SI.CreateUserID) AS CreateUserID,
			SI.ChangeDateTime,
			SI.ChangeUserID,
			SUBSTRING(SI.Barcode,10,2) AS MixBatchNo,
			SUBSTRING(SI.Barcode,12,1) AS EDLC,
			0 AS LabelQty,
			LBI.CommandType,
			LBI.FormatName,
			LBI.LabelType,
			--isnull(LBI.CommandType,'Report') as CommandType ,
			--isnull(LBI.FormatName,'조립라벨') AS FormatName,
			--isnull(LBI.LabelType,'Treelabel') as LabelType,
			LBI.PrinterName,
			MA.AssmCount,
			MBI.MBIExtText04 + '(V)-' + MBIExtText05 + '(F)' AS ItemSpec,
			LotUniqueNumber,
			LI.LineCode,
			LI.LineName AS LineNameDPP,
			MBI.MBIExtText03 AS ModelType,
			MBI.MBIExtText04 AS ModelVolt,
			MBI.MBIExtText05 AS ModelFarad
       FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)			    ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)			ON MLI.ModelCode = SI.MaterialCode        AND MLI.LabelType = @LabelType
			LEFT OUTER JOIN LabelInfo LBI		 WITH(NOLOCK) 		    ON LBI.LabelType = @LabelType             AND LBI.FormatName = MLI.FormatName     AND LBI.RankIndex = 1
			LEFT OUTER JOIN MainAssemble MA		 WITH(NOLOCK) 		    ON MA.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)			ON SI.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)            ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_LineInfo LI2 WITH(NOLOCK)			    ON LI2.LineCode = DPP.LineCode
	   
	   WHERE 1=1
	   and SI.Barcode in (@LotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
		--AND SI.PONo = @PONo 
		--AND SI.DayPlanNo LIKE @DayPlanNo

	ORDER BY SI.ControlNo

END





































