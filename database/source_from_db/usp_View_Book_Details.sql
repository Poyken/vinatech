CREATE PROC [dbo].[usp_View_Book_Details]
AS
BEGIN
	SELECT
	ID,
	MothDate,
	Stage,
	Code,
	ProductionName,
	Unit,
	Qty,
	QtyOut,
	StatusIn,
	StatusOut,
    --TotalInventory,
	Remark,
	DATEOUT,
	CreateDateTime,
	RIGHT(CreateDateTime,8) AS CreatTime,
	CreateUserID ,
	ChangeDateTime,
	RIGHT(ChangeDateTime,8) AS ChangeTime,
	ChangeUserID
	FROM
			STB_NOBOOK WITH(NOLOCK)

	GROUP BY 
	ID,
	MothDate,
	Stage,
	Code,
	ProductionName,
	Unit,
	Qty,
	QtyOut,
	StatusIn,
	StatusOut,
    TotalInventory,
	Remark,
	DATEOUT,
	CreateDateTime,
	CreateUserID ,
	ChangeDateTime,
	ChangeUserID
END