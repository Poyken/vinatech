CREATE TABLE [dbo].[AspNetUserTokens] (
    [UserId] NVARCHAR(450) NOT NULL DEFAULT ,
    [LoginProvider] NVARCHAR(450) NOT NULL DEFAULT ,
    [Name] NVARCHAR(450) NOT NULL DEFAULT ,
    [Value] NVARCHAR(MAX) NULL DEFAULT ,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED ([UserId], [LoginProvider], [Name])
);
GO

