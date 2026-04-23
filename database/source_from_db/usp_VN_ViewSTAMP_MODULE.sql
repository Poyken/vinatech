
create proc usp_VN_ViewSTAMP_MODULE
AS
BEGIN
		SELECT
				MaterialCode,
				MaterialName,
				Voltage,
				Farad,
				Rating,
				PartNo,
				CONVERT(DATE,CreateDateTime) AS CreateDateTime,
				RIGHT(CreateDateTime,8) AS Timecreate,
				CONVERT(DATE,ChangeDateTime) AS ChangeDateTime,
				RIGHT(ChangeDateTime,8) AS TimeChange
		FROM 
				 STB_VN_STAMP_MODULE WITH(NOLOCK)
END