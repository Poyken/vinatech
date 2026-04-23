
-- =============================================
-- Author:	   Kangs (kilee@vina.co.kr)
-- Create date: 2021-04-22
-- Browsable : true
-- Group : 품질관리 > 제품검사 >  특성완료상태변경 버튼 클릭시
-- Description:	수입검사 검사보류 처리합니다
-- Modified: usp_DoUpdateMaterialQcInfo_Complete
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Complete]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = null
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @DecisionResult VARCHAR(20)
	DECLARE @VendorLotNo VARCHAR(100)
	DECLARE @BefQcStatus VARCHAR(10)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
				SELECT
						CASE 
							WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo
							ELSE XMLData.OldMaterialQcNo
						END AS OldMaterialIqcNo
					   ,DecisionResult
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20),
								 DecisionResult VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo, @DecisionResult

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			SELECT
					@BefQcStatus = MQI.DecisionResult,
					@VendorLotNo = MQI.VendorLotNo
			FROM
					STB_MaterialQcInfo MQI WITH(NOLOCK)
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			--IF @DecisionResult NOT IN ('None', 'Hold')           -- 원본백업 (2021.04.22)

			IF @DecisionResult NOT IN ('None', 'Hold', 'Pass') 
			
			BEGIN    -- 이미정요청
				EXEC usp_RaiseLocalizedError @pProcessLanguage, '[검사대기]와 [검사보류], [합격]인 상태만 변경이 가능합니다.'
				RETURN
			END

            UPDATE STB_MaterialQcInfo
				SET
				  --  DecisionResult = CASE WHEN @DecisionResult = 'None' THEN 'Hold' ELSE 'None'  END,

				  DecisionResult = CASE WHEN @DecisionResult = 'None' THEN 'CComplete'   
				                                 WHEN @DecisionResult = 'Pass' THEN 'CComplete' ELSE 'None'  END,
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID,
					-- add by Mr.Tung 
					-- 2021-03-19 for History of Holding in OQC Vietnam
					VendorLotNo = ( CASE WHEN @DecisionResult = 'None' and  (@OldMaterialQcNo like 'VV%'  or @OldMaterialQcNo like 'F%')	THEN  substring(@VendorLotNo + ' - Hold:'   + convert(varchar(16),getdate(),120)   ,1,100)
												   WHEN   @DecisionResult = 'Hold'  and  (@OldMaterialQcNo like 'VV%'  or @OldMaterialQcNo like 'F%') THEN  substring(@VendorLotNo + ' - UnHold:'+ convert(varchar(16),getdate(),120) ,1,100)
													 ELSE   @VendorLotNo END
								          ) 
				WHERE
				    MaterialQcNo = @OldMaterialQcNo
        END
    END TRY

	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	
END