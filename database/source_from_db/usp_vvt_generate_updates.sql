CREATE PROCEDURE [dbo].[usp_vvt_generate_updates] (
    @fullquery              nvarchar(max) = '',
    @ignore_field_input     nvarchar(MAX) = '',
    @PK_COLUMN_NAME         nvarchar(MAX) = ''
)
AS

SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
/*
-- For Standard USAGE: (where clause is mandatory)
                EXEC [sp_generate_updates] 'select * from dbo.mytable where mytext=''1''  ' 
        OR
                SET QUOTED_IDENTIFIER OFF 
                EXEC [sp_generate_updates] "select * from dbo.mytable where mytext='1'    "

-- For ignoring specific columns  (to ignore in the UPDATE and INSERT SQL statement) 
                EXEC [sp_generate_updates] 'select * from dbo.mytable where 1=1  ' , 'Column01,Column02'

-- For just updates without insert statement (replace the * )
                EXEC [sp_generate_updates] 'select Column01, Column02 from dbo.mytable where 1=1  ' 

-- For tables without a primary key: construct the key in the third variable
                EXEC [sp_generate_updates] 'select * from dbo.mytable where 1=1  '  ,'','your_chosen_primary_key_Col1,key_Col2'

-- For complex updates with JOINED tables 
                EXEC [sp_generate_updates] 'select o1.Name,  o1.category, o2.name+ '_hello_world' as #name 
                                            from overnightsetting o1 
                                            inner join overnightsetting o2  on o1.name=o2.name  
                                            where o1.name like '%appserver%' 
                (REMARK about above:   the use of # in front of a column name (so #abc) can do an update of that columname (abc) with any column from an inner joined table where you use the alias #abc )


-------------README for the deeper interested person:
            Goal of the Stored PROCEDURE is to get updates from simple SQL SELECT statements. It is made ot be simple but fast and powerfull. As always => power is nothing without control, so check before you execute.
            Its power sits also in the fact that you can make insert statements, so combined gives you a  "IF NOT EXISTS()  INSERT "   capability. 

            The scripts work were there are primary keys or identity columns on table you want to update (/ or make inserts for).
            It will also works when no primary keys / identity column exist(s) and you define them yourselve. But then be carefull (duplicate hits can occur). When the table has a primary key it will always be used.
            The script works with a real  temporary table, made on the fly   (APPROPRIATE RIGHTS needed), to put the values inside from the script, then add 3 columns for constructing the "insert into tableX (...) values ()" ,  and the 2 update statement.
            We work with temporary structures like   "where columnname = {Columnname}" and then later do the update on that temptable for the columns values found on that same line.
                    example  "where columnname = {Columnname}"  for birthdate becomes   "where birthdate = {birthdate}" an then we find the birthdate value on that line inside the temp table.
            So then the statement becomes  "where birthdate = {19800417}"
            Enjoy releasing scripts as of now...                                        by  Pieter van Nederkassel  - freeware "CC BY-SA" (+use at own risk)
*/
IF OBJECT_ID('tempdb..#ignore','U') IS NOT NULL     DROP TABLE #ignore
DECLARE @stringsplit_table               TABLE (col nvarchar(255), dtype  nvarchar(255)) -- table to store the primary keys or identity key
DECLARE @PK_condition                    nvarchar(512), -- placeholder for WHERE pk_field1 = pk_value1 AND pk_field2 = pk_value2 AND ...
        @pkstring                        NVARCHAR(512),  -- sting to store the primary keys or the idendity key
        @table_name                      nvarchar(512), -- (left) table name, including schema
        @table_N_where_clause            nvarchar(max), -- tablename 
        @table_alias                     nvarchar(512), -- holds the (left) table alias if one available, else @table_name
        @table_schema                    NVARCHAR(30),  -- schema of @table_name
        @update_list1                    NVARCHAR(MAX), -- placeholder for SET fields section of update
        @update_list2                    NVARCHAR(MAX), -- placeholder for SET fields section of update value comming from other tables in the join, other than the main table to update => updateof base table possible with inner join
        @list_all_cols                   BIT = 0,       -- placeholder for values for the insert into table VALUES command
        @select_list                     NVARCHAR(MAX), -- placeholder for SELECT fields of (left) table
        @COLUMN_NAME                     NVARCHAR(255), -- will hold column names of the (left) table
        @sql                             NVARCHAR(MAX), -- sql statement variable
        @getdate                         NVARCHAR(17),  -- transform getdate() to YYYYMMDDHHMMSSMMM
        @tmp_table                       NVARCHAR(255), -- will hold the name of a physical temp table
        @pk_separator                    NVARCHAR(1),   -- separator used in @PK_COLUMN_NAME if provided (only checking obvious ones ,;|-)
        @COLUMN_NAME_DATA_TYPE           NVARCHAR(100), -- needed for insert statements to convert to right text string
        @own_pk                          BIT = 0        -- check if table has PK (0) or if provided PK will be used (1)




