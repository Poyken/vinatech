-- Procedure: usp_DoRegistVOC




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-05
-- Description:	VOC 를 등록합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRegistVOC]
	@pSeqNo BIGINT = NULL OUTPUT,
	@pUserID VARCHAR(20),
	@pPhone VARCHAR(20) = NULL,
	@pEmail NVARCHAR(100) = NULL,
	@pTitle NVARCHAR(200),
	@pContents NVARCHAR(MAX),
	@pSnapshot VARBINARY(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			@pSeqNo = ISNULL(MAX(SeqNo),0) + 1
	FROM
			STB_VOC

    INSERT INTO STB_VOC
	(
		SeqNo,
		UserID,
		Phone,
		Email,
		Title,
		Contents,
		CreateDateTime,
		Snapshot
	)
	VALUES
	(
		@pSeqNo,
		@pUserID,
		@pPhone,
		@pEmail,
		@pTitle,
		@pContents,
		GETDATE(),
		@pSnapshot
	)
END





GO

