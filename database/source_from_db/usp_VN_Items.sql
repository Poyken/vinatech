CREATE PROC [dbo].[usp_VN_Items]
@pProcessLanguage VARCHAR(20),
@pProcessUserID VARCHAR(20)
AS
BEGIN
		SELECT
				CodeItem,
				Item
				
		FROM STB_VN_ITEM WITH (NOLOCK)
		WHERE IsUsed=1
END

--select * from STB_VN_ITEM

--update STB_VN_ITEM
--set IsUsed = 0
--where IDI = IDI

--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'BTP SÔ CHA SAU WINDING',N'BTP SÔ CHA SAU WINDING','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'BTP SÔ CHA ĐÃ LẮP CAO SU',N'BTP SÔ CHA ĐÃ LẮP CAO SU','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'BTP SÔ CHA ĐÃ NGÂM DUNG DỊCH',N'BTP SÔ CHA ĐÃ NGÂM DUNG DỊCH','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'BTP SAU BEADING',N'BTP SAU BEADING','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'BTP SAU BỌC VỎ',N'BTP SAU BỌC VỎ','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'ĐIỆN CỰC PHẾ',N'ĐIỆN CỰC PHẾ','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'TAN CHA PHẾ',N'TAN CHA PHẾ','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'DUNG DỊCH PHẾ',N'DUNG DỊCH PHẾ','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'VỎ NHÔM PHẾ',N'VỎ NHÔM PHẾ','1')
--INSERT INTO STB_VN_ITEM (CodeItem,Item,IsUsed) VALUES (N'GIẤY NGĂN PHẾ',N'GIẤY NGĂN PHẾ','1')


--select * from STB_VN_ITEM