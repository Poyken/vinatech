CREATE PROC [dbo].[usp_VN_COUNTRYFINISHEDGOOD]
AS
BEGIN
		SELECT 
				CountryName
		FROM 
				STB_VN_COUNTRY WITH (NOLOCK)
END

-- insert into STB_VN_COUNTRY (CodeCountry,CountryName) values ('FI',N'Finland')

--delete STB_VN_COUNTRY where ID = 39	


--SELECT 
--				*
--		FROM 
--				STB_VN_COUNTRY --WITH (NOLOCK)



--SELECT CountryName, COUNT(*)
--FROM STB_VN_COUNTRY
--GROUP BY CountryName
--HAVING COUNT(*)>1

--select * from STB_VN_COUNTRY WHERE CountryName = 'Switzerland'


--delete STB_VN_COUNTRY where id='43'