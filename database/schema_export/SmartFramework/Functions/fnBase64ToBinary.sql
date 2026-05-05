-- Function: fnBase64ToBinary



-- =============================================
-- Author:      <Kim Han Young>
-- Create date: <2015-12-23>
-- Description: <Base64 String to Binary>
-- =============================================
CREATE FUNCTION [dbo].[fnBase64ToBinary]
(
    @Base64 VARCHAR(MAX)
)
RETURNS VARBINARY(MAX)
AS
BEGIN
    DECLARE @Bin VARBINARY(MAX)
    
    /*
        SELECT CONVERT(VARCHAR(MAX), dbo.fnBase64ToBinary('Q29udmVydGluZyB0aGlzIHRleHQgdG8gQmFzZTY0Li4u'))
    */
    
    SET @Bin = CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@Base64"))', 'VARBINARY(MAX)')
 
    RETURN @Bin
END




GO

