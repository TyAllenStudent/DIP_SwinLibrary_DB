﻿/*
Deployment script for DIP_Library_DB

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar LoadTestData "true"
:setvar DatabaseName "DIP_Library_DB"
:setvar DefaultFilePrefix "DIP_Library_DB"
:setvar DefaultDataPath "C:\Users\Ty\AppData\Local\Microsoft\VisualStudio\SSDT"
:setvar DefaultLogPath "C:\Users\Ty\AppData\Local\Microsoft\VisualStudio\SSDT"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Dropping [dbo].[FK_LOAN_BOOK]...';


GO
ALTER TABLE [dbo].[Loans] DROP CONSTRAINT [FK_LOAN_BOOK];


GO
PRINT N'Dropping [dbo].[FK_LOAN_STUDENT]...';


GO
ALTER TABLE [dbo].[Loans] DROP CONSTRAINT [FK_LOAN_STUDENT];


GO
PRINT N'Starting rebuilding table [dbo].[Books]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Books] (
    [ISBN]            NVARCHAR (50)  NOT NULL,
    [BookTitle]       NVARCHAR (100) NOT NULL,
    [YearPublished]   INT            NOT NULL,
    [AuthorID]        INT            NOT NULL,
    [AuthorFirstName] NVARCHAR (50)  NOT NULL,
    [AuthorSurName]   NVARCHAR (50)  NOT NULL,
    [AuthorTFN]       NVARCHAR (12)  NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_BOOK1] PRIMARY KEY CLUSTERED ([ISBN] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Books])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_Books] ([ISBN], [BookTitle], [YearPublished], [AuthorID], [AuthorFirstName], [AuthorSurName], [AuthorTFN])
        SELECT   [ISBN],
                 [BookTitle],
                 [YearPublished],
                 [AuthorID],
                 [AuthorFirstName],
                 [AuthorSurName],
                 [AuthorTFN]
        FROM     [dbo].[Books]
        ORDER BY [ISBN] ASC;
    END

DROP TABLE [dbo].[Books];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Books]', N'Books';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_BOOK1]', N'PK_BOOK', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Starting rebuilding table [dbo].[Loans]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Loans] (
    [StudentID]    NVARCHAR (9)  NOT NULL,
    [ISBN]         NVARCHAR (50) NOT NULL,
    [DateBorrowed] DATE          NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_LOAN1] PRIMARY KEY CLUSTERED ([StudentID] ASC, [ISBN] ASC, [DateBorrowed] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Loans])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_Loans] ([StudentID], [ISBN], [DateBorrowed])
        SELECT   [StudentID],
                 [ISBN],
                 [DateBorrowed]
        FROM     [dbo].[Loans]
        ORDER BY [StudentID] ASC, [ISBN] ASC, [DateBorrowed] ASC;
    END

DROP TABLE [dbo].[Loans];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Loans]', N'Loans';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_LOAN1]', N'PK_LOAN', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Altering [dbo].[Students]...';


GO
ALTER TABLE [dbo].[Students] ALTER COLUMN [PhoneNumber] NVARCHAR (10) NULL;


GO
PRINT N'Creating [dbo].[FK_LOAN_BOOK]...';


GO
ALTER TABLE [dbo].[Loans] WITH NOCHECK
    ADD CONSTRAINT [FK_LOAN_BOOK] FOREIGN KEY ([ISBN]) REFERENCES [dbo].[Books] ([ISBN]);


GO
PRINT N'Creating [dbo].[FK_LOAN_STUDENT]...';


GO
ALTER TABLE [dbo].[Loans] WITH NOCHECK
    ADD CONSTRAINT [FK_LOAN_STUDENT] FOREIGN KEY ([StudentID]) REFERENCES [dbo].[Students] ([StudentID]);


GO
IF '$(LoadTestData)' = 'true'

BEGIN

DELETE FROM Loans;
DELETE FROM Students;
DELETE FROM Books;

INSERT INTO STUDENTS (STUDENTID, FIRSTNAME, LASTNAME, EMAIL, PHONENUMBER) VALUES
('s12345678', 'Fred', 'Flintstone', '12345678@student.swin.edu.au', '0400 555 111'),
('s23456789', 'Barney', 'Rubble', '23456789@student.swin.edu.au', '0400 555 222'),
('s34567890', 'Bam-Bam', 'Rubble', '34567890@student.swin.edu.au', '0400 555 333');

INSERT INTO BOOKS (ISBN, BOOKTITLE, YEARPUBLISHED, AUTHORID, AUTHORFIRSTNAME, AUTHORSURNAME, AUTHORTFN) VALUES
('978-3-16-148410-0', 'Relationships with Databases, the ins and outs', 1970, 32567, 'Edgar', 'Codd', '150 111 222'),
('978-3-16-148410-1', 'Normalisation, how to make a database geek fit in.', 1973, 32567, 'Edgar', 'Codd', '150 111 222'),
('978-3-16-148410-2', 'TCP/IP, the protocol for the masses.', 1983, 76543, 'Vinton', 'Cerf', '150 222 333'),
('978-3-16-148410-3', 'The Man, the Bombe, and the Enigma.', 1940, 12345, 'Alan', 'Turing', '150 333 444');

INSERT INTO LOANS (STUDENTID, ISBN, DateBorrowed) VALUES
('s12345678', '978-3-16-148410-0', '10/01/2011'),
('s23456789', '978-3-16-148410-1', '30/03/2019');

END;
GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[Loans] WITH CHECK CHECK CONSTRAINT [FK_LOAN_BOOK];

ALTER TABLE [dbo].[Loans] WITH CHECK CHECK CONSTRAINT [FK_LOAN_STUDENT];


GO
PRINT N'Update complete.';


GO
