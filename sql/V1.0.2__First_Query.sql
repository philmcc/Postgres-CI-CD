PREPARE test_insert (TEXT) AS
    INSERT INTO test1 (details) VALUES($1);

PREPARE test_query (int) AS
   SELECT * FROM test1 where id = $1;