IF EXISTS (SELECT * FROM Sys.Objects WHERE object_id = OBJECT_ID(N'[dbo].[uspFindObjects]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspFindObjects]
GO

CREATE PROCEDURE uspFindObjects
    @ObjectType CHAR(2)=NULL,
    @SearchText VARCHAR(500) = NULL,
    @SearchType CHAR(1)=NULL,
    @OrderBy CHAR(1)='N'
AS
BEGIN
/***********************************************************************************************************
Procedure:    uspFindObjects
Source:  https://www.sqlservercentral.com/scripts/find-for-sql-objects-entities-or-text

Parameters: 1. @ObjectType    -    Type of object to be searched.
                    - U        :    Table
                    - P        :    Stored Procedure
                    - V        :    View
                    - FN    :    Function
                    - *        :    Find All (Tables, SP, Views, Functions)
            2. @SearchText    -    Text to be searched
            3. @SearchType    -    Type of data to be searched
                    - C        :    Column
                    - T        :    Text
            4. @OrderBy        -    Order of results to be returned. Default is by object name.
                    - N        :    ObjectName
                    Anything other than N is order by ObjectType

Purpose:    1. Find tables/stored procedures/functions/views by name. 
            2. Find tables having specific columns.
            3. Find a string inside stored procedure/views/functions.

Written by:    Sunil M. Chandurkar

Tested on:     SQL Server 2005

Date created: October 18, 2007

Example 1:    To search table with a name:
        
        EXEC uspFindObjects 'U','Client_Master','N'

Example 2:     To search table/stored procedure/views with specific name
        
        EXEC uspFindObjects '*','Client_Master','N'

Example 3:    To seach tables having specific columns

        EXEC uspFindObjects 'U','Client_ID','C'

Example 4:    To search text inside any Stored Procedure/View/Function

        EXEC uspFindObjects '*','City_Name','T'

***********************************************************************************************************/
    SET NOCOUNT ON
    CREATE TABLE #sysObjects
    (
        ObjectName VARCHAR(200),
        ObjectType VARCHAR(200)
    )
    
    SET @ObjectType = ISNULL(LTRIM(RTRIM(@ObjectType)),'')
    
    IF @ObjectType=''
    BEGIN
        PRINT 'Procedure ''uspFindObjects'' expects parameter ''@ObjectType'', which was not supplied.'
        RETURN
    END

    SET @SearchText = ISNULL(LTRIM(RTRIM(@SearchText)),'')
    IF @SearchText=''
    BEGIN
        PRINT 'Procedure ''uspFindObjects'' expects parameter ''@SearchText'', which was not supplied.'
        RETURN
    END
    SET @SearchType = ISNULL(LTRIM(RTRIM(@SearchType)),'N')
--Here search for an object by its name.
--E.g. Look for a table having a specific name
    IF LTRIM(RTRIM(@SearchType))='N'
        INSERT INTO #sysObjects
        SELECT    so.name,
                CASE so.XType    WHEN 'P' THEN 'Stored Procedure'
                                WHEN 'U' THEN 'TABLE'
                                WHEN 'V' THEN 'View'
                                WHEN 'FN' THEN 'Function'
                END 'Type'
        FROM    sysobjects so 
        WHERE    so.Name Like '%' + @SearchText +'%' AND 
                (@ObjectType='*' OR so.xtype=@ObjectType)
--search for text in stored procedures or views
    ELSE IF LTRIM(RTRIM(@SearchType))='T'
        INSERT INTO #sysObjects
        SELECT    so.name,
                CASE so.XType    WHEN 'P' THEN 'Stored Procedure'
                                WHEN 'U' THEN 'TABLE'
                                WHEN 'V' THEN 'View'
                                WHEN 'FN' THEN 'Function'
                END 'Type'
        FROM    SysObjects so INNER JOIN SysComments SCM ON so.id=scm.id AND scm.text LIKE '%' + @SearchText +'%' 
                AND (@ObjectType='*' OR so.xtype=@ObjectType)
--search for columns in tables
    ELSE IF LTRIM(RTRIM(@SearchType))='C'
        INSERT INTO #sysObjects
        SELECT    so.name,
                CASE so.XType    WHEN 'P' THEN 'Stored Procedure'
                                WHEN 'U' THEN 'TABLE'
                                WHEN 'V' THEN 'View'
                                WHEN 'FN' THEN 'Function'
                END 'Type'
        FROM    SysObjects so INNER JOIN syscolumns sc ON so.id=sc.id AND sc.name LIKE '%' + @SearchText +'%'
                AND (@ObjectType='*' OR so.xtype=@ObjectType)

    SET NOCOUNT OFF

    IF @OrderBy='N'
        SELECT * FROM #sysObjects ORDER BY ObjectName
    ELSE
        SELECT * FROM #sysObjects ORDER BY ObjectType,ObjectName

    SET NOCOUNT OFF
END
GO
