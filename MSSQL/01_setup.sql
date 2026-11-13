-- Выполнить целиком в SSMS. Совместимо с SQL Server 2014 и выше.
-- Создает учебные таблицы и исходные данные. Существующие таблицы не изменяет.
USE [master];
GO

IF DB_ID(N'PharmDB') IS NULL
BEGIN
    CREATE DATABASE [PharmDB] COLLATE Cyrillic_General_CI_AS;
END;
GO

USE [PharmDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.cities') IS NOT NULL
    OR OBJECT_ID(N'dbo.drugstores') IS NOT NULL
    OR OBJECT_ID(N'dbo.cashdesk') IS NOT NULL
BEGIN
    THROW 50001, N'Учебные таблицы уже существуют. Для запросов откройте 02_queries.sql. Для повторного создания используйте другую пустую учебную базу.', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Сначала родительская таблица, затем две зависимые.
    -- VARCHAR(128) соответствует диаграмме; Cyrillic_General_CI_AS сохраняет кириллицу.
    CREATE TABLE dbo.cities
    (
        [id] INT IDENTITY(1, 1) NOT NULL,
        [name] VARCHAR(128) COLLATE Cyrillic_General_CI_AS NOT NULL,
        CONSTRAINT PK_cities PRIMARY KEY ([id])
    );

    CREATE TABLE dbo.drugstores
    (
        [id] INT IDENTITY(1, 1) NOT NULL,
        [name] VARCHAR(128) COLLATE Cyrillic_General_CI_AS NOT NULL,
        [address] VARCHAR(128) COLLATE Cyrillic_General_CI_AS NULL,
        [city_id] INT NOT NULL,
        CONSTRAINT PK_drugstores PRIMARY KEY ([id]),
        CONSTRAINT FK_drugstores_cities FOREIGN KEY ([city_id])
            REFERENCES dbo.cities ([id])
    );

    CREATE TABLE dbo.cashdesk
    (
        [id] INT IDENTITY(1, 1) NOT NULL,
        [number] INT NOT NULL,
        [description] VARCHAR(128) COLLATE Cyrillic_General_CI_AS NULL,
        [drugstore_id] INT NOT NULL,
        CONSTRAINT PK_cashdesk PRIMARY KEY ([id]),
        CONSTRAINT FK_cashdesk_drugstores FOREIGN KEY ([drugstore_id])
            REFERENCES dbo.drugstores ([id])
    );

    INSERT INTO dbo.cities ([name])
    VALUES (N'Хабаровск'), (N'Владивосток'), (N'Благовещенск');

    -- Получаем city_id по названию: не предполагаем конкретные значения IDENTITY.
    INSERT INTO dbo.drugstores ([name], [address], [city_id])
    SELECT source.[name], source.[address], c.[id]
    FROM
    (
        VALUES
            (N'Аптека №1', N'ул. Карла Маркса, 1', N'Хабаровск'),
            (N'Аптека №2', N'ул. Ленина, 2', N'Хабаровск'),
            (N'Аптека №3', N'пр. Победы, 3', N'Хабаровск'),
            (N'Аптека №4', N'ул. Карла Маркса, 15', N'Хабаровск'),
            (N'Аптека №5', N'ул. Комсомольская, 5', N'Владивосток'),
            (N'Аптека №6', N'ул. Большая, 6', N'Владивосток'),
            (N'Аптека №7', N'ул. Ленина, 22', N'Благовещенск')
    ) AS source ([name], [address], [city_name])
    INNER JOIN dbo.cities AS c ON c.[name] = source.[city_name];

    INSERT INTO dbo.cashdesk ([number], [description], [drugstore_id])
    SELECT source.[number], source.[description], d.[id]
    FROM
    (
        VALUES
            (1, N'касса 1', N'Аптека №1'),
            (2, N'касса 2', N'Аптека №1'),
            (3, N'рецептура 1', N'Аптека №1'),
            (1, N'касса 1', N'Аптека №2'),
            (2, N'касса 2', N'Аптека №2'),
            (3, N'касса 3', N'Аптека №2'),
            (1, N'рецептура 1', N'Аптека №3'),
            (1, N'касса 1', N'Аптека №4'),
            (2, N'касса 2', N'Аптека №4'),
            (1, N'касса 1', N'Аптека №5'),
            (2, N'касса 2', N'Аптека №5'),
            (3, N'рецептура 1', N'Аптека №5'),
            (4, N'рецептура 2', N'Аптека №5'),
            (5, N'рецептура 3', N'Аптека №5'),
            (1, N'касса 1', N'Аптека №6'),
            (1, N'касса 1', N'Аптека №7'),
            (2, N'касса 2', N'Аптека №7'),
            (2, N'касса 1', N'Аптека №7'),
            (3, N'касса 2', N'Аптека №7'),
            (4, N'касса 1', N'Аптека №7'),
            (5, N'касса 2', N'Аптека №7')
    ) AS source ([number], [description], [drugstore_name])
    INNER JOIN dbo.drugstores AS d ON d.[name] = source.[drugstore_name];

    COMMIT TRANSACTION;
    PRINT N'PharmDB готова: 3 города, 7 аптек, 21 касса. Выполните 02_queries.sql.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
