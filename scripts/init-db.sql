-- ================================
-- DATABASE INITIALIZATION SCRIPT
-- ================================
-- Bu script container başladığında çalışır

USE master;
GO

-- Database oluştur (varsa pas geç)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DevApiDb')
BEGIN
    CREATE DATABASE DevApiDb;
    PRINT 'DevApiDb database created successfully';
END
ELSE
BEGIN
    PRINT 'DevApiDb database already exists';
END
GO

USE DevApiDb;
GO

-- Users tablosu oluştur
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id int IDENTITY(1,1) PRIMARY KEY,
        Username nvarchar(450) NOT NULL UNIQUE,
        Password nvarchar(450) NOT NULL,
        CreatedDate datetime2 DEFAULT GETUTCDATE(),
        LastLoginDate datetime2 NULL
    );
    
    PRINT 'Users table created successfully';
    
    -- Varsayılan kullanıcı ekle
    INSERT INTO Users (Username, Password) VALUES 
    ('admin', '123456'),
    ('demo', 'demo123'),
    ('test', 'test123');
    
    PRINT 'Default users inserted successfully';
END
ELSE
BEGIN
    PRINT 'Users table already exists';
END
GO

-- ================================
-- PERFORMANCE INDEXES
-- ================================
-- Username üzerinde index (login performance için)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_Username')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Users_Username 
    ON Users (Username);
    PRINT 'Username index created successfully';
END
GO

-- ================================
-- SECURITY & PERMISSIONS
-- ================================
-- Application user oluştur (production için)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'appuser')
BEGIN
    CREATE LOGIN appuser WITH PASSWORD = 'AppUser@123';
    CREATE USER appuser FOR LOGIN appuser;
    
    -- Sadece gerekli izinleri ver
    GRANT SELECT, INSERT, UPDATE, DELETE ON Users TO appuser;
    
    PRINT 'Application user created with limited permissions';
END
GO

PRINT 'Database initialization completed successfully';
GO 