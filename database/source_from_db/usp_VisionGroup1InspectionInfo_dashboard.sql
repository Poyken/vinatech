
-- 전면 검사결과
CREATE PROC usp_VisionGroup1InspectionInfo_dashboard
AS
BEGIN
	SELECT VGI1.InspectionNo
		  ,VGI1.MachineID
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
		  ,VGI1.DecisionDateTime
	   from STB_VisionGroup1InspectionInfo VGI1
END
