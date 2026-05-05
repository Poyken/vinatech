-- Procedure: usp_AssyCardInfoCommon_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description:	Lot 생산현황 조회(공통)
-- Modified:
--              2020.04.17 기종변경 바코드추가
-- Modify date: 2020-07-16
-- Purpose: The development extension for dry oven function.
-- Modify by: Kevin Nguyễn
-- =============================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfoCommon_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pBarcode [varchar](20) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @Barcode	VARCHAR(20) = @pBarcode
	Declare @NewBarcode VARCHAR(20)

	DECLARE @NewLotID VARCHAR(20)


	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory 
	 WHERE OldBarcode = @Barcode


	 select @NewLotID=NewLotID
	 from STB_ChangePartNoAndLotNo
	 where NewLotID=@Barcode
	 

	-- 공통정보
	--SELECT SI.MaterialCode
	--      ,MM.MaterialName
	--	  ,SI.Barcode
	--	  ,SI.InputLineCode
	--	  ,SI.InputJobDate
	--	  ,SI.ProdQty
	--	  ,SI.SIExtText02 AS OvenInputDateTime
	--	  ,SI.SIExtText03 AS OvenOutputDateTime
	--	  ,SI.SIExtText04 AS HighTempStoringInputDateTime
	--	  ,SI.SIExtText05 AS HighTempStoringOutputDateTime
	--	  ,SI.SIExtText06 AS OvenCode
	--	  ,'Report' AS CommandType
	--  FROM STB_SetInfo SI
	--          LEFT OUTER JOIN STB_MaterialMaster MM	    ON SI.MaterialCode = MM.MaterialCode
	 --WHERE 1=1
	 --  AND  (SI.Barcode = @Barcode OR SI.Barcode = (SELECT NewBarcode  FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode )) 
	

SELECT SI.MaterialCode
	      , case when @Barcode in  -- đổi tên theo yêu cầu của Mr.Trung
		   (
		    'VVOT143R850601',
			'VVOT153R850606',
			'VVOT213R850602',
			'VVOT223R850601',
			'VVOT203R850601',
			'VVOT223R850607',
			'VVOT193R850610',
			'VVOT213R850606',
			'VVOU033R850601',
			'VVOT223R850604',
			'VVOT253R850607',
			'VVOU043R850601',
			'VVOT253R850604',
			'VVOU043R850602',
			'VVOT223R850608',
			'VVOT193R850604',
			'VVOT213R850601',
			'VVOT203R850606',
			'VVOT203R850604',
			'VVOT223R850602',
			'VVOT223R850605',
			'VVOT213R850607'
		   ) then 'VEL08253R8506G-B050 (0825)'
		   when @Barcode in  -- 2025-07-08 following  Mr.Diep BG 's request
		   (
			'VVPN113R036708',
			'VVPN123R036727',
			'VVPN113R036707',
			'VVPN133R036716',
			'VVPN173R036709',
			'VVPM153R036709',
			'VVPM173R036723',
			'VVPM153R036708',
			'VVPM163R036737',
			'VVPM153R036710',
			'VVPM163R036738',
			'VVP0223R036707'
		   ) then 'HY-CAP VEP3R0367QG (3562)'
		   -- when SI.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' -- Ms Phuong updated audit 2025-11-26
		   else MM.MaterialName end MaterialName
		  ,SI.Barcode
		  ,SI.InputLineCode
		  ,SI.InputJobDate
		  ,SI.ProdQty
		  ,CONVERT(DATETIME,SI.SIExtText02) AS OvenInputDateTime
		  --,N'Thời gian vào: ' + RIGHT(SI.SIExtText02,8) AS TimeIn
		  ,CONVERT(DATETIME,SI.SIExtText03) AS OvenOutputDateTime
		  --,N'Thời gian ra: '+RIGHT(SI.SIExtText03,8) AS TimeOut
		  ,N'Thời gian vào: ' + RIGHT(SI.SIExtText02,8) AS HighTempStoringInputDateTime
		  ,N'Thời gian ra: '+RIGHT(SI.SIExtText03,8) AS HighTempStoringOutputDateTime
		  ,TotalMinutes  AS HighTempStoringInputDateTime
		  ,DATEDIFF(HOUR,SIExtText02,GETDATE()) AS TotalCurrently
		  ,T1.TotalHouse 
		  ,SI.SIExtText06 AS OvenCode
		  ,'Report' AS CommandType
		  ,LEFT(SI.MaterialCode, 4) AS MaterialCodeHeader
	  FROM STB_SetInfo SI
	          LEFT OUTER JOIN STB_MaterialMaster MM	    ON SI.MaterialCode = MM.MaterialCode
			  LEFT JOIN STB_VN_DRYOVER T1 ON SI.Barcode=T1.BarCode
	 WHERE 1=1
	   AND  (SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode OR SI.NewBarcode=@NewLotID)            -- 2020.04.17 추가 (기종변경 바코드추가)
END
GO

