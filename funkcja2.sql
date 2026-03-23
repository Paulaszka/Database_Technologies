-- Funkcja skalarna T-SQL czyszcząca kod pocztowy dla danej lokalizacji.
-- Wykorzystuje pętlę WHILE do iteracji po ciągu znaków adresu,
-- pozostawiając jedynie znaki alfanumeryczne.

CREATE OR ALTER FUNCTION dbo.get_clean_postal_code (
    @p_location_id NUMERIC(4)
)
RETURNS VARCHAR(12)
AS
BEGIN
    DECLARE @v_raw_postal VARCHAR(12);
    DECLARE @v_clean_postal VARCHAR(12) = '';
    DECLARE @v_pos INT = 1;
    DECLARE @v_char CHAR(1);
    DECLARE @v_length INT;

    -- Pobranie surowego kodu pocztowego dla danej lokalizacji
    SELECT @v_raw_postal = postal_code 
    FROM locations 
    WHERE location_id = @p_location_id;

    -- Jeśli kod jest pusty, zwracamy NULL
    IF @v_raw_postal IS NULL
        RETURN NULL;

    SET @v_length = LEN(@v_raw_postal);

    -- Pętla WHILE iterująca po każdym znaku kodu pocztowego
    WHILE @v_pos <= @v_length
    BEGIN
        -- Pobranie znaku na bieżącej pozycji
        SET @v_char = SUBSTRING(@v_raw_postal, @v_pos, 1);

        -- Logika biznesowa: Sprawdzenie, czy znak jest alfanumeryczny
        -- Pozwala na usunięcie spacji, myślników i innych separatorów geograficznych
        IF @v_char LIKE '[a-zA-Z0-9]'
        BEGIN
            SET @v_clean_postal = @v_clean_postal + @v_char;
        END

        -- Inkrementacja licznika pętli
        SET @v_pos = @v_pos + 1;
    END

    RETURN @v_clean_postal;
END;


-- Przykład wywołania:
SELECT location_id, city, postal_code, dbo.get_clean_postal_code(location_id) AS clean_postal
FROM locations;
