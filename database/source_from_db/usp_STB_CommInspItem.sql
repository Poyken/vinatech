CREATE Proc [dbo].[usp_STB_CommInspItem]
@CommInspItemCode NVARCHAR(1500),
@CommInspTypeCode NVARCHAR(1500),
@CompanyCode NVARCHAR(150),
@WorkCenterCode NVARCHAR(1500),
@DisplayIndex NVARCHAR(1500),
@CommInspItemGroup1 NVARCHAR(1500),
@CommInspItemGroup3 NVARCHAR(1500),
@CommInspItemName VARCHAR(1500),
@CommInspItemDesc VARCHAR(1500),
@CommInspInputType NVARCHAR(1050),
@CommInspSelectGroupCode NVARCHAR(1500),
@CommInspUpper NVARCHAR(1500),
@CommInspLower NVARCHAR(1500),
@ItemImageFileID NVARCHAR(1500),
@ItemTargetQty NVARCHAR(1500),
@IsIndividualSpec NVARCHAR(1500)
AS
BEGIN

INSERT INTO STB_CommInspItem
(
CommInspItemCode,
CommInspTypeCode,
CompanyCode,
WorkCenterCode,
DisplayIndex,
CommInspItemGroup1,
CommInspItemGroup3,
CommInspItemName,
CommInspItemDesc,
CommInspInputType,
CommInspSelectGroupCode,
CommInspUpper,
CommInspLower,
ItemImageFileID,
ItemTargetQty,
IsIndividualSpec
)
VALUES
(
@CommInspItemCode,
@CommInspTypeCode,
@CompanyCode,
@WorkCenterCode,
@DisplayIndex,
@CommInspItemGroup1,
@CommInspItemGroup3,
@CommInspItemName,
@CommInspItemDesc,
@CommInspInputType,
@CommInspSelectGroupCode,
@CommInspUpper,
@CommInspLower,
@ItemImageFileID,
@ItemTargetQty,
@IsIndividualSpec
)
END


-- select * from  STB_CommInspItem where WorkCenterCode = 'VVT_F2' and CommInspTypeCode='ROUTE_QUALITY2'


-- delete STB_CommInspItem where WorkCenterCode = 'VVT_F2'


--ALTER TABLE STB_CommInspItem 
--ALTER COLUMN CommInspItemName NVARCHAR(150)  NULL


--declare @t table (c nchar(1))

--insert into @t select '말'
--insert into @t select N'말'

--select c, ascii(c), unicode(c) from @t

--update @t set c = cast(c as nchar(1))

--select c, ascii(c), unicode(c) from @t