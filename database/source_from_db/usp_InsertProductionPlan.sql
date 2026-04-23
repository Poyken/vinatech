
CREATE PROCEDURE [dbo].[usp_InsertProductionPlan]
    @pMonth INT = NULL,
    @pDatePlan DATE = NULL,
    @pDayOfWeek NVARCHAR(10) = NULL,
    @pInputESR NUMERIC(18, 2) = 0,
    @pNGESR NUMERIC(18, 2) = 0,
    @pInputSD NUMERIC(18, 2) = 0,
    @pNGSD NUMERIC(18, 2) = 0,
    @pNoteESR NVARCHAR(255) = NULL,
    @pNoteSD NVARCHAR(255) = NULL,
    @pUserID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Khai báo biến để giữ ID vừa tạo
    DECLARE @NewID INT;

    INSERT INTO STB_ProductionPlan (
        Month, DatePlan, DayOfWeek, InputESR, NGESR, 
        InputSD, NGSD, NoteModelNGESR, NoteModelNGSD, CreateUserID
    )
    VALUES (
        @pMonth, @pDatePlan, @pDayOfWeek, @pInputESR, @pNGESR, 
        @pInputSD, @pNGSD, @pNoteESR, @pNoteSD, @pUserID
    );

    -- Lấy ID cuối cùng được chèn vào
    SET @NewID = SCOPE_IDENTITY();

    -- Thay vì chỉ lấy ID, ta select tất cả các trường của dòng vừa tạo
    SELECT * FROM STB_ProductionPlan 
    WHERE PlanID = @NewID;
END