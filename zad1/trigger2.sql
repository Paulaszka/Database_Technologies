-- Wyzwalacz AFTER DELETE na tabeli locations.
-- Wykorzystuje kursor, aby pobrać i wypisać informację o usuniętych miastach oraz przypisanych do nich krajach.

CREATE OR ALTER TRIGGER delete_trigger ON locations
AFTER DELETE
AS
BEGIN
	DECLARE @v_city NVARCHAR(255);
	DECLARE @v_country_name NVARCHAR(100);

	DECLARE location_cursor CURSOR FOR
	SELECT c.country_name, d.city
	FROM DELETED d
	JOIN countries c on c.country_id = d.country_id;

	OPEN location_cursor;

	FETCH NEXT FROM location_cursor INTO @v_country_name, @v_city;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Deleted city: ' + @v_city + ' in country: ' + @v_country_name;
		FETCH NEXT FROM location_cursor INTO @v_country_name, @v_city;
	END;

CLOSE location_cursor;
DEALLOCATE location_cursor;
END;


--Przypadki testowe

DELETE
FROM locations
WHERE locations.location_id NOT IN (
					SELECT d.location_id FROM departments d
					WHERE d.location_id IS NOT NULL
					);