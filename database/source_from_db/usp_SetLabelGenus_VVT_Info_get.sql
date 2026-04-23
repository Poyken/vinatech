-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-11
-- Description:	<Description,,>
-- =============================================

-- exec usp_SetLabelGenus_VVT_Info_get '', '', '', '', '', '' ,'1' ,'' ,'' , '', 1
CREATE PROCEDURE [dbo].[usp_SetLabelGenus_VVT_Info_get] 
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pCustomPartNo VARCHAR(20) = null,
				@pMPN VARCHAR(20) = null,
				@pINVOICENO VARCHAR(50) = null,
				@pINVOICEDate  VARCHAR(50) = null,
				@pIsOuter BIT = null,
				@pPacketQty VARCHAR(100) = null,
				@pBoxQty VARCHAR(100) = null,
				@pNumberOfTotal INT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	CREATE TABLE #tmp (Num INT)


	IF @pNumberOfTotal >= 1 
	BEGIN
		

		DECLARE @Number INT = 1;
		DECLARE @TotalBox INT = 0
		WHILE @Number <= @pNumberOfTotal
			BEGIN
				SET @TotalBox = @TotalBox + 1;
				INSERT INTO #tmp (Num) VALUES (@Number)
				SET @Number = @Number + 1;
			END
	END


		SELECT 
				(CASE 
					WHEN @pIsOuter = 1 THEN 'Outer BOX PACKING STICKER' 
					ELSE 'INNER BOX PACKING STICKER' 
				END) as Typez,
				@pCustomPartNo as CustomPartNo,
				@pMPN as MPN,
				@pINVOICENO as INVOICENO,
				@pINVOICEDate as INVOICEDATE,
				@pPacketQty as PacketQty,
				@pBoxQty as BoxQty,
				CONVERT(VARCHAR(3), #tmp.Num) + ' of ' + CONVERT(VARCHAR(3), @pNumberOfTotal) as TotalBoxesOfShipment,
				--CONVERT(VARCHAR(3), #tmp.Num) as TotalBoxesOfShipment,
				'Report' AS CommandType

		FROM #tmp


	DROP TABLE #tmp




END
