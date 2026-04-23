
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-17
-- Browsable : true
-- Group : 금형관리
-- Description:	금형현황정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldDetail]	
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
	DECLARE @MoldAlarmInfo TABLE
	(
		MoldNumber VARCHAR(50),
		Alarm VARCHAR(20)
	)
	
	DECLARE @AlarmResult TABLE
	(
		MoldNumber VARCHAR(20),
		AlarmStatus VARCHAR(100)
	)


	DECLARE @MoldCheckType TABLE
	(
		MoldCheckTypeCode VARCHAR(30)
	)

	

	IF @WorkCenterCode = 'BW_BC' BEGIN
		INSERT @MoldCheckType
		SELECT
				CommInspTypeCode
		FROM
				STB_CommInspTypeInfo
		WHERE
				CommInspTypeCode IN ('DailyCheck','RegularCheck','DieSpotCheck','OverhaulCheck')
	END

	IF @WorkCenterCode = 'BW_AS' BEGIN
		INSERT @MoldCheckType
		SELECT
				CommInspTypeCode
		FROM
				STB_CommInspTypeInfo
		WHERE
				CommInspTypeCode IN ('AS_DailyCheck','AS_RegularCheck','AS_DieSpotCheck','AS_OverhaulCheck')
	END
	
	INSERT @MoldAlarmInfo
	SELECT
			Master.MoldNumber,
			Master.ALARM
	FROM
				(
					SELECT
							MBI.MoldNumber,
							MBI.CheckTypeCode,
							MBI.CheckTypeName,
							MBI.CheckTerm,
							MBI.AccumulateQty,
							ISNULL(CIDH.LastCheckQty,0) AS LastCheckQty,
							MBI.AccumulateQty - ISNULL(CIDH.LastCheckQty,0) AS PassedAccumulateQty,
							CASE	
								WHEN (MBI.CheckTerm <> 0) AND (MBI.AccumulateQty - ISNULL(CIDH.LastCheckQty,0)) >= (MBI.CheckTerm - 1000) THEN MBI.CheckTypeName
								ELSE ''
							END AS ALARM
					FROM
				    
							(
								SELECT	
										MoldBasicInfo.MoldNumber,
										CommInspTypeInfo.CheckTypeCode,
										
										CommInspTypeInfo.CheckTypeName,
										CommInspTypeInfo.CITIExtInt01 AS CheckTerm,
										MoldBasicInfo.AccumulateQty
								FROM
								
										(
											SELECT
													MBI.MoldNumber,
													MBI.AccumulateQty
											FROM
													STB_MoldBasicInfo MBI WITH(NOLOCK)
											WHERE
													((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode)) AND 
													((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode))
										)MoldBasicInfo,
										(
											SELECT
													CITI.CommInspTypeCode AS CheckTypeCode,
													CITI.CommInspTypeName AS CheckTypeName,
													CITI.CITIExtInt01
											FROM
													STB_CommInspTypeInfo CITI WITH(NOLOCK)
											WHERE
													((@CompanyCode = '*') OR (CITI.CompanyCode = @CompanyCode)) AND 
													((@WorkCenterCode = '*') OR (CITI.WorkCenterCode = @WorkCenterCode)) AND 
													--(CITI.CommInspTypeCode IN ('DailyCheck_small',
													--							'DailyCheck_large',
													--							'RegularCheck_small',
													--							'RegularCheck_large',
													--							'DieSpotCheck_small',
													--							'DieSpotCheck_large',
													--							'OverhaulCheck_small',
													--							'OverhaulCheck_large'
													--							)
													--) AND
													(CITI.CommInspTypeCode IN (SELECT MoldCheckTypeCode FROM @MoldCheckType)) AND
													(ISNULL(CITI.CITIExtInt01,0) > 0 )
										)CommInspTypeInfo
							)MBI
							INNER JOIN
							(
								SELECT
										DISTINCT
										CIDHH.MoldNumber,
										CIDHH.CheckTypeCode,
										CIDHH.LastCheckQty,
										CIDHH.R
								FROM
										(
											SELECT
													CIDH.MoldNumber,
													CIDH.CommInspTypeCode AS CheckTypeCode,
													CIDH.CIDHExtInt01 AS LastCheckQty,
													RANK() OVER (PARTITION BY CIDH.MoldNumber, CIDH.CommInspTypeCode ORDER BY CIDH.CIDHExtInt01 DESC) AS R
											FROM
													STB_CommInspDocHistory CIDH WITH(NOLOCK)
										)CIDHH
								WHERE
										(CIDHH.R = 1) AND
									--(CIDHH.CheckTypeCode IN (
									--								'DailyCheck_small',
									--								'DailyCheck_large',
									--								'RegularCheck_small',
									--								'RegularCheck_large',
									--								'DieSpotCheck_small',
									--								'DieSpotCheck_large',
									--								'OverhaulCheck_small',
									--								'OverhaulCheck_large'
									--							)
								   	--	)
									(CIDHH.CheckTypeCode IN (SELECT MoldCheckTypeCode FROM @MoldCheckType))
							)CIDH
								ON CIDH.MoldNumber = MBI.MoldNumber AND
								CIDH.CheckTypeCode = MBI.CheckTypeCode	
				)Master
	WHERE
			Master.ALARM <> ''
	ORDER BY
			Master.MoldNumber,
			Master.CheckTypeCode
			
	
	
	INSERT @AlarmResult
	SELECT
			MSH.MoldNumber,
			STUFF((SELECT ',' + MSH2.Alarm FROM @MoldAlarmInfo MSH2 WHERE MSH.MoldNumber = MSH2.MoldNumber FOR XML PATH('')),1,1,'') AS Alarm
	FROM
			@MoldAlarmInfo MSH
	GROUP BY
			MSH.MoldNumber
			
			
	SELECT
			MBI.MoldNumber,
			MBI.MoldGrade,
			ISNULL(MBI.GuaranteeQty,'0') AS GuaranteeQty,
			ISNULL(MBI.AccumulateQty,'0') AS AccumulateQty,
			ISNULL(MBI.CurrentQty,'0') AS CurrentQty,
			'' AS AlarmStatus,
			TB.AlarmStatus AS AlarmStatusName,
			
			CASE WHEN MBI.MoldGradeTypeCode = 'TA' THEN
														CASE WHEN MBI.AccumulateQty < 400000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '1')
															 WHEN MBI.AccumulateQty >=400000 AND MBI.AccumulateQty < 500000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '2')
															 WHEN MBI.AccumulateQty >= 500000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '3')
															 ELSE (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '4')
														END
				WHEN MBI.MoldGradeTypeCode = 'TB' THEN 
														CASE WHEN MBI.AccumulateQty < 600000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '1')
															 WHEN MBI.AccumulateQty >= 600000 AND MBI.AccumulateQty < 1000000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '2')
															 WHEN MBI.AccumulateQty >= 1000000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '3')
															 ELSE (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '4')
														END
				WHEN MBI.MoldGradeTypeCode = 'TC' THEN
														CASE WHEN MBI.MoldGrade = 'A' or  MBI.MoldGrade = 'B' THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '1')
															 WHEN MBI.MoldGrade = 'C' THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '2')
															 WHEN MBI.MoldGrade = 'D' THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '3')
															 ELSE (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '4')
														END
				WHEN MBI.MoldGradeTypeCode = 'TD' THEN 
														CASE WHEN MBI.AccumulateQty < 60000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '1')
															 WHEN MBI.AccumulateQty >= 60000 AND MBI.AccumulateQty <100000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '2')
															 WHEN MBI.AccumulateQty >= 100000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '3')
															 ELSE (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '4')
														END
				WHEN MBI.MoldGradeTypeCode = 'TE' THEN 
														CASE WHEN MBI.AccumulateQty < 1000000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '1')
															 WHEN MBI.AccumulateQty >= 1000000 AND MBI.AccumulateQty < 1500000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '2')
															 WHEN MBI.AccumulateQty >= 1500000 THEN (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '3')
															 ELSE (SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = '4')
														END					
			END MoldSignalLight,
			
			
			MTI.MoldTypeName,
			MBI.CompanyCode,
			CI.CompanyName,
			MBI.WorkCenterCode,
			WCI.WorkCenterName,
			CASE
				WHEN MBI.CurrentPosition = '보관창고' THEN ML.LocationName
				ELSE MBI.CurrentPosition
			END AS CurrentPosition,
--			MBI.CurrentPosition,
			'생산',
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.RawMaterial,
			CONVERT(VARCHAR(7), MBI.MakeDate, 120) AS MakeDate,
			MBI.MakeVendor,
			MBI.MBIExtText01 AS Comment
	FROM
			STB_MoldBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MTI.MoldTypeCode = MBI.MoldTypeCode
			LEFT OUTER JOIN STB_MoldLocation ML WITH(NOLOCK)
				ON ML.MoldLocationCode = MBI.MoldLocationCode
			LEFT OUTER JOIN @AlarmResult TB
				ON TB.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MBI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				on CI.CompanyCode = MBI.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (MBI.WorkCenterCode = @WorkCenterCode)) 
	ORDER BY
			MBI.MoldNumber
END


