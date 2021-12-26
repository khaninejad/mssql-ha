--Add_Secondary
USE [master]
GO
--Create login for AG
-- It should match the password from the primary script
CREATE LOGIN ag_login WITH PASSWORD = 'AGPa55w0rd';
CREATE USER ag_user FOR LOGIN ag_login;

-- Create the certificate using the certificate file created in the primary node
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AGPa55w0rd';
GO
-- Create from copied cert - the password must match the primary 
CREATE CERTIFICATE ag_certificate
    AUTHORIZATION ag_user
    FROM FILE = '/var/opt/mssql/data/ag_certificate.cert'
    WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/ag_certificate.key',
    DECRYPTION BY PASSWORD = 'AGPa55w0rd'
)
GO
--create HADR endpoint
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
GRANT CONNECT ON ENDPOINT::AG_endpoint TO [ag_login];
GO
--add current node to the availability group
ALTER AVAILABILITY GROUP [K8sAG] JOIN WITH (CLUSTER_TYPE = NONE)
ALTER AVAILABILITY GROUP [K8sAG] GRANT CREATE ANY DATABASE
GO