
BEGIN;


CREATE TABLE IF NOT EXISTS public.Individual
(
    ID serial NOT NULL,
    Document_Number text NOT NULL UNIQUE,
    Full_Name text,
    Date_of_Birth date,
    Address text,
    Email text,
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.Company
(
    ID serial NOT NULL,
    CUIT integer NOT NULL UNIQUE,
    Date_of_Commencement date,
    Website text,
    Email text,
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.Number_Type
(
    ID serial NOT NULL,
    Description text UNIQUE,
    PRIMARY KEY (ID)
);

CREATE TABLE IF NOT EXISTS public.Contact_Number
(
    ID serial NOT NULL,
    Individual_ID integer,
    Company_Id integer,
    Number_Type integer,
    Contact_Number TEXT,
    PRIMARY KEY (ID)
);

ALTER TABLE IF EXISTS public.Contact_Number
    ADD CONSTRAINT Number_Type FOREIGN KEY (Number_Type)
    REFERENCES public.Number_Type (ID)
    ;


ALTER TABLE IF EXISTS public.Contact_Number
    ADD CONSTRAINT Individual FOREIGN KEY (Individual_ID)
    REFERENCES public.Individual (ID)
    ;


ALTER TABLE IF EXISTS public.Contact_Number
    ADD CONSTRAINT Company FOREIGN KEY (Company_Id)
    REFERENCES public.Company (ID)
    ;

CREATE TABLE IF NOT EXISTS public.Company_Owners
(
    Id serial NOT NULL,
    Company_Id integer,
    Individual_Id integer,
    Start_Date date NOT NULL,
    End_Date date,
    PRIMARY KEY (Id)
);

ALTER TABLE IF EXISTS public.Company_Owners
ADD CONSTRAINT Individual_Id FOREIGN KEY (Individual_Id)
    REFERENCES public.Individual (ID)
    ;


ALTER TABLE IF EXISTS public.Company_Owners
    ADD CONSTRAINT Company_Id FOREIGN KEY (Company_Id)
    REFERENCES public.Company (ID)
    ;


CREATE TABLE IF NOT EXISTS public.Collection_Agency
(
    ID serial NOT NULL,
    Name text,
    Number text,
    Address text,
    Person_in_Charge integer,
    Number_of_Employees integer,
    PRIMARY KEY (ID)
);

ALTER TABLE IF EXISTS public.Collection_Agency
    ADD CONSTRAINT Person_in_Charge FOREIGN KEY (Person_in_Charge)
    REFERENCES public.Individual (ID)
    ;


CREATE TABLE IF NOT EXISTS public.Tax_Type
(
    ID serial NOT NULL,
    Name text NOT NULL,
    PRIMARY KEY (ID)
);


CREATE TABLE IF NOT EXISTS public.Tax_Payer_Id
(
    ID serial NOT NULL,
    Individual_ID integer,
    Company_ID integer,
    PRIMARY KEY (ID)
);


ALTER TABLE IF EXISTS public.Tax_Payer_Id
    ADD CONSTRAINT Individuals FOREIGN KEY (Individual_ID)
    REFERENCES public.Individual (ID)
    ;


ALTER TABLE IF EXISTS public.Tax_Payer_Id
    ADD CONSTRAINT Company FOREIGN KEY (Company_ID)
    REFERENCES public.Company (ID)
    ;

CREATE TABLE IF NOT EXISTS public.Payment
(
    ID serial NOT NULL,
    Collection_Agengy integer NOT NULL,
    Taxpayer integer NOT NULL,
    Amount real NOT NULL,
    Payment_Date date NOT NULL,
    Tax_Type integer,
    PRIMARY KEY (ID),
    CONSTRAINT No_Duplicate_Payments UNIQUE (Collection_Agengy, Taxpayer, Payment_Date)
);

ALTER TABLE IF EXISTS public.Payment
    ADD CONSTRAINT Tax_Type FOREIGN KEY (Tax_Type)
    REFERENCES public.Tax_Type (ID)
    ;


ALTER TABLE IF EXISTS public.Payment
    ADD CONSTRAINT Tax_Payer FOREIGN KEY (Taxpayer)
    REFERENCES public.Tax_Payer_Id (ID)
    ;
    
END;


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

