PREPARE test_insert (detail TEXT) AS
    INSERT INTO test (details) VALUES($1);

PREPARE test_query (id int) AS
   SELECT * FROM test where id = $1;