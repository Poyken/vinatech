CREATE PROC usp_VN_HexaLable 
AS
BEGIN

		CREATE TABLE #Tbl 
		(
				
				NhiPhan NVARCHAR(10) NULL,
				Hexa NVARCHAR(10) NOT NULL PRIMARY KEY(Hexa),
				Sts BIT DEFAULT '1' NULL
		)

		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('0','00000')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('1','00001')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('2','00002')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('3','00003')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('4','00004')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('5','00005')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('6','00006')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('7','00007')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('8','00008')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('9','00009')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('10','0000A')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('11','0000B')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('12','0000C')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('13','0000D')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('14','0000E')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('15','0000F')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('16','0000G')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('17','0000H')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('18','0000I')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('19','0000J')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('20','0000K')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('21','0000L')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('22','0000M')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('23','0000N')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('24','0000O')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('25','0000P')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('26','0000Q')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('27','0000R')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('28','0000S')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('29','0000T')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('30','0000U')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('31','0000V')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('32','0000W')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('33','0000X')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('34','0000Y')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('35','0000Z')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('36','00010')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('37','00011')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('38','00012')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('39','00013')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('40','00014')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('41','00015')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('42','00016')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('43','00017')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('44','00018')
		INSERT INTO #Tbl (NhiPhan,Hexa) VALUES ('45','00019')

		SELECT
				NhiPhan,
				Hexa
		FROM 
			#Tbl

	  WHERE Sts = 1

	  drop table #Tbl
END