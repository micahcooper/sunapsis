USE master;
GO
ALTER DATABASE [InternationalServices-staging] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

restore database [InternationalServices-staging]
from disk = N'\\serverName\folderName\fileName.bak'
WITH REPLACE
GO
