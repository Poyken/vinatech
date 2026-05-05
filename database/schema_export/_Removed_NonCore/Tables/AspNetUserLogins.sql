CREATE TABLE [dbo].[AspNetUserLogins] (
    [LoginProvider] NVARCHAR(450) NOT NULL DEFAULT ,
    [ProviderKey] NVARCHAR(450) NOT NULL DEFAULT ,
    [ProviderDisplayName] NVARCHAR(MAX) NULL DEFAULT ,
    [UserId] NVARCHAR(450) NOT NULL DEFAULT ,
    CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED ([LoginProvider], [ProviderKey])
);
GO

