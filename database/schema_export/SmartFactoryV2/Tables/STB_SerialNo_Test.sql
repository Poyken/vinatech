CREATE TABLE [dbo].[STB_SerialNo_Test] (
    [BaseDate] DATE NOT NULL DEFAULT ,
    [SerialNo] INT NOT NULL DEFAULT ,
    CONSTRAINT [PK_STB_SerialNo_Test] PRIMARY KEY CLUSTERED ([BaseDate], [SerialNo])
);
GO

