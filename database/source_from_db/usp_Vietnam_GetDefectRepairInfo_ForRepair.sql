
-- =============================================
-- Author:	    MR.TUNG
-- Create date: 2023-08-07
-- Browsable : true
-- Modified:            usp_Vietnam_GetDefectRepairInfo_ForRepair '','','VVT','VVT_F2','','2024-01-01','2024-01-31','VVOJ172R718617','QC_BG'
-- =============================================

--- Mr.Duy : Tìm kiếm không hiển thị đầy đủ ở C321 chỉ là do mã lỗi đó chưa được thêm nhà máy. cập nhật nhà máy thì sẽ hiển thị
CREATE PROCEDURE [dbo].[usp_Vietnam_GetDefectRepairInfo_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	--@pRepairType VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pBarCode VARCHAR(20) = NULL,
	@pIsQC varchar(20)=null
AS
BEGIN
	SET NOCOUNT ON;

	--select * from [SmartFramework].[dbo].[STB_UserTypeBasicPermission] 
	--where usertype='vi_qc'

	--select top 10 * from [SmartFramework].[dbo].stb_usergroup

	DECLARE @CompanyCode VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	DECLARE @FromDate VARCHAR(19) = convert(varchar(10),@pFromDate,120) + ' 10:00:00'
	DECLARE @ToDate VARCHAR(19) = convert(varchar(10),dateadd(day,1,@pToDate),120) + ' 10:00:00'
	--DECLARE @RepairType VARCHAR(20) = CASE WHEN ISNULL(@pRepairType ,'') = '' THEN '*' ELSE @pRepairType END
	DECLARE @BarCode VARCHAR(20) = CASE WHEN rtrim(ltrim(ISNULL(@pBarCode ,''))) = '' THEN '*' ELSE @pBarCode END
	declare @count int = 0;

								
		--select @count = count(*) from stb_materiallotinfo WITH(NOLOCK)  where lotno=@BarCode
		--	if(@count>0) begin
		--		raiserror(N'Lót hàng đã đóng gói, nên không thể nhập thêm lỗi!',16,1);
		--		return;			
		--	end

	IF (rtrim(ltrim(ISNULL(@pBarCode ,''))) <> '' OR @BarCode<>'*') BEGIN  
		set @ToDate=@FromDate
		declare @routecode varchar(20)='';
		declare @defectcode varchar(20)='';
		declare @defectgroupcode varchar(20)='';


		declare @linecodeSI varchar(20)='';
		
		DECLARE @LotNonew1 VARCHAR(20) = ''
		DECLARE @LotNonew2 VARCHAR(20) = ''
		DECLARE @LotNonew3 VARCHAR(20) = ''
		DECLARE @LotNonew4 VARCHAR(20) = ''
		DECLARE @LotNonew5 VARCHAR(20) = ''
		DECLARE @LotNonew6 VARCHAR(20) = ''		

		select @LotNonew1 = NewBarcode
		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
		where OldBarcode=@Barcode; 
	
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
		

		select @BarCode = Barcode, @linecodeSI = InputLineCode 
		from STB_SetInfo   WITH(NOLOCK) 
		where Barcode in (@Barcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
		
			--select @count = count(*) from stb_materiallotinfo WITH(NOLOCK)  where lotno=@BarCode
			--if(@count>0) begin
				--raiserror(N'Lót hàng đã đóng gói, nên không thể nhập thêm lỗi!',16,1);
			--	return;			
			--end

			DECLARE routingtable CURSOR FOR
			--select defectcode,routecode from [dbo].[fn_VVT_QCPARTCODE]() where (flag=@pIsQC or @pIsQC='all')
			select defectcode,defectgroupcode  from STB_DefectInfo  where WorkCenterCode=@WorkCenterCode and (DirectlyUnder=@pIsQC or @pIsQC='all')


			--select routecode+'_00',* from STB_BasicRoutingDetail 
			--where BasicRoutingCode=(	select BasicRoutingCode from STB_ProductionOrderInfo 
			--							WHERE PONO = (SELECT PONO FROM STB_SetInfo WHERE BARCODE='VVNQ073R033530'))
			--AND CompanyCode='VVT'

			OPEN  routingtable 
			FETCH NEXT FROM routingtable  INTO @defectcode, @defectgroupcode
			WHILE @@FETCH_STATUS = 0          
			BEGIN

				select @count = count(*) from STB_DefectRepairInfo  WITH(NOLOCK) 
				where controlno=(SELECT controlno FROM STB_SetInfo  WITH(NOLOCK) WHERE BARCODE=@BarCode)
				and FindRouteCode=@defectgroupcode
				and DefectCode=@defectcode

				if(@count=0) 
					begin try
						exec usp_DoProcessDefectRepairInfoByBarcode_SmartApp '','',@linecodeSI, @defectgroupcode , @BarCode, @defectcode ,0.00001 ,'',''
					end try
					begin catch
						set @count=1
					end catch
				FETCH NEXT FROM routingtable 
					  INTO @defectcode, @defectgroupcode

			END
			CLOSE routingtable              
			DEALLOCATE routingtable	
			--DROP TABLE #routingtable;								
	END



	;WITH DefectRepairInfo AS
	(
		SELECT
				DRI.*
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE
			 (
				@pIsQC='other' and DRI.DefectCode not in (select defectcode from STB_DefectInfo)
						or DRI.DefectCode in (select defectcode from STB_DefectInfo where WorkCenterCode=@WorkCenterCode and (DirectlyUnder=@pIsQC or @pIsQC='all') ) 
			 ) AND 

			(@CompanyCode='*' or DRI.CompanyCode = @CompanyCode) AND 
			(@WorkCenterCode='*' or DRI.WorkCenterCode = @WorkCenterCode) AND 
			(@LineCode='*' or DRI.FindLineCode = @LineCode) AND 
			(DRI.ControlNo = (SELECT controlno FROM STB_SetInfo  WITH(NOLOCK) WHERE BARCODE=@BarCode) 
							or (DRI.CreateDateTime >= @FromDate AND DRI.CreateDateTime <= @ToDate)
			) --AND
			--(@RepairType='*' or DRI.RepairType = @RepairType)  
	)
    SELECT
			DRI.DefectSummaryNo AS OldDefectSummaryNo,
			DRI.DefectSummaryNo,
			DRI.PONo,
			DRI.DayPlanNo,
			SI.Barcode,
			SI.IsLoss,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName AS FindLineName,
			DRI.FindRouteCode,
			RI.RouteName AS FindRouteName,
			DRI.FindSubRouteCode,
			--SRI.SubRouteName AS FindSubRouteName,
			DRI.FindJobdate,
			DRI.FindShiftCode,
			VFSC.[Shift] AS FindShiftName,
			DRI.FindTimeCode,
			DRI.CauseLineCode,
			CLI.LineName AS CauseLineName,
			DRI.CauseShiftCode,
			VCSC.[Shift] AS CuaseShiftName,
			DRI.CauseTimeCode,
			DRI.CauseJobDate,
			DRI.DefectCauseCode,
			DCI.BasicDefectCauseName,
			--CASE 
			--	WHEN ISNULL(DCGL.DefectCauseName,'') = '' THEN DCI.BasicDefectCauseName
			--	ELSE DCGL.DefectCauseName
			--END AS DefectCauseName,
			DRI.DefectCauseDetailCode,
			DRI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			DRI.DutyCostCenterCode,
			DRI.DutyVendorCode,
			CUI.CustomerName AS DutyVendorName,
			----------------------
			--CASE 
			--	WHEN ISNULL(DRI.FindRouteCode,'') = 'V-24' and ISNULL(DRI.DefectQty,'') >= 1 THEN 'V-24_BG' 
			--	ELSE 'V-24_00' 
			--END AS DefectCode,
			-----------------------
			DRI.DefectCode,
			DI.BasicDefectName AS DefectName,
			--CASE
			--	WHEN ISNULL(DLI.DefectName,'') = '' THEN DI.BasicDefectName
			--	ELSE DLI.DefectName
			--END AS DefectName,
			DRI.DefectExtDesc,
			DRI.DefectQty,
			DRI.ControlNo,
			DRI.RepairType,		-- 수리여부
			RT.RepairTypeName,
			DRI.RepairDesc,
			DRI.RepairUserID,
			UI.UserName AS RepairUserName,
			DRI.RepairQty,
			DRI.RepairDateTime,
			ISNULL(DRDI.ProcessQty,0) AS ProcessQty,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,
			--CASE WHEN (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0)) = 0 THEN 0
			--     ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) / (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0)) END AS WasteUnitPrice,
			--dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS TotWastePrice,
			--dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, 1) AS MaterialDcUnitPrice,
			--dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS MaterialDcPrice,
			--dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, 1) AS MaterialPcUnitPrice,
			--dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS MaterialPcPrice,
			DRI.DRIExtText02
	FROM
			DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)
				ON	FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = DRI.FindRouteCode
			LEFT OUTER JOIN STB_LineInfo CLI WITH(NOLOCK)
				ON CLI.LineCode = DRI.CauseLineCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON	DI.DefectCode = DRI.DefectCode
			LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)
			    ON DI.DefectGroupCode = DG.DefectGroupCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON	DCI.DefectCauseCode = DRI.DefectCauseCode
			LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)
				ON	CUI.CustomerCode = DRI.DutyVendorCode
			LEFT OUTER JOIN VW_RepairType RT
				ON	RT.RepairType = DRI.RepairType
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON	DCT.DefectCauseType = DRI.DefectCauseType
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = DRI.RepairUserID
			LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)
				ON	VFSC.ShiftCode = DRI.FindShiftCode
			LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)
				ON	VCSC.ShiftCode = DRI.CauseShiftCode
			LEFT OUTER JOIN
			(
				SELECT
						DRDI.DefectSummaryNo,
						SUM(DRDI.RepairQty) + SUM(DRDI.LossQty) AS ProcessQty	-- SUM(DRDI.DefectQty) MissingQty는 제외
				FROM
						STB_DefectRepairDetailInfo DRDI WITH(NOLOCK)
				WHERE
						DRDI.DefectSummaryNo IN (SELECT DefectSummaryNo FROM DefectRepairInfo)
				GROUP BY
						DRDI.DefectSummaryNo
			) DRDI
				ON DRDI.DefectSummaryNo = DRI.DefectSummaryNo
	WHERE
			--right(DRI.DefectCode,3) in ('_00','_QQ','X03') AND 
			(@CompanyCode='*' or DRI.CompanyCode = @CompanyCode) AND 
			(@WorkCenterCode='*' or DRI.WorkCenterCode = @WorkCenterCode) AND 
			(@LineCode='*' or DRI.FindLineCode = @LineCode) AND 
			--(@RepairType='*' or DRI.RepairType = @RepairType) AND 
			(@BarCode='*' or si.Barcode = @BarCode) 
			
END
