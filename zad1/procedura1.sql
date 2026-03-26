-- Procedura wyświetlająca nazwy miast, w których maksymalne wynagrodzenie
-- pracowników w lokalnych departamentach jest niższe niż podany próg (@max_salary).
-- Wykorzystuje kursor do iteracji i wypisywania wyników.

CREATE OR ALTER PROCEDURE print_cities_with_max_salary
    @p_max_salary DECIMAL(10, 2)
AS
BEGIN
    DECLARE @v_current_city VARCHAR(255);

    DECLARE curs CURSOR FOR
        SELECT l.city
        FROM locations l
        JOIN departments d ON d.location_id = l.location_id
        JOIN employees e ON e.department_id = d.department_id
        GROUP BY l.city
        HAVING MAX(e.salary) < @p_max_salary;

    OPEN curs;

    FETCH NEXT FROM curs INTO @v_current_city;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @v_current_city;
        FETCH NEXT FROM curs INTO @v_current_city;
    END;

    CLOSE curs;
    DEALLOCATE curs;
END;


-- Wywołanie procedury z określonym progiem maksymalnego wynagrodzenia
EXEC print_cities_with_max_salary @p_max_salary = 10000;