USE [PharmDB];
GO

-- Фиксируем поведение конкатенации с NULL и для SQL Server 2014.
SET CONCAT_NULL_YIELDS_NULL ON;

-- 1. Все кассы: присоединяем к каждой кассе аптеку и ее город.
SELECT
    d.[name] AS [Аптека],
    c.[name] + ISNULL(N', ' + d.[address], N'') AS [Адрес аптеки с городом],
    k.[number] AS [Номер кассы],
    k.[description] AS [Описание кассы]
FROM dbo.cashdesk AS k
INNER JOIN dbo.drugstores AS d ON d.[id] = k.[drugstore_id]
INNER JOIN dbo.cities AS c ON c.[id] = d.[city_id]
ORDER BY d.[name], k.[number], k.[description], k.[id];

-- 2. Аптеки, в которых строго больше трех касс.
SELECT
    d.[name] AS [Аптека],
    c.[name] AS [Город],
    d.[address] AS [Адрес аптеки]
FROM dbo.drugstores AS d
INNER JOIN dbo.cities AS c ON c.[id] = d.[city_id]
INNER JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
GROUP BY d.[id], d.[name], c.[name], d.[address]
HAVING COUNT(k.[id]) > 3
ORDER BY d.[name], d.[id];

-- 3. Аптеки на улице Карла Маркса и количество всех их касс.
-- LEFT JOIN сохраняет даже аптеку без касс; COUNT(k.id) тогда вернет 0.
SELECT
    d.[name] AS [Аптека],
    c.[name] AS [Город],
    d.[address] AS [Адрес аптеки],
    COUNT(k.[id]) AS [Кол-во касс]
FROM dbo.drugstores AS d
INNER JOIN dbo.cities AS c ON c.[id] = d.[city_id]
LEFT JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
WHERE d.[address] LIKE N'%Карла Маркса%'
GROUP BY d.[id], d.[name], c.[name], d.[address]
ORDER BY d.[name], d.[id];

-- 4. Аптеки с рецептурой и количество именно таких касс.
-- В исходных данных описания: "рецептура 1", "рецептура 2", "рецептура 3".
SELECT
    d.[name] AS [Аптека],
    c.[name] AS [Город],
    d.[address] AS [Адрес аптеки],
    COUNT(k.[id]) AS [Кол-во касс с рецептурой]
FROM dbo.drugstores AS d
INNER JOIN dbo.cities AS c ON c.[id] = d.[city_id]
INNER JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
WHERE k.[description] LIKE N'%рецептура%'
GROUP BY d.[id], d.[name], c.[name], d.[address]
ORDER BY d.[name], d.[id];

-- 5. Города, в которых суммарно строго больше восьми касс.
SELECT
    c.[name] AS [Город]
FROM dbo.cities AS c
INNER JOIN dbo.drugstores AS d ON d.[city_id] = c.[id]
INNER JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
GROUP BY c.[id], c.[name]
HAVING COUNT(k.[id]) > 8
ORDER BY c.[name], c.[id];
