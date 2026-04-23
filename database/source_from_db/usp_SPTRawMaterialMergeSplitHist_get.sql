-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-16
-- Browsable : true
-- Group : 지지체
-- Description: 원재재소분이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SPTRawMaterialMergeSplitHist_get]
	@pProcessLanguage VARCHAR(20) 
   ,@pProcessUserID VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pOriginalLotID VARCHAR(50) = NULL
   ,@pMergeLotID VARCHAR(50) = NULL
   ,@pSplitLotID VARCHAR(50) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@OriginalLotID VARCHAR(50) = CASE WHEN ISNULL(@pOriginalLotID, '') = '' THEN '*' ELSE @pOriginalLotID END
		   ,@MergeLotID VARCHAR(50) = CASE WHEN ISNULL(@pMergeLotID, '') = '' THEN '*' ELSE @pMergeLotID END
		   ,@SplitLotID VARCHAR(50) = CASE WHEN ISNULL(@pSplitLotID, '') = '' THEN '*' ELSE @pSplitLotID END

	SELECT MIN(SRMH.OriginalLotID) + ' 외 ' + CONVERT(VARCHAR, COUNT(*) -1) + '건' AS OriginalLotID
	      ,SRMH.MergeLotID
		  ,MAX(ISNULL(MLI.CurrentQty, 0)) AS MergeLotCurrentQty
		  ,SRSH.SplitLotID
		  ,MAX(SRSH.SplitQty) AS SplitQty
		  ,MAX(ISNULL(MLI2.CurrentQty, 0)) AS SplitLotCurrentQty
		  ,'Report' AS CommandType
		  ,MAX(MM.productGroupCode) AS productGroupCode
		  ,MAX(MM.MaterialName) AS MaterialName
		  ,MAX(MLI2.CurrentQty) AS StockQty
		  ,MAX(MM.MaterialUnit) AS MaterialUnit
		  ,MAX(MLI2.LotID) AS LotID
		  ,MAX(MDLI.LotNo) AS LotNo
		  ,MAX(MDLI.LotAttr10) AS LotAttr10
		  ,MAX(CONVERT(CHAR(10), DATEADD(day, -1, DATEADD(month, MM.MMExtInt01, CONVERT(DATE, MDLI.LotAttr10, 121))), 121)) AS PackDate
	  FROM STB_SupportRawMaterialMergeHist SRMH
	  LEFT OUTER JOIN STB_SupportRawMaterialSplitHist SRSH
	    ON SRMH.MergeLotID = SRSH.MergeLotID
	  LEFT OUTER JOIN STB_MaterialLotInfo MLI
	    ON MLI.LotID = SRMH.MergeLotID
	  LEFT OUTER JOIN STB_MaterialLotInfo MLI2
	    ON MLI2.LotID = SRSH.SplitLotID
	  LEFT OUTER JOIN (SELECT LotID, MAX(LotNo) AS LotNo, MAX(LotAttr10) AS LotAttr10
	                     FROM STB_MaterialDocLotInfo 
						WHERE (
							LotID IN (SELECT OriginalLotID FROM STB_SupportRawMaterialMergeHist)
						 OR LotID IN (SELECT MergeLotID FROM STB_SupportRawMaterialMergeHist)
						 OR LotID IN (SELECT SplitLotID FROM STB_SupportRawMaterialSplitHist)
					    )
						GROUP BY LotID
					  ) MDLI
	    ON MDLI.LotID = SRMH.OriginalLotID
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MLI2.MaterialCode = MM.MaterialCode
	 WHERE SRSH.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@OriginalLotID = '*' OR SRMH.OriginalLotID LIKE '%' + @OriginalLotID + '%') 
	   AND (@MergeLotID = '*' OR SRMH.MergeLotID = @MergeLotID) 
	   AND (@SplitLotID = '*' OR SRSH.SplitLotID = @SplitLotID) 
	 GROUP BY SRMH.MergeLotID, SRSH.SplitLotID
END