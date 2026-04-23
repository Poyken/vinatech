-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-11-15
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionSampleResultMon_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	Declare @SpecOverCnt INT
	       ,@MainContents VARCHAR(MAX) = 'S/D 스펙오버 상세<br/><br/>'
		   ,@Barcode VARCHAR(20)

	DELETE FROM SpecOverResultTemp


	INSERT INTO SpecOverResultTemp
		SELECT MQI.MaterialCode
				,MM.MaterialName
				,MQSR.TestValue
				,MQII.LSL
				,MQII.USL
				,MQSR.CreateDateTime
				,(SELECT MAX(Barcode) FROM STB_SetInfo WHERE LotNumber = MQI.MaterialQcNo)
			FROM STB_MaterialQcInfo MQI
			LEFT OUTER JOIN STB_MaterialQcDetail MQD
			ON MQI.MaterialQcNo = MQD.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR
			ON MQSR.MaterialQcNo = MQI.MaterialQcNo
			AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
			LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII
			ON MQII.MaterialCode = MQI.MaterialCode
			AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
			LEFT OUTER JOIN STB_MaterialMaster MM
			ON MM.MaterialCode = MQI.MaterialCode
			WHERE MQI.InspectionDocType = 'OQC'
			AND MQD.QcInspectionItemCode = 'IQC_GPD_18'
			AND MQSR.TestValue IS NOT NULL
			AND MQSR.CreateDateTime BETWEEN DATEADD(day, -1, GETDATE()) AND GETDATE()
			AND (MQSR.TestValue > MQII.USL OR MQSR.TestValue < MQII.LSL)
			ORDER BY MQSR.CreateDateTime ASC

	SELECT @SpecOverCnt = COUNT(*)
	  FROM SpecOverResultTemp

	IF @SpecOverCnt > 0 BEGIN
		DECLARE cur CURSOR FOR
		
		SELECT DISTINCT Barcode FROM SpecOverResultTemp

		OPEN cur

		FETCH NEXT FROM cur INTO @Barcode

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @MainContents = @MainContents + 'http://110.11.27.5:8088/ProductCheckSheet.do?barcode=' + @Barcode + '&skey=F77869B5-DCEE-4C90-9385-D7DCEE7ADE3E <br/>'
	
			FETCH NEXT FROM cur INTO @Barcode
		END

		CLOSE cur
		DEALLOCATE cur

		EXEC usp_DoAddSystemMail @pProcessUserID = '' 
			                ,@pProcessLanguage = ''
							,@pTargetMailAddress='yjyu@vina.co.kr'
							,@pMailSubject = 'S/D 스펙오버가 발생하였습니다.'
							,@pMailContents = @MainContents
	END
END