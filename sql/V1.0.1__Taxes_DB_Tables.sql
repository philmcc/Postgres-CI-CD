
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


