CREATE PROC [dbo].[usp_View_Divematerials]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pLOTID NVARCHAR(50) = NULL,
@pLabelType NVARCHAR(60) = NULL
AS
BEGIN

SET NOCOUNT ON;

	DECLARE @LOTID  NVARCHAR(50) = CASE WHEN ISNULL(@pLOTID,'') = '' THEN '' ELSE @pLOTID END
    DECLARE @LabelType  NVARCHAR(60) = @pLabelType

	DECLARE @companycode NVARCHAR(10)='';
	SELECT @companycode = companycode 
	FROM STB_UserInfo
	WHERE UserID=@pProcessUserID
		   
	;WITH LABELINFO AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()
	)


	
SELECT
		T1.LOTID,
		T1.DIVIDE_STOCKQTY,
		T1.PACKINGIDSMALL,
		T1.SEQNO,
		T1.CREATEUSERID,
		T1.CREATEDATETIME,
		T2.MaterialDocDetailNo,
		T2.LotID AS LOTIDMATERS,
		T2.StockQty,
		T2.LotNo,
		T2.PackingID,
		T2.MaterialLocationCode,
		T2.IsChecked,
		T2.MaterialDocNo AS OldMaterialDocNo,
		T2.MaterialLocationCode,
		T2.StockAttrib1,
		T2.StockAttrib2,
		T2.StockAttrib3,
		T2.LotAttr01,
		T2.LotAttr02,
		T3.MaterialName,
		T3.MaterialSpec,
		T3.MaterialUnit,
		T3.MMExtText02,
		T3.MMExtText03,
		T3.MMExtInt01,
		LBI.CommandType,
		LBI.LabelType  AS LabelType,
		CASE WHEN @companycode='VVT' THEN LBI.FormatName+'VNLableSmall' ELSE LBI.FormatName END   AS LabelFormatName,
		LBI.PrinterName,
		CASE WHEN ISPRINTER IS NULL THEN N'Chưa in tem'
		WHEN ISPRINTER = 1 THEN N'Đã in tem' ELSE '' END AS ISPRINTER,
		T3.ProductGroupCode,
		T3.MaterialCode,
		T3.MaterialName,
		T3.MaterialUnit,
		T1.MaterialWarehouseCode,
		CASE WHEN  isnull(T2.LotAttr10,'')='' THEN  ''  WHEN ISDATE(T2.LotAttr10)=1  THEN T2.LotAttr10 ELSE N'Error Date LotAttr10_Lỗi ngày tháng' END LotAttr10,
		CASE WHEN  isnull(T2.LotAttr10,'')='' then  ''
			  WHEN @companycode='VVT' and ISDATE(T2.Lotattr10)=1  THEN CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(VARCHAR(10), DATEADD(day,  T3.MMExtInt01*30, T2.Lotattr10), 121)), 121)
		      WHEN  ISDATE(T2.LotAttr10)=1  THEN  CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  T3.MMExtInt01, T2.Lotattr10), 121)), 121)
			  ELSE N'Error Date LotAttr10_Lỗi ngày tháng' END  AS PackDate,

		CASE
				WHEN WorkCenterCode = 'VVT_F2' THEN N'Bắc Giang'
				WHEN WorkCenterCode = 'VVT_F1' THEN N'Bắc Ninh'
		ELSE ''

		END  AS WorkCenterCode,
		'Report' AS Command
		
FROM
		STB_VN_DIVIDEMATERIALSMAL T1 WITH(NOLOCK)


LEFT OUTER JOIN 

		STB_MaterialDocLotInfo T2 WITH(NOLOCK) ON T2.LotID = T1.LOTID

LEFT OUTER JOIN 
		
		STB_MaterialMaster T3 WITH(NOLOCK)	 ON T2.MaterialCode = T3.MaterialCode


 LEFT OUTER JOIN 
 
        LABELINFO LBI ON LBI.LabelType = @LabelType    
		


WHERE T1.LOTID = @LOTID


-- SELECT * FROM   STB_VN_DIVIDEMATERIALSMAL 


-- SELECT * FROM STB_MaterialDocLotInfo


END

-- update STB_MaterialDocLotInfo set Isused = null where LotID ='ECVT27-213LK2500012' 
--  DELETE STB_VN_DIVIDEMATERIALSMAL where LotID ='ECVT27-213LK2500012'
-- SELECT * FROM STB_VN_DIVIDEMATERIALSMAL

--SELECT * FROM SmartFramework.dbo.STB_LabelInfo WHERE LabelType = 'PartLabelSmall'

--SELECT * FROM STB_VN_DIVIDEMATERIALSMAL

--SELECT * FROM STB_MaterialDocLotInfo WHERE LotID = 'ML20240519000290'

--UPDATE STB_MaterialDocLotInfo SET Isused = NULL WHERE LotID = 'ML20240519000290'

--DELETE STB_VN_DIVIDEMATERIALSMAL WHERE LOTID = 'ML20240519000290'


--ALTER TABLE STB_VN_DIVIDEMATERIALSMAL
--ADD
--	MaterialWarehouseCode  NVARCHAR(50)


--	UPDATE STB_VN_DIVIDEMATERIALSMAL SET MaterialWarehouseCode = 'PROD_VN_WH' WHERE ID =ID