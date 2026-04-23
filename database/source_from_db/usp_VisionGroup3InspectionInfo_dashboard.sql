
-- 핀홀
CREATE PROC usp_VisionGroup3InspectionInfo_dashboard
AS
BEGIN
	SELECT VGI3.InspectionNo
		  ,VGI3.MachineID
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
		  ,VGI3.DecisionDateTime
	   from STB_VisionGroup3InspectionInfo VGI3
END