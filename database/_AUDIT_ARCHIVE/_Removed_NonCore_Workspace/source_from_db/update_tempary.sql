CREATE PROC update_tempary
@IDCODE NVARCHAR(50)
as
begin

DECLARE @id int
		SELECT 
				@id = ID
		FROM STB_VN_FINISHGOODS


		update STB_VN_FINISHGOODS
		set IDCODE = @IDCODE
		WHERE ID = @id
end