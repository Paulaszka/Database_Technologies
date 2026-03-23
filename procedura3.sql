CREATE PROCEDURE proc3
    @year INT,
    @increment DECIMAL(4, 2),
    @modified_count INT OUTPUT
AS
BEGIN
    SET @modified_count = 0;

    UPDATE employees
    SET commission_pct =
        COALESCE(commission_pct, 0.00) + @increment
    WHERE YEAR(hire_date) < @year

    SET @modified_count = @@ROWCOUNT;
END;
GO


DECLARE @modified_count INT;

EXEC proc3 @year = 2004, @increment = 0.05, @modified_count = @modified_count OUTPUT;

PRINT 'Liczba zmodyfikowanych rekordów: ' + CAST(@modified_count AS VARCHAR);