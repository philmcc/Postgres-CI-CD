PREPARE test_insert (TEXT) AS
    INSERT INTO test (details) VALUES($1);

PREPARE test_query (int) AS
   SELECT * FROM test where id = $1;