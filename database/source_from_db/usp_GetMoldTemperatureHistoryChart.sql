-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 금형관리
-- Description:	금형온도이력조회(Chart)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldTemperatureHistoryChart]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pFromMeasureDateTime DATETIME = NULL,
	@pToMeasureDateTime DATETIME = NULL 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
    DECLARE @FromMeasureDateTime DATETIME = CASE WHEN ISNULL(@pFromMeasureDateTime,'') = '' THEN GETDATE() ELSE @pFromMeasureDateTime END
	DECLARE @ToMeasureDateTime DATETIME = CASE WHEN ISNULL(@pToMeasureDateTime,'') = '' THEN GETDATE() ELSE @pToMeasureDateTime END
	
	SELECT
			A.*
	FROM
		(
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면1' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 1
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면1 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 1
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면2' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 2
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면2 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 2
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면3' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 3
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면3 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 3
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면4' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 4
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'금형표면4 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 4
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'냉각수IN' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 5
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'냉각수IN 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 5
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'냉각수OUT' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 6
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'냉각수OUT 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 6
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'온수기1' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 7
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'온수기1 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 7
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'온수기2' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 8
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'온수기2 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 8
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'오일탱크' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 9
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'오일탱크 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 9

					UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'호퍼온도' AS Gubun,
					CASE WHEN CDD.MeasureData = -999 THEN NULL 
						ELSE CDD.MeasureData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 10
			UNION ALL
			SELECT
					CDH.MeasureDateTime AS MeasureDateTime,
					'호퍼온도 설정온도' AS Gubun,
					CASE WHEN CDD.SetingData = -999 THEN NULL 
						ELSE CDD.SetingData 
					END AS Value
			FROM
					STB_ContinueDataDetail CDD WITH(NOLOCK)
					LEFT OUTER JOIN STB_ContinueDataHistory CDH WITH(NOLOCK)
						ON CDH.MeasureSeq = CDD.MeasureSeq	
	
			WHERE
					(CDH.CompanyCode = @CompanyCode)
					AND (CDH.WorkCenterCode = @WorkCenterCode)
					AND (CDH.MachineCode = @MachineCode)
					AND ((@FromMeasureDateTime <= CDH.MeasureDateTime) AND (@ToMeasureDateTime >= CDH.MeasureDateTime))
					AND CDD.DataSeq = 10
	) A
	ORDER BY 
		A.Gubun,
		A.MeasureDateTime

END