set @ignore_field_input=replace(replace(replace(@ignore_field_input,' ',''),'[',''),']','')
set @PK_COLUMN_NAME=    replace(replace(replace(@PK_COLUMN_NAME,    ' ',''),'[',''),']','')

-- first we remove all linefeeds from the user query
set @fullquery=replace(replace(replace(@fullquery,char(10),''),char(13),' '),'  ',' ')
set @table_N_where_clause=@fullquery
if charindex ('order by' , @table_N_where_clause) > 0
    print ' WARNING:        ORDER BY NOT ALLOWED IN UPDATE ...'
if @PK_COLUMN_NAME <> ''
    select ' WARNING:        IF you select your own primary keys, make double sure before doing the update statements below!! '
--print @table_N_where_clause
if charindex ('select ' , @table_N_where_clause) = 0
    set @table_N_where_clause= 'select * from ' + @table_N_where_clause
if charindex ('select ' , @table_N_where_clause) > 0
    exec (@table_N_where_clause)

set @table_N_where_clause=rtrim(ltrim(substring(@table_N_where_clause,CHARINDEX(' from ', @table_N_where_clause )+6, 4000)))
--print @table_N_where_clause 
set @table_name=left(@table_N_where_clause,CHARINDEX(' ', @table_N_where_clause )-1)


IF CHARINDEX('where ', @table_N_where_clause) > 0             SELECT @table_alias = LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(@table_N_where_clause,1, CHARINDEX('where ', @table_N_where_clause )-1),'(nolock)',''),@table_name,'')))
IF CHARINDEX('join ',  @table_alias) > 0                      SELECT @table_alias = SUBSTRING(@table_alias, 1, CHARINDEX(' ', @table_alias)-1) -- until next space
IF LEN(@table_alias) = 0                                      SELECT @table_alias = @table_name
IF (charindex (' *' , @fullquery) > 0 or charindex (@table_alias+'.*' , @fullquery) > 0 )     set @list_all_cols=1
/*       
       print @fullquery     
       print @table_alias
       print @table_N_where_clause
       print @table_name
*/


