-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-09-23
-- Browsable : true
-- Group : 품질관리 > [C460]전극공정검사 불합격 Button
-- Description:	전극공검 검사를 폐기처리합니다
-- Modified: 

-- [프로시저 실행문]  --   usp_DoLossElectrodeProcess_iud '','','',''
-- SELECT SIExtInt01, IsLoss, * FROM STB_SetInfo WHERE BARCODE ='VJKR1620001E17'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoLossElectrodeProcess_iud]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pBarcode VARCHAR(50) = NULL,
				--@pCommInspDocNo VARCHAR(20),
				@pIsCheckItem BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				@Barcode VARCHAR(50) = @pBarcode,
				@CommInspDocNo VARCHAR(20), --= @pCommInspDocNo,
				@IsCheckItem BIT = ISNULL(@pIsCheckItem,0)
			
	DECLARE @IsLoss BIT
	DECLARE @IsFinished BIT
	--DECLARE @Barcode VARCHAR(50)
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE  @SIExtInt01 BIT
	DECLARE @NewBarcode VARCHAR(50)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = @Barcode

	SELECT
			@CommInspDocNo = CIDH.CommInspDocNo
	FROM
								  STB_SetInfo SI			
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON 	CIDH.ProdNo = SI.ControlNo			
	WHERE 1=1	    
		   AND SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode   

	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode,
			@IsLoss = SI.IsLoss,
	        @SIExtInt01 = SIExtInt01
	FROM
			STB_CommInspDocHistory CIDH WITH(NOLOCK)
			INNER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo
	
	--IF @IsFinished = 1 BEGIN
	--		EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
	--															'^이미 완료처리 되었습니다^',
	--															@ErrorMessage OUTPUT
	--		SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
	--		RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
	--		RETURN
	--END

	IF @SIExtInt01 = 1 
	
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																' ^폐기처리 되었습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s/%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode,@CommInspDocNo)
			RETURN
	END


	UPDATE	STB_SetInfo
	SET
			SIExtInt01 = 1
			--,IsLoss = 1
	WHERE
			Barcode = @Barcode

	EXEC usp_DoFinishCommInspDoc	@pProcessUserID = @ProcessUserID,
												@pProcessLanguage = @ProcessLanguage,
												@pCommInspDocNo = @CommInspDocNo,
												@pIsCheckItem = @IsCheckItem
END
