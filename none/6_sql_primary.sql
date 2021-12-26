-- Create AG test database
USE [master]
GO
CREATE DATABASE DevTestAG
GO
USE [DevTestAG]
GO
CREATE TABLE Customers([CustomerID] int NOT NULL, [CustomerName] varchar(30) NOT NULL)
GO
INSERT INTO Customers (CustomerID, CustomerName) VALUES (30,'CANNON TOOLS'),(90,'INTERNATIONAL BANK'),(130,'SUN DIAL CITRUS')
-- Change DB recovery model to Full and take full backup
ALTER DATABASE [DevTestAG] SET RECOVERY FULL ;
GO
BACKUP DATABASE [DevTestAG] TO  DISK = N'/var/opt/mssql/backup/DevTestAG.bak' WITH NOFORMAT, NOINIT,  NAME = N'DevTestAG-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
USE [master]
GO
--create logins for AG
CREATE LOGIN ag_login WITH PASSWORD = 'AGPa55w0rd';
CREATE USER ag_user FOR LOGIN ag_login;
-- Create a master key and certificate
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AGPa55w0rd';
GO
CREATE CERTIFICATE ag_certificate WITH SUBJECT = 'ag_certificate';
-- Copy these two files to the same directory on secondary replicas
BACKUP CERTIFICATE ag_certificate
TO FILE = '/var/opt/mssql/data/ag_certificate.cert'
WITH PRIVATE KEY (
        FILE = '/var/opt/mssql/data/ag_certificate.key',
        ENCRYPTION BY PASSWORD = 'AGPa55w0rd'
    );
GO
-- Create AG endpoint on port 5022
CREATE ENDPOINT [AG_endpoint]
STATE=STARTED
AS TCP (
    LISTENER_PORT = 5022,
    LISTENER_IP = ALL
)
FOR DATA_MIRRORING (
    ROLE = ALL,
    AUTHENTICATION = CERTIFICATE ag_certificate,
    ENCRYPTION = REQUIRED ALGORITHM AES
)
--Create AG primary replica
CREATE AVAILABILITY GROUP [K8sAG]
WITH (
    CLUSTER_TYPE = NONE
)
FOR REPLICA ON
N'mssql-primary' WITH
(
    ENDPOINT_URL = N'tcp://mssql-primary:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
),
N'mssql-sec1' WITH
(
    ENDPOINT_URL = N'tcp://mssql-sec1:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
),
N'mssql-sec2' WITH
(
    ENDPOINT_URL = N'tcp://mssql-sec2:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
),
N'mssql-sec3' WITH
(
    ENDPOINT_URL = N'tcp://mssql-sec3:5022',
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
    SEEDING_MODE = AUTOMATIC,
    FAILOVER_MODE = MANUAL,
    SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
);

-- Add database to AG
USE [master]
GO
ALTER AVAILABILITY GROUP [K8sAG] ADD DATABASE [DevTestAG]
GO