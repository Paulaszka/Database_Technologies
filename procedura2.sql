-- Procedura dodająca nowy departament do tabeli departments.
-- Automatycznie wyznacza nowy identyfikator (department_id) jako obecne maksimum + 10.
-- Obsługuje parametry opcjonalne dla menadżera i lokalizacji (domyślnie 2000).

CREATE OR ALTER PROCEDURE add_new_department(
    @p_department_name NVARCHAR(100),
    @p_manager_id INT = NULL,
    @p_location_id INT = 2000
) AS
BEGIN
    INSERT INTO departments (department_id, department_name, manager_id, location_id)
	VALUES ((SELECT COALESCE(MAX(department_id), 0) + 10 FROM departments),
	        @p_department_name, @p_manager_id, @p_location_id)
END;

-- Przypadki testowe 

-- Wywołanie tylko z wymaganą nazwą (reszta domyślna)
EXEC add_new_department @p_department_name = 'Machine Learning Operations';

-- Wywołanie z przypisaniem konkretnego menadżera
EXEC add_new_department @p_department_name = 'Cybersecurity Response', @p_manager_id = 105;

-- Wywołanie z niestandardową lokalizacją (np. dla nowego biura)
EXEC add_new_department @p_department_name = 'Global Logistics', @p_location_id = 2500;

-- Wywołanie pozycyjne (bez nazw parametrów - ważne, by zachować kolejność!)
EXEC add_new_department @p_department_name = 'User Experience Design', @p_manager_id =  110, @p_location_id = 3000;
