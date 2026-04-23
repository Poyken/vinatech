
-- 배면 검사결과
CREATE PROC usp_VisionGroup2InspectionInfo_dashboard
AS
BEGIN
	SELECT VGI2.InspectionNo
		  ,VGI2.MachineID
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
		  ,VGI2.DecisionDateTime
	   from STB_VisionGroup2InspectionInfo VGI2
END
