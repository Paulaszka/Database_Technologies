-- Funkcja zwracająca statystyki
-- departamentów dla podanej lokalizacji (@p_location_id).
-- Zwraca nazwę departamentu, liczbę pracowników oraz procentowy udział 
-- pracowników departamentu w całkowitej liczbie pracowników danej lokalizacji.

CREATE OR ALTER FUNCTION departments_in_location_stats (
    @p_location_id NUMERIC
)
RETURNS TABLE
AS
RETURN (
    WITH employees_in_deperatments AS (

        SELECT 
            d.department_name,
            COUNT(e.employee_id) AS employee_count
        FROM departments d
        LEFT JOIN employees e ON d.department_id = e.department_id
        WHERE d.location_id = @p_location_id
        GROUP BY d.department_name
    ),
    employees_in_location_sum AS (
        SELECT SUM(employee_count) AS total_count
        FROM employees_in_deperatments
    )

    SELECT
        dc.department_name,
        dc.employee_count,
        CAST(
            CASE 
                WHEN eil.total_count = 0 THEN 0
                ELSE (CAST(dc.employee_count AS DECIMAL(18,4)) / eil.total_count) * 100
            END 
        AS DECIMAL(10,2)) AS percentage_of_location
    FROM employees_in_deperatments dc
    CROSS JOIN employees_in_location_sum eil
);


-- Przykład wywołania:
SELECT * FROM departments_in_location_stats (1700) ORDER BY percentage_of_location DESC;