-- Prepare PK condition
        SELECT @table_schema = CASE WHEN CHARINDEX('.',@table_name) > 0 THEN LEFT(@table_name, CHARINDEX('.',@table_name)-1) ELSE 'dbo' END

        SELECT @PK_condition = ISNULL(@PK_condition + ' AND ', '') + QUOTENAME('pk_'+COLUMN_NAME) + ' = ' + QUOTENAME('pk_'+COLUMN_NAME,'{')
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
        AND TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
        AND TABLE_SCHEMA = @table_schema

        SELECT @pkstring = ISNULL(@pkstring + ', ', '') + @table_alias + '.' + QUOTENAME(COLUMN_NAME) + ' AS pk_' + COLUMN_NAME
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE i1
        WHERE OBJECTPROPERTY(OBJECT_ID(i1.CONSTRAINT_SCHEMA + '.' + QUOTENAME(i1.CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
        AND i1.TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
        AND i1.TABLE_SCHEMA = @table_schema

            -- if no primary keys exist then we try for identity columns
                IF @PK_condition is null SELECT @PK_condition = ISNULL(@PK_condition + ' AND ', '') + QUOTENAME('pk_'+COLUMN_NAME) + ' = ' + QUOTENAME('pk_'+COLUMN_NAME,'{')
                FROM  INFORMATION_SCHEMA.COLUMNS
                WHERE COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1 
                AND TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
                AND TABLE_SCHEMA = @table_schema

                IF @pkstring is null SELECT @pkstring = ISNULL(@pkstring + ', ', '') + @table_alias + '.' + QUOTENAME(COLUMN_NAME) + ' AS pk_' + COLUMN_NAME
                FROM  INFORMATION_SCHEMA.COLUMNS
                WHERE COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1 
                AND TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
                AND TABLE_SCHEMA = @table_schema
-- Same but in form of a table

        INSERT INTO @stringsplit_table
        SELECT 'pk_'+i1.COLUMN_NAME as col, i2.DATA_TYPE as dtype
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE i1
        inner join INFORMATION_SCHEMA.COLUMNS i2
        on  i1.TABLE_NAME = i2.TABLE_NAME AND i1.TABLE_SCHEMA =  i2.TABLE_SCHEMA
        WHERE OBJECTPROPERTY(OBJECT_ID(i1.CONSTRAINT_SCHEMA + '.' + QUOTENAME(i1.CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
        AND i1.TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
        AND i1.TABLE_SCHEMA = @table_schema

                -- if no primary keys exist then we try for identity columns
                IF 0=(select count(*) from @stringsplit_table) INSERT INTO @stringsplit_table
                SELECT 'pk_'+i2.COLUMN_NAME as col, i2.DATA_TYPE as dtype
                FROM INFORMATION_SCHEMA.COLUMNS i2
                WHERE COLUMNPROPERTY(object_id(i2.TABLE_SCHEMA+'.'+i2.TABLE_NAME), i2.COLUMN_NAME, 'IsIdentity') = 1 
                AND i2.TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
                AND i2.TABLE_SCHEMA = @table_schema

-- NOW handling the primary key given as parameter to the main batch

SELECT @pk_separator = ',' -- take this as default, we'll check lower if it's a different one
IF (@PK_condition IS NULL OR @PK_condition = '') AND @PK_COLUMN_NAME <> ''
BEGIN
    IF CHARINDEX(';', @PK_COLUMN_NAME) > 0
        SELECT @pk_separator = ';'
    ELSE IF CHARINDEX('|', @PK_COLUMN_NAME) > 0
        SELECT @pk_separator = '|'
    ELSE IF CHARINDEX('-', @PK_COLUMN_NAME) > 0
        SELECT @pk_separator = '-'

    SELECT @PK_condition = NULL -- make sure to make it NULL, in case it was ''
    INSERT INTO @stringsplit_table
    SELECT LTRIM(RTRIM(x.value)) , 'datetime'  FROM STRING_SPLIT(@PK_COLUMN_NAME, @pk_separator) x  
    SELECT @PK_condition = ISNULL(@PK_condition + ' AND ', '') + QUOTENAME(x.col) + ' = ' + replace(QUOTENAME(x.col,'{'),'{','{pk_')
      FROM @stringsplit_table x

    SELECT @PK_COLUMN_NAME = NULL -- make sure to make it NULL, in case it was ''
    SELECT @PK_COLUMN_NAME = ISNULL(@PK_COLUMN_NAME + ', ', '') + QUOTENAME(x.col) + ' as pk_' + x.col
      FROM @stringsplit_table x
    --print 'pkcolumns  '+ isnull(@PK_COLUMN_NAME,'')
    update @stringsplit_table set col='pk_' + col
    SELECT @own_pk = 1
END
ELSE IF (@PK_condition IS NULL OR @PK_condition = '') AND @PK_COLUMN_NAME = ''
BEGIN
    RAISERROR('No Primary key or Identity column available on table. Add some columns as the third parameter when calling this SP to make your own temporary PK., also remove  [] from tablename',17,1)
END


-- IF there are no primary keys or an identity key in the table active, then use the given columns as a primary key


if isnull(@pkstring,'')   = ''  set    @pkstring  = @PK_COLUMN_NAME
IF ISNULL(@pkstring, '') <> ''  SELECT @fullquery = REPLACE(@fullquery, 'SELECT ','SELECT ' + @pkstring + ',' )
--print @pkstring




-- ignore fields for UPDATE STATEMENT (not ignored for the insert statement,  in iserts statement we ignore only identity Columns and the columns provided with the main stored proc )
-- Place here all fields that you know can not be converted to nvarchar() values correctly, an thus should not be scripted for updates)
-- for insert we will take these fields along, although they will be incorrectly represented!!!!!!!!!!!!!.
SELECT           ignore_field = 'uniqueidXXXX' INTO #ignore 
UNION ALL SELECT ignore_field = 'UPDATEMASKXXXX'
UNION ALL SELECT ignore_field = 'UIDXXXXX'
UNION ALL SELECT value FROM  string_split(@ignore_field_input,@pk_separator)




SELECT @getdate = REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(30), GETDATE(), 121), '-', ''), ' ', ''), ':', ''), '.', '')
SELECT @tmp_table = 'Release_DATA__' + @getdate + '__' + REPLACE(@table_name,@table_schema+'.','') 

