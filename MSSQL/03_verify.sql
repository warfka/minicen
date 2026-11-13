-- Проверка после выполнения 01_setup.sql. Данные не меняет.
USE [PharmDB];
GO

SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM dbo.cities) <> 3
    OR (SELECT COUNT(*) FROM dbo.drugstores) <> 7
    OR (SELECT COUNT(*) FROM dbo.cashdesk) <> 21
BEGIN
    THROW 50002, N'Неверное количество городов, аптек или касс.', 1;
END;

DECLARE @Expected TABLE ([name] VARCHAR(128) COLLATE Cyrillic_General_CI_AS, [cashdesk_count] INT);
INSERT INTO @Expected ([name], [cashdesk_count])
VALUES
    (N'Аптека №1', 3), (N'Аптека №2', 3), (N'Аптека №3', 1),
    (N'Аптека №4', 2), (N'Аптека №5', 5), (N'Аптека №6', 1),
    (N'Аптека №7', 6);

DECLARE @Actual TABLE ([name] VARCHAR(128) COLLATE Cyrillic_General_CI_AS, [cashdesk_count] INT);
INSERT INTO @Actual ([name], [cashdesk_count])
SELECT d.[name], COUNT(k.[id])
FROM dbo.drugstores AS d
LEFT JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
GROUP BY d.[id], d.[name];

IF EXISTS
(
    SELECT [name], [cashdesk_count] FROM @Expected
    EXCEPT
    SELECT [name], [cashdesk_count] FROM @Actual
)
OR EXISTS
(
    SELECT [name], [cashdesk_count] FROM @Actual
    EXCEPT
    SELECT [name], [cashdesk_count] FROM @Expected
)
BEGIN
    THROW 50003, N'Количество касс по аптекам отличается от задания.', 1;
END;

-- Повтор номера 2 у аптеки №7 присутствует в исходном документе.
IF
(
    SELECT COUNT(*)
    FROM dbo.cashdesk AS k
    INNER JOIN dbo.drugstores AS d ON d.[id] = k.[drugstore_id]
    WHERE d.[name] = N'Аптека №7' AND k.[number] = 2
) <> 2
BEGIN
    THROW 50004, N'Не сохранен повтор номера кассы из исходных данных.', 1;
END;

SELECT N'Города' AS [Таблица], COUNT(*) AS [Количество] FROM dbo.cities
UNION ALL
SELECT N'Аптеки', COUNT(*) FROM dbo.drugstores
UNION ALL
SELECT N'Кассы', COUNT(*) FROM dbo.cashdesk;

-- Контрольная сводка: Хабаровск — 9, Владивосток — 6, Благовещенск — 6.
SELECT c.[name] AS [Город], COUNT(k.[id]) AS [Всего касс]
FROM dbo.cities AS c
INNER JOIN dbo.drugstores AS d ON d.[city_id] = c.[id]
INNER JOIN dbo.cashdesk AS k ON k.[drugstore_id] = d.[id]
GROUP BY c.[id], c.[name]
ORDER BY c.[name];

PRINT N'Проверка исходных данных пройдена. Сравните пять выборок с RESULTS.md.';
