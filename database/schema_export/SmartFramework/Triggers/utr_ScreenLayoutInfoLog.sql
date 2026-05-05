-- Trigger: utr_ScreenLayoutInfoLog
CREATE TRIGGER utr_ScreenLayoutInfoLog
   ON  STB_ScreenLayoutInfo
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	Declare @BefXmlLayout NVARCHAR(MAX)
	       ,@AftXmlLayout NVARCHAR(MAX)

	-- INSERT 이면, 
	IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED) BEGIN
		INSERT INTO ScreenLayoutInfoLog 
		(
			EventType
           ,PostTime
           ,Name
           ,Version
           ,DeveloperVersion
           ,BefLayout
           ,AftLayout
           ,BefXmlLayout
           ,AftXmlLayout
           ,Description
           ,Snapshot
		)
		SELECT 'INSERT'
		      ,GETDATE()
			  ,Name
			  ,Version
			  ,DeveloperVersion
			  ,NULL
			  ,Layout
			  ,NULL
			  ,XMLLayout
			  ,Description
			  ,Snapshot
		  FROM inserted
	END

	-- UPDATE 이면,
	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED) BEGIN
		SELECT @BefXmlLayout = XMLLayout FROM deleted
		SELECT @AftXmlLayout = XMLLayout FROM inserted

		IF @BefXmlLayout <> @AftXmlLayout BEGIN
			INSERT INTO ScreenLayoutInfoLog 
			(
				EventType
			   ,PostTime
			   ,Name
			   ,Version
			   ,DeveloperVersion
			   ,BefLayout
			   ,AftLayout
			   ,BefXmlLayout
			   ,AftXmlLayout
			   ,Description
			   ,Snapshot
			)
			SELECT 'UPDATE'
				  ,GETDATE()
				  ,Name
				  ,Version
				  ,DeveloperVersion
				  ,(SELECT Layout FROM deleted)
				  ,Layout
				  ,(SELECT XMLLayout FROM deleted)
				  ,XMLLayout
				  ,Description
				  ,Snapshot
			  FROM inserted
			END
	END

	-- DELETE 이면,
	IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED) BEGIN
		INSERT INTO ScreenLayoutInfoLog 
		(
			EventType
           ,PostTime
           ,Name
           ,Version
           ,DeveloperVersion
           ,BefLayout
           ,AftLayout
           ,BefXmlLayout
           ,AftXmlLayout
           ,Description
           ,Snapshot
		)
		SELECT 'UPDATE'
		      ,GETDATE()
			  ,Name
			  ,Version
			  ,DeveloperVersion
			  ,Layout
			  ,NULL
			  ,XMLLayout
			  ,NULL
			  ,Description
			  ,Snapshot
		  FROM deleted
	END
END

GO

