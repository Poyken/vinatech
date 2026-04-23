
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-16
-- Browsable : true
-- Group : 금형관리
-- Description:	금형점검 예방 타수관리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldCheckTargetManage]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
	DECLARE @MoldCheckType TABLE (MoldCheckTypeCode VARCHAR(30))


	IF @WorkCenterCode = 'BW_BC' BEGIN
		INSERT @MoldCheckType 
		SELECT
				CommInspTypeCode
		FROM
				STB_CommInspTypeInfo WITH(NOLOCK)
		WHERE
				CommInspTypeCode IN ('DailyCheck','RegularCheck','DieSpotCheck','OverhaulCheck')		
	END 

	IF @WorkCenterCode = 'BW_AS' BEGIN
		INSERT @MoldCheckType 
		SELECT
				CommInspTypeCode
		FROM
				STB_CommInspTypeInfo WITH(NOLOCK)
		WHERE
				CommInspTypeCode IN ('AS_DailyCheck','AS_RegularCheck','AS_DieSpotCheck','AS_OverhaulCheck')	
	END

    ;WITH CTE AS
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
					WHEN (MBI.AccumulateQty - ISNULL(CIDH.LastCheckQty,0)) >= (MBI.CheckTerm - 1000) THEN MBI.CheckTypeName
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
										--(CITI.CommInspTypeCode IN ('DailyCheck',
										--							'RegularCheck',
										--							'DieSpotCheck',
										--							'OverhaulCheck'																	)
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
							--								'DailyCheck',
							--								'RegularCheck',
							--								'DieSpotCheck',
							--								'OverhaulCheck'	
							--							)
							--)
							(CIDHH.CheckTypeCode IN (SELECT MoldCheckTypeCode FROM @MoldCheckType))
				)CIDH
					ON CIDH.MoldNumber = MBI.MoldNumber AND
					CIDH.CheckTypeCode = MBI.CheckTypeCode	
    )

    
    
    SELECT
			CI.CompanyName,
			WCI.WorkCenterName,
			'' AS AlarmStatus,
			T.ALARM AS AlarmStatusName,
			--CASE 
			--	WHEN
			--		(
			--			SELECT
			--					COUNT(*)
			--			FROM
			--					STB_CommInspDocHistory CIDH WITH(NOLOCK)
			--					LEFT OUTER JOIN STB_CommInspDocItem CIDI WITH(NOLOCK)
			--						ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
			--					LEFT OUTER JOIN STB_CommInspMeasureHist CIMH WITH(NOLOCK)
			--						ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
			--			WHERE
			--					CIDH.MoldNumber = MBI.MoldNumber AND
			--					CIDI.CommInspItemCode = 'CheckItem12' AND -- 점검항목명 : 즉각정비입고여부
			--					CIMH.MeasureResult = 'OK' AND
			--					CIDH.IsFinished <> 1 
			--		) > 0 THEN '라인점검 입고필요'
			--	ELSE ''
			--END AS ExtLineCheck
			MBI.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.AccumulateQty,
			T.PassedAccumulateQty
	FROM
			STB_MoldBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MTI.MoldTypeCode = MBI.MoldTypeCode
			LEFT OUTER JOIN STB_MoldLocation ML WITH(NOLOCK)
				ON ML.MoldLocationCode = MBI.MoldLocationCode
			INNER JOIN CTE T
				ON T.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MBI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = MBI.CompanyCode
	WHERE
			((@CompanyCode = '*') OR (CI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (WCI.WorkCenterCode = @WorkCenterCode)) AND
			(ISNULL(T.ALARM,'') <> '')
	ORDER BY
			CI.CompanyCode,
			WCI.WorkCenterCode
	
END


