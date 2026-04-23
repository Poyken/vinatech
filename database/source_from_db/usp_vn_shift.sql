CREATE PROC [dbo].[usp_vn_shift]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @TimeServer NVARCHAR(50),
	        @TimeFromShiftS02 NVARCHAR(50),
			@TimeToShiftS02 NVARCHAR(50),
			@TimeFromShiftS01 NVARCHAR(50),
			@TiemToShiftS01 NVARCHAR(50)
			

	SET @TimeServer=CONVERT(VARCHAR(8),GETDATE(),108)

	SELECT @TimeFromShiftS01=CONVERT(VARCHAR(8),FromTime,108),@TiemToShiftS01=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS01'

	IF @TimeFromShiftS01 <=@TimeServer AND @TiemToShiftS01 >=@TimeServer

	BEGIN
	    SELECT CodeShift,NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS01'
	END

	SELECT @TimeFromShiftS02=CONVERT(VARCHAR(8),FromTime,108),@TimeToShiftS02=CONVERT(VARCHAR(8),ToTime,108)
	FROM dbo.STB_VN_Shift WITH(NOLOCK)
	WHERE IsUsed='True' AND CodeShift='CS02'

	IF @TimeFromShiftS02 <= @TimeServer AND @TimeToShiftS02 >=@TimeServer

	BEGIN
	    SELECT CodeShift,NameShift 
		FROM dbo.STB_VN_Shift WITH(NOLOCK)
		WHERE IsUsed='True' AND CodeShift='CS02'
	END
	
END

