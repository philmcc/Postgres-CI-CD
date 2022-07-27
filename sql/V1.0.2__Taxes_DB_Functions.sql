

------
-- Functions required to generate test data
------

CREATE FUNCTION random_date_in_range(DATE, DATE)
RETURNS DATE
LANGUAGE SQL
AS $$
    SELECT $1 + floor( ($2 - $1 + 1) * random() )::INTEGER;
$$;

CREATE OR REPLACE FUNCTION random_NUMERIC_in_range(
  DOUBLE PRECISION,
  DOUBLE PRECISION
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT ROUND(CAST(greatest($1, least($2, $1 + ($2 - $1) * random()))  AS NUMERIC), 2);
$$;

------
-- Triggers and functions to ensure that a company always has at least one owner
------

CREATE OR REPLACE FUNCTION check_if_company_has_owners ( IN p_ID Integer ) RETURNS bool AS $$
SELECT
case when exists( SELECT * FROM Company WHERE ID = p_ID for KEY share )
    THEN exists( SELECT * FROM Company_Owners WHERE Company_Id = p_ID  for KEY share )
ELSE true
END;
$$ language sql;


CREATE OR REPLACE FUNCTION company_has_owner_trg() RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
    IF NOT check_if_company_has_owners( NEW.ID ) THEN
        raise exception 'Company % has no owners!', NEW.CUIT;
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

 
CREATE CONSTRAINT TRIGGER trg_company_has_owners AFTER INSERT OR UPDATE ON company
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE company_has_owner_trg();


CREATE OR REPLACE FUNCTION owners_left_for_company() RETURNS TRIGGER AS
$BODY$
DECLARE
BEGIN
    IF NOT check_if_company_has_owners( OLD.Company_ID ) THEN
        raise exception 'Company % has no owners!', OLD.ID;
    END IF;
    RETURN OLD;
END;
$BODY$
LANGUAGE 'plpgsql';


CREATE CONSTRAINT TRIGGER trg_owners_left_for_company AFTER UPDATE OR DELETE ON Company_Owners
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE owners_left_for_company();

------
-- Function to actually create a company along with its first owner
------

CREATE OR REPLACE FUNCTION CreateCompanyandOwner(p_CUIT integer, 
                                                  p_Date_of_Commencement date,
                                                  p_Website text,
                                                  p_Email text,
                                                  p_Owner_Document_Number TEXT) RETURNS VOID AS
$$
BEGIN
    Insert into Company (CUIT, Date_of_Commencement) VALUES (p_CUIT,  p_Date_of_Commencement);
    
    INSERT INTO Company_Owners (Company_Id, Individual_Id, Start_Date) VALUES ((SELECT ID from Company WHERE CUIT = p_CUIT) , (select ID from Individual where Document_Number like p_Owner_Document_Number), p_Date_of_Commencement);
END
$$
  LANGUAGE 'plpgsql';


--------
-- Functions to help with answerting the questions
--------

CREATE OR REPLACE FUNCTION Monthly_payments_from(p_payer text, p_Company bool)
  RETURNS TABLE (Payment_month text   -- also visible as OUT param in function body
               , Taxpayer   int
               , Amount numeric)
  LANGUAGE plpgsql AS
$$
BEGIN
   IF p_Company THEN                                                                                                           
   RETURN QUERY select to_char(p.payment_date, 'YYYY-MM') as short_payment_date, p.taxpayer, round(cast(sum(p.amount)  as numeric),2)
                    from payment p
                    WHERE p.TAXPAYER = ( SELECT t.id from tax_payer_id t, company c where c.CUIT = cast(p_payer as int) and t.individual_id = c.id  )
                    GROUP BY short_payment_date, p.taxpayer 
                    ORDER BY short_payment_date DESC, p.taxpayer;                   
    ELSE   
    RETURN QUERY select to_char(p.payment_date, 'YYYY-MM') as short_payment_date, p.taxpayer, round(cast(sum(p.amount)  as numeric),2)
                    from payment p
                    WHERE p.TAXPAYER = ( SELECT t.id from tax_payer_id t, individual i where i.Document_Number = p_payer and t.individual_id = i.id  )
                    GROUP BY short_payment_date, p.taxpayer 
                    ORDER BY short_payment_date DESC, p.taxpayer;      
    END IF;                                                                                                            
END;
$$
;         


----
CREATE FUNCTION Company_CUIT_from_taxpayer_id(p_taxpayer int)
RETURNS TEXT
LANGUAGE SQL
AS $$
    select CUIT from company, tax_payer_id
    where company.id = tax_payer_id.company_id
    and tax_payer_id.id = p_taxpayer      
$$;

