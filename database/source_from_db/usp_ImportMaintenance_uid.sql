-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-01
-- Description:	thêm bảo trì
-- exec usp_ImportMaintenance_uid 'haitrieu','Vi','Cell line #5','Stripping','test','test','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImportMaintenance_uid]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCellLineID int,
	@pStepID int,
	@pTaskDesc NVARCHAR(200)=NULL,
	@pAs NVARCHAR(100)=NULL,
	@pTobe NVARCHAR(100)=NULL,
	@pEffect NVARCHAR(100)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
	-- Xử lý ngoại lệ
	BEGIN TRY
	BEGIN TRANSACTION; --Bắt đầu mở giao dịch
	-- Bắt đàu xử lý ngoại lệ
	-- Láy Celline
	
	
	INSERT INTO MaintenanceTasks (
			StepID,
			TaskDescription,
			AsIs,
			ToBe,
			Cause,
			PerformedBy,
			CreatedAt,
			CellLineID
		)
		VALUES (
			@pStepID,
			@pTaskDesc,
			@pAs,
			@pTobe,
			@pEffect,
			@pProcessUserID,
			GETDATE(),
			@pCellLineID
		);
	COMMIT TRANSACTION; --  Thành công → lưu tất cả
   END TRY
    BEGIN CATCH
	    ROLLBACK TRANSACTION; -- Có lỗi → rollback toàn bộ

    -- Ghi log lỗi hoặc in ra
    PRINT N'Lỗi: ' + ERROR_MESSAGE();
    
	END CATCH
END
