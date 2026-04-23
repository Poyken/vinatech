-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-05-02
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	비전그룹 검사정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROC usp_VisionGroupInspectionInfo_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pBarcode VARCHAR(20) = NULL
   ,@pVisionGroup VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
		   ,@VisionGroup VARCHAR(20) = CASE WHEN ISNULL(@pVisionGroup, '') = '' THEN '*' ELSE @pVisionGroup END

	SELECT VGI1.InspectionNo
          ,VGI1.MachineID
		  ,IMI.MachineName
          ,VGI1.LotNo
          ,VGI1.Barcode
          ,VGI1.ModelNo
          ,VGI1.CameraNo
          ,VGI1.DefectType
          ,VGI1.XAxis
          ,VGI1.YAxis
          ,VGI1.LongSize
          ,VGI1.ShortSize
          ,VGI1.Size
          ,VGI1.GD
          ,VGI1.Area
          ,VGI1.Peak
          ,VGI1.Dx
          ,VGI1.Dy
          ,VGI1.Compact
          ,VGI1.Thickness
          ,VGI1.Distance
          ,VGI1.AlgType
          ,VGI1.IsMerge
          ,VGI1.Image
          ,VGI1.CreateDateTime
		  ,'Group1' AS VisionGroup
	  FROM STB_VisionGroup1InspectionInfo VGI1
	  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	    ON IMI.MachineID = VGI1.MachineID
	 WHERE VGI1.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR VGI1.Barcode = @Barcode)
	   AND (@VisionGroup = '*' OR @VisionGroup = 'Group1')
	UNION ALL
	SELECT VGI2.InspectionNo
          ,VGI2.MachineID
		  ,IMI.MachineName
          ,VGI2.LotNo
          ,VGI2.Barcode
          ,VGI2.ModelNo
          ,VGI2.CameraNo
          ,VGI2.DefectType
          ,VGI2.XAxis
          ,VGI2.YAxis
          ,VGI2.LongSize
          ,VGI2.ShortSize
          ,VGI2.Size
          ,VGI2.GD
          ,VGI2.Area
          ,VGI2.Peak
          ,VGI2.Dx
          ,VGI2.Dy
          ,VGI2.Compact
          ,VGI2.Thickness
          ,VGI2.Distance
          ,VGI2.AlgType
          ,VGI2.IsMerge
          ,VGI2.Image
          ,VGI2.CreateDateTime
		  ,'Group2' AS VisionGroup
	  FROM STB_VisionGroup2InspectionInfo VGI2
	  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	    ON IMI.MachineID = VGI2.MachineID
	 WHERE VGI2.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR VGI2.Barcode = @Barcode)
	   AND (@VisionGroup = '*' OR @VisionGroup = 'Group2')
	UNION ALL
	SELECT VGI3.InspectionNo
          ,VGI3.MachineID
		  ,IMI.MachineName
          ,VGI3.LotNo
          ,VGI3.Barcode
          ,VGI3.ModelNo
          ,VGI3.CameraNo
          ,VGI3.DefectType
          ,VGI3.XAxis
          ,VGI3.YAxis
          ,VGI3.LongSize
          ,VGI3.ShortSize
          ,VGI3.Size
          ,VGI3.GD
          ,VGI3.Area
          ,VGI3.Peak
          ,VGI3.Dx
          ,VGI3.Dy
          ,VGI3.Compact
          ,VGI3.Thickness
          ,VGI3.Distance
          ,VGI3.AlgType
          ,VGI3.IsMerge
          ,VGI3.Image
          ,VGI3.CreateDateTime
		  ,'Group3' AS VisionGroup
	  FROM STB_VisionGroup3InspectionInfo VGI3
	  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	    ON IMI.MachineID = VGI3.MachineID
	 WHERE VGI3.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR VGI3.Barcode = @Barcode)
	   AND (@VisionGroup = '*' OR @VisionGroup = 'Group3')
	ORDER BY VisionGroup, CreateDateTime
END