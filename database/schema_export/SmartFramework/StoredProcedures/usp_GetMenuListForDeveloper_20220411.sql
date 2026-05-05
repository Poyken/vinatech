-- Procedure: usp_GetMenuListForDeveloper_20220411






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Menu List
-- =============================================
Create PROCEDURE [dbo].[usp_GetMenuListForDeveloper_20220411]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			S.*
	FROM
			(
				SELECT 
						SI.Name AS ID,
						SI.Name,
						SI.TCode,
						SI.IsFolder,	
						SI.IsNeverClose,		
						SI.ShowAfterStart,
						SI.ShowInMenu,
						SI.ParentName,			
						SI.Caption,
						CASE SI.IsFolder
							WHEN 1 THEN 0
							ELSE SI.CurrentVersion
						END AS CurrentVersion,
						CASE SI.IsFolder
							WHEN 1 THEN 0
							ELSE
								(
									SELECT
											MAX(SLI.Version)
									FROM
											STB_ScreenLayoutInfo SLI WITH(NOLOCK)
									WHERE
											SLI.Name = SI.Name
								)
						END AS MaxVersion,
						SI.CreateDateTime,
						SI.CreateUserID,
						SI.AccessType,
						CASE
							WHEN ISNULL(SI.TCode,'') = '' THEN 'ZZZZ'
							ELSE SI.TCode
						END AS VirtualTCode
				FROM
						STB_ScreenInfo SI WITH(NOLOCK)
				WHERE
						SI.IsDelete = 0 --AND
						--(
						--	SI.ChangeDateTime IS NULL OR
						--	SI.ChangeDateTime <= '2022-04-08' OR
						--	SI.Name IN
						--		(
						--			'Daily_Inspection',
						--			'Electrode _Menu',
						--			'Electrode_Measuring',
						--			'Model_Change',
						--			'Plan_Management',
						--			'PM_ProductManagement_MENU',
						--			'Prod _Menu',
						--			'ScrapByLotNew',

						--			'Vietnam_Measuring',
						--			'Vitnam_Prod_Menu',
						--			'PO_InformationManagement',
						--			'MaterialOqcInfoSampleManagement',
						--			'DayMoldProdPlanForPO',
						--			'DayProdPlanForMainLot',
						--			'DayProdPlanForProductLot',
						--			'DayProdPlanForPO',
						--			'VNT_ElectrodePrcsCard',
						--			'VNT_LineManagerEmailInfo',
						--			'ProductMachine',
						--			'BasicRoutingInfo',
						--			'LineRouteMapping',
						--			'RouteInfo',
						--			'LineInfo',
						--			'UserInfo',
						--			'VVT_ProductionOrderSelectDialog',
						--			'ElectrodePlan_Vietnam'
						--		)
						--)
			) S
	ORDER BY
			S.IsFolder DESC,
			S.VirtualTCode,
			S.Caption
END






/*
SELECT
		*
FROM
		STB_ScreenInfo SI WITH(NOLOCK)
WHERE
		SI.Name = 'DayMoldProdPlanForPO'

SELECT
		*
FROM
		STB_ScreenLayoutInfo WITH (NOLOCK)
WHERE
		Name = 'DayMoldProdPlanForPO'
UPDATE		STB_ScreenInfo 
SET
		IsFolder = 1
WHERE
		Name = 'DayMoldProdPlanForPO'



*/
GO