SET @sql = replace( @fullquery,  ' from ',  ' INTO ' + @tmp_table +' from ')
----print (@sql)
exec (@sql)



SELECT @sql = N'alter table ' + @tmp_table + N'  add update_stmt1  nvarchar(max), update_stmt2 nvarchar(max) , update_stmt3 nvarchar(max)'
EXEC (@sql)

-- Prepare update field list (only columns from the temp table are taken if they also exist in the base table to update)
SELECT @update_list1 = ISNULL(@update_list1 + ', ', '') + 
                      CASE WHEN C1.COLUMN_NAME = 'ModifiedBy' THEN '[ModifiedBy] = left(right(replace(CONVERT(VARCHAR(19),[Modified],121),''''-'''',''''''''),19) +''''-''''+right(SUSER_NAME(),30),50)'
                           WHEN C1.COLUMN_NAME = 'Modified' THEN '[Modified] = GETDATE()'
                           ELSE QUOTENAME(C1.COLUMN_NAME) + ' = ' + QUOTENAME(C1.COLUMN_NAME,'{')
                      END
FROM INFORMATION_SCHEMA.COLUMNS c1
inner join INFORMATION_SCHEMA.COLUMNS c2
on c1.COLUMN_NAME =c2.COLUMN_NAME and c2.TABLE_NAME = REPLACE(@table_name,@table_schema+'.','')  AND c2.TABLE_SCHEMA = @table_schema
WHERE c1.TABLE_NAME = @tmp_table --REPLACE(@table_name,@table_schema+'.','') 
AND QUOTENAME(c1.COLUMN_NAME) NOT IN (SELECT QUOTENAME(ignore_field) FROM #ignore) -- eliminate binary, image etc value here
AND COLUMNPROPERTY(object_id(c2.TABLE_SCHEMA+'.'+c2.TABLE_NAME), c2.COLUMN_NAME, 'IsIdentity') <> 1
AND NOT EXISTS (SELECT 1 
                  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku 
                 WHERE 1 = 1
                   AND ku.TABLE_NAME = c2.TABLE_NAME
                   AND ku.TABLE_SCHEMA = c2.TABLE_SCHEMA
                   AND ku.COLUMN_NAME = c2.COLUMN_NAME
                   AND OBJECTPROPERTY(OBJECT_ID(ku.CONSTRAINT_SCHEMA + '.' + QUOTENAME(ku.CONSTRAINT_NAME)), 'IsPrimaryKey') = 1)
AND NOT EXISTS (SELECT 1 FROM @stringsplit_table x WHERE x.col = c2.COLUMN_NAME AND @own_pk = 1)

-- Prepare update field list  (here we only take columns that commence with a #, as this is our queue for doing the update that comes from an inner joined table)
SELECT @update_list2 = ISNULL(@update_list2 + ', ', '') +  QUOTENAME(replace( C1.COLUMN_NAME,'#','')) + ' = ' + QUOTENAME(C1.COLUMN_NAME,'{')
FROM INFORMATION_SCHEMA.COLUMNS c1
WHERE c1.TABLE_NAME = @tmp_table --AND c1.TABLE_SCHEMA = @table_schema
AND QUOTENAME(c1.COLUMN_NAME) NOT IN (SELECT QUOTENAME(ignore_field) FROM #ignore) -- eliminate binary, image etc value here
AND c1.COLUMN_NAME like '#%'

-- similar for select list, but take all fields
SELECT @select_list = ISNULL(@select_list + ', ', '') + QUOTENAME(COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE TABLE_NAME = REPLACE(@table_name,@table_schema+'.','') 
AND TABLE_SCHEMA = @table_schema
AND COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') <> 1  -- Identity columns are filled automatically by MSSQL, not needed at Insert statement
AND QUOTENAME(c.COLUMN_NAME) NOT IN (SELECT QUOTENAME(ignore_field) FROM #ignore) -- eliminate binary, image etc value here


SELECT @PK_condition = REPLACE(@PK_condition, '[pk_', '[')
set @select_list='if not exists (select * from '+  REPLACE(@table_name,@table_schema+'.','') +'  where '+  @PK_condition +')  INSERT INTO '+ REPLACE(@table_name,@table_schema+'.','')   + '('+ @select_list  + ') VALUES (' + replace(replace(@select_list,'[','{'),']','}') + ')'
SELECT @sql = N'UPDATE ' + @tmp_table + ' set update_stmt1 = ''' + @select_list + '''' 
if @list_all_cols=1 EXEC (@sql)



--print 'select==========  ' + @select_list
--print 'update==========  ' + @update_list1


SELECT @sql = N'UPDATE ' + @tmp_table + N'
set update_stmt2 = CONVERT(NVARCHAR(MAX),''UPDATE ' + @table_name + 
                                          N' SET ' + @update_list1 + N''' + ''' +
                                          N' WHERE ' + @PK_condition + N''') ' 

EXEC (@sql)
--print @sql



SELECT @sql = N'UPDATE ' + @tmp_table + N'
set update_stmt3 = CONVERT(NVARCHAR(MAX),''UPDATE ' + @table_name + 
                                          N' SET ' + @update_list2 + N''' + ''' +
                                          N' WHERE ' + @PK_condition + N''') ' 

EXEC (@sql)
--print @sql


-- LOOPING OVER ALL base tables column for the INSERT INTO .... VALUES
DECLARE c_columns CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT COLUMN_NAME, DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = (CASE WHEN @list_all_cols=0 THEN @tmp_table ELSE REPLACE(@table_name,@table_schema+'.','') END )
    AND TABLE_SCHEMA = @table_schema
        UNION--pned
    SELECT col, 'datetime' FROM @stringsplit_table

OPEN c_columns
FETCH NEXT FROM c_columns INTO @COLUMN_NAME, @COLUMN_NAME_DATA_TYPE
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @sql = 
    CASE WHEN @COLUMN_NAME_DATA_TYPE IN ('char','varchar','nchar','nvarchar')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('float','real','money','smallmoney')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],126)),   '''''''','''''''''''') + '''''''', ''NULL'')) '
        WHEN @COLUMN_NAME_DATA_TYPE IN ('uniqueidentifier')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('text','ntext')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('xxxx','yyyy')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('binary','varbinary')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('XML','xml')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],0)),     '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('datetime','smalldatetime')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],121)),   '''''''','''''''''''') + '''''''', ''NULL'')) '
    ELSE  
                  N'UPDATE ' + @tmp_table + N' SET update_stmt1 = REPLACE(update_stmt1, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) '
    END
    ----PRINT @sql
    EXEC (@sql)
    FETCH NEXT FROM c_columns INTO @COLUMN_NAME, @COLUMN_NAME_DATA_TYPE
END
CLOSE c_columns
DEALLOCATE c_columns

--SELECT col FROM @stringsplit_table -- these are the primary keys

-- LOOPING OVER ALL temp tables column for the Update values
DECLARE c_columns CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT COLUMN_NAME,DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME =  @tmp_table --    AND TABLE_SCHEMA = @table_schema
       UNION--pned
    SELECT col, 'datetime' FROM @stringsplit_table

OPEN c_columns
FETCH NEXT FROM c_columns INTO @COLUMN_NAME, @COLUMN_NAME_DATA_TYPE
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @sql = 
    CASE WHEN @COLUMN_NAME_DATA_TYPE IN ('char','varchar','nchar','nvarchar')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')) ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('float','real','money','smallmoney')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],126)),   '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],126)),   '''''''','''''''''''') + '''''''', ''NULL'')) '
        WHEN @COLUMN_NAME_DATA_TYPE IN ('uniqueidentifier')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL''))  ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('text','ntext')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL''))  ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('xxxx','yyyy')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL''))  ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('binary','varbinary')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL''))  ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('XML','xml')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],0)),     '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],0)),     '''''''','''''''''''') + '''''''', ''NULL''))  ' 
        WHEN @COLUMN_NAME_DATA_TYPE IN ('datetime','smalldatetime')
            THEN  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],121)),   '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'],121)),   '''''''','''''''''''') + '''''''', ''NULL''))  ' 
    ELSE    
                  N'UPDATE ' + @tmp_table + N' SET update_stmt2 = REPLACE(update_stmt2, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL'')), update_stmt3 = REPLACE(update_stmt3, ''{' + @COLUMN_NAME + N'}'', ISNULL('''''''' + REPLACE(RTRIM(CONVERT(NVARCHAR(MAX),[' + @COLUMN_NAME + N'])),       '''''''','''''''''''') + '''''''', ''NULL''))  ' 
    END
    EXEC (@sql)
    ----print @sql
    FETCH NEXT FROM c_columns INTO @COLUMN_NAME, @COLUMN_NAME_DATA_TYPE
END
CLOSE c_columns
DEALLOCATE c_columns

SET @sql = 'Select * from  ' + @tmp_table + ';'
--exec (@sql)

SELECT @sql = N'
IF OBJECT_ID(''' + @tmp_table + N''', ''U'') IS NOT NULL
BEGIN
       SELECT   ''USE ' + DB_NAME()  + '''  as executelist 
              UNION ALL
       SELECT   ''GO ''  as executelist 
              UNION ALL
       SELECT   '' /*PRESCRIPT CHECK  */              ' + replace(@fullquery,'''','''''')+''' as executelist 
              UNION ALL
       SELECT update_stmt1 as executelist FROM ' + @tmp_table + N' where update_stmt1 is not null
              UNION ALL
       SELECT update_stmt2 as executelist FROM ' + @tmp_table + N' where update_stmt2 is not null
              UNION ALL
       SELECT isnull(update_stmt3, '' add more columns inn query please'')  as executelist FROM ' + @tmp_table + N' where update_stmt3 is not null
              UNION ALL
       SELECT ''--EXEC usp_AddInstalledScript 5, 5, 1, 1, 1, ''''' + @tmp_table + '.sql'''', 2 ''  as executelist
              UNION ALL 
       SELECT   '' /*VERIFY WITH:  */              ' + replace(@fullquery,'''','''''')+''' as executelist 
              UNION ALL
       SELECT ''-- SCRIPT LOCATION:      F:\CopyPaste\++Distributionpoint++\Release_Management\' + @tmp_table + '.sql''  as executelist   
END'
exec (@sql)

SET @sql = 'DROP TABLE ' + @tmp_table + ';'
exec (@sql)