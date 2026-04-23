
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-18
-- Description:	납품서 입하 처리를 합니다.   (자재입고 > 자재입고관리 > 자재입고 및 라벨발행 > 입하처리버튼 )

-- exec [usp_DoArriveMaterialDelivery] 'Korean', 'kilee', '200407000169', ''
-- exec [usp_DoArriveMaterialDelivery] 'Korean', 'kilee', '230622000267', ''

/*
SELECT *
  FROM STB_MaterialDocInfo
 WHERE MaterialDocNo = '230622000267'

UPDATE STB_MaterialDocInfo
   SET DocStatus = 'CREATE'
 WHERE MaterialDocNo = '230622000267'
*/
-- =============================================

CREATE PROCEDURE [dbo].[usp_DoArriveMaterialDelivery]
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pMaterialDocNo VARCHAR(20),
						@pIsFinished BIT = 0 OUTPUT
AS

BEGIN

--raiserror('check',16,1)
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			    @IsRequireIQC BIT,
			    @IsRequireApproval BIT,
			    @ErrorMessage NVARCHAR(MAX),
				@CompanyCode VARCHAR(20),
				@DecisionResultIQC varchar(50)

	/* -- Chặn khi bị đánh giá NG
				SELECT DISTINCT 
				@DecisionResultIQC = MQI.DecisionResult
			FROM
				STB_MaterialDocDetail MDD WITH(NOLOCK)
				INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
				INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
				INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      
	where  MDD.MaterialDocNo=@MaterialDocNo
			Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo ,MQI.DecisionResult

	if(@DecisionResultIQC = 'Reject')
	begin
		RAISERROR(N'Lô hàng đã bị QC đánh NG' ,16, 1)  
		return 
	end
	*/



	DECLARE @TotPickingAssignQty NUMERIC(20,5)
	      , @TotRequestQty        NUMERIC(20,5)
		  , @MDDExtBit01 BIT


	EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
											@pProcessUserID     = @ProcessUserID,
											@pMaterialDocNo    = @MaterialDocNo

	IF @@ERROR <> 0 
	
	BEGIN
		RETURN
	END

	DECLARE @DocStatus VARCHAR(20)

	SELECT
			@DocStatus = MDI.DocStatus,
			@IsRequireIQC = MDT.IsRequireQC,
			@IsRequireApproval = MDT.IsRequireApproval
	FROM
			                STB_MaterialDocInfo MDI
			INNER JOIN STB_MaterialDocType MDT			ON	MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	PRINT '1'
	-- 요청수량의 합과 입하수량의 합을 비교
	SELECT @TotRequestQty        = SUM(RequestQty)
	     , @TotPickingAssignQty = SUM(PickingAssignQty) 
		 , @MDDExtBit01 = ISNULL(CONVERT(BIT, MAX(CONVERT(INT, MDDExtBit01))), CONVERT(BIT, 0))
	  FROM STB_MaterialDocDetail
	 WHERE MaterialDocNo = @MaterialDocNo



	 PRINT '2'
	 ---- TEST용 주석처리 
		--	select RequestQty                                  -- 요청수량
		--	, PickingAssignQty                           -- 입하수량
		--	, *
		--from STB_MaterialDocDetail
		--where 1=1
		--   and MaterialDocNo = '200407000169'




	 IF @TotRequestQty <> @TotPickingAssignQty 
	 
	 BEGIN
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
													@pName = '^요청수량의 합과 입하수량의 합이 일치하지 않습니다.^',
													@pValue = @ErrorMessage OUTPUT
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	 END



	IF @DocStatus = 'ARRIVAL' 
	
	BEGIN
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^이미 입하처리가 되었습니다.^',
										@pValue = @ErrorMessage OUTPUT
		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @IsRequireApproval = 1 
	
	BEGIN	
		IF @DocStatus NOT IN ('APPROVED','REFUSED') 
		
		BEGIN
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^결제가 완료되지 않았습니다.^',
											@pValue = @ErrorMessage OUTPUT
			RAISERROR(@ErrorMessage,16,1)
			RETURN
	    END

		IF @DocStatus = 'REFUSED' 
		
		BEGIN
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^결재가 반려되었습니다.^',
											@pValue = @ErrorMessage OUTPUT
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END

	END

	UPDATE
			STB_MaterialDocInfo
	SET
			DocStatus = 'ARRIVAL',
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			MaterialDocNo = @MaterialDocNo


	declare @ccccount int=0;
	--begin by mr.tung on 28-March-2023
	select @ccccount=count(mdd.MaterialCode) from STB_MaterialDocDetail mdd with(nolock)
	left outer join STB_MaterialMaster mm with(nolock) on mdd.MaterialCode=mm.MaterialCode
	where MaterialDocNo=@MaterialDocNo and (mdd.MaterialCode like 'ECVT%' 
		or mdd.MaterialCode like 'LIVT%'
		or mm.MaterialName like 'HY-CAP%' and mm.ProductGroupCode in ('HC-EDLC','HC-VPC') 
	);

	PRINT '3'
	--end by mr.tung on 28-March-2023
	
	---  Modify By PJS : 납품서 생성 시 이미 오더 잔량 차감처리 하였으므로 입하 시 로직은 제거함
		---- 발주정보의 입하잔량에서 입하수량 차감 업데이트
		--UPDATE STB_MaterialOrderItem
		--SET
		--		MaterialOrderRemainQty = MaterialOrderRemainQty - MDD.PickingAssingQty
		--FROM
		--		STB_MaterialDocDetail MDD
		--		INNER JOIN STB_MaterialOrderItem MOI
		--			ON	MDD.OrderDetailNo = MOI.MaterialOrderItemNo
		--WHERE
		--		MDD.MaterialDocNo = @MaterialDocNo
	--

	SELECT @CompanyCode = CompanyCode   
	  FROM STB_UserInfo 
	 where UserID=@ProcessUserID;
	
	-- Modified by KHY : 검사가 필요한 수불유형일 경우 수입검사 의뢰 생성
	-- 무검사품의 경우도 성적서로 대체되고 수량 확인 등 기본적인 확인절차가 필요하므로 수입검사 의뢰를 생성함. 2019.04.16
	--IF @IsRequireIQC = 1 BEGIN
	IF @MDDExtBit01 = CONVERT(BIT, 1) AND @CompanyCode = 'VNT' BEGIN
		PRINT '개발품이고 본사이면 무검사품으로 갈음함.'
	END ELSE BEGIN
		EXEC usp_DoCreateMaterialIQCInfo @pProcessLanguage = @ProcessLanguage,
										 @pProcessUserID = @ProcessUserID,
										 @pMaterialDocNo = @MaterialDocNo
	END
	--END

	PRINT '4'
		

	if(@CompanyCode='VNT' or @CompanyCode='*' or @ccccount>0) begin
		-- 완료처리 시도
		-- 검사자재, 바코드사용 자재가 없을 경우 FINISH
		EXEC usp_DoFinishMaterialDoc  @pProcessLanguage = @ProcessLanguage,
											@pProcessUserID = @ProcessUserID,
											@pMaterialDocNo = @MaterialDocNo,
											@pIsTry = 1,
											@pIsFinished = @pIsFinished OUTPUT
	end

	PRINT '5'

END
