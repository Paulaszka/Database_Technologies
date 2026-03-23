CREATE OR ALTER TRIGGER check_commission
ON employees
INSTEAD OF UPDATE
AS
BEGIN
    DECLARE @prev_commission NUMERIC(2, 2), @new_commission NUMERIC(2, 2), @is_manager BIT;

    SELECT @prev_commission = commission_pct FROM deleted;
    SELECT @new_commission = commission_pct FROM inserted;


    SELECT @is_manager = CASE WHEN EXISTS (
        SELECT 1 FROM employees WHERE manager_id = (SELECT employee_id FROM inserted)
    ) THEN 1 ELSE 0 END;


    IF @is_manager = 0
    BEGIN
        UPDATE employees
        SET commission_pct = @new_commission
        WHERE employee_id IN (SELECT employee_id FROM inserted);
        RETURN;
    END


    IF @prev_commission IS NULL
    BEGIN
        IF @new_commission > 0.1
            SET @new_commission = 0.1;
    END
    ELSE
    BEGIN

        IF @new_commission >= 2 * @prev_commission
        BEGIN
            SET @new_commission = 2 * @prev_commission;
        END
    END

    UPDATE employees
    SET commission_pct = @new_commission
    WHERE employee_id IN (SELECT employee_id FROM inserted);
END;



--Wyświetlenie managera
SELECT * FROM employees
WHERE employee_id = 201;

--Wyświetlenie pracownika
SELECT * FROM employees
WHERE employee_id = 202;

--Ustawienie wartości na null dla managera - wynik: null
UPDATE employees
SET commission_pct = null
WHERE employee_id = 201;

--Ustawienie wartości na 0.25 dla managera - wynik: 0.1
UPDATE employees
SET commission_pct = 0.25
WHERE employee_id = 201;

--Ustawienie wartości na 0.5 dla managera - wynik: 0.2
UPDATE employees
SET commission_pct = 0.5
WHERE employee_id = 201;

--Ustawienie wartości na null dla pracownika - wynik: null
UPDATE employees
SET commission_pct = null
WHERE employee_id = 202;

--Ustawienie wartości na 0.5 dla pracownika - wynik: 0.5
UPDATE employees
SET commission_pct = 0.5
WHERE employee_id = 202;