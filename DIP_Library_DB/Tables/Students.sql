﻿CREATE TABLE [dbo].[Students]
(
	[StudentID] NVARCHAR(9) NOT NULL,
	[FirstName] NVARCHAR(50) NOT NULL,
	[LastName] NVARCHAR(50) NOT NULL,
	[Email] NVARCHAR(100) NULL,
	[PhoneNumber] NVARCHAR(12) NULL,
	CONSTRAINT PK_STUDENT PRIMARY KEY (StudentID)
)
