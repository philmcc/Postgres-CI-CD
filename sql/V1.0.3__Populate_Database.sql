-- Generating test Data for the database.

SET datestyle = "ISO, DMY";
-- Populate Individual table
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('214365D', 'Joe Blogs', DATE '03/11/1980', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('45986231', 'Jim Smith', DATE '16/05/1982', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('FG4557H', 'All User', DATE '07/11/1976', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('3WGH5667', 'Bob Blogs', DATE '29/11/1989', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('AL1435DT', 'User One', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('ABCDE134', 'User two', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('123ABC', 'User Three', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('09876ghk', 'User Four', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('5436VDT44', 'User Five', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');
INSERT INTO public.Individual(Document_Number, Full_Name, Date_of_Birth, Address, Email) VALUES ('sdfgh4567', 'User Six', DATE '30/12/1967', '1 Some Street, Some Town, SW1 8FG', 'email@email.com');

-- Populate Tax_Payer_Id with new Individuals ignoring previously created Individuals
INSERT INTO Tax_Payer_Id (Individual_ID) SELECT DISTINCT ID FROM Individual WHERE ID NOT IN (SELECT Individual_ID FROM Tax_Payer_Id WHERE Individual_ID is not null) ;

-- Populate the Number_Type table
INSERT INTO Number_Type (Description) VALUES('landline');
INSERT INTO Number_Type (Description) VALUES('fax');
INSERT INTO Number_Type (Description) VALUES('mobile');

-- Populate the Contact_Number Table
INSERT INTO Contact_Number(Individual_ID, Number_Type, Contact_Number) VALUES ((SELECT ID from Individual where Document_Number like '214365D'), (SELECT ID FROM Number_Type WHERE Description like 'landline'), '01675 3214587');
INSERT INTO Contact_Number(Individual_ID, Number_Type, Contact_Number) VALUES ((SELECT ID from Individual where Document_Number like '45986231'), (SELECT ID FROM Number_Type WHERE Description like 'fax'), '01675 3214587');
INSERT INTO Contact_Number(Individual_ID, Number_Type, Contact_Number) VALUES ((SELECT ID from Individual where Document_Number like '45986231'), (SELECT ID FROM Number_Type WHERE Description like 'mobile'), '01675 3214587');
INSERT INTO Contact_Number(Individual_ID, Number_Type, Contact_Number) VALUES ((SELECT ID from Individual where Document_Number like '3WGH5667'), (SELECT ID FROM Number_Type WHERE Description like 'landline'), '01675 3214587');

-- Populate the Tax_Type table
INSERT INTO Tax_Type (Name) VALUES ('stamp duty');
INSERT INTO Tax_Type (Name) VALUES ('real estate');
INSERT INTO Tax_Type (Name) VALUES ('automotive patent');
INSERT INTO Tax_Type (Name) VALUES ('gross income');

-- Populate the Collection_Agency table
INSERT INTO Collection_Agency ( Name, Number, Person_in_Charge, Number_of_Employees) VALUES ('Agency1', 'AGENCY001', (SELECT ID from Individual where Document_Number like '214365D'), 50);
INSERT INTO Collection_Agency ( Name, Number, Person_in_Charge, Number_of_Employees) VALUES ('Agency2', 'AGENCY002', (SELECT ID from Individual where Document_Number like 'FG4557H'), 10);
INSERT INTO Collection_Agency ( Name, Number, Person_in_Charge, Number_of_Employees) VALUES ('Agency3', 'AGENCY003', (SELECT ID from Individual where Document_Number like '3WGH5667'), 21);


-- Populate companies as well as the company Owner relation table

SELECT CreateCompanyandOwner(104, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(105, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(106, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(107, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(108, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(109, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(110, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(111, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );
SELECT CreateCompanyandOwner(112, (Select random_date_in_range('01-01-2018', '13-12-2021')), '','',(SELECT Document_Number from Individual ORDER BY RANDOM() LIMIT 1) );


-- Add some more Owners
INSERT INTO Company_Owners (Company_Id,Individual_Id, Start_Date ) VALUES (9, 2, (Select random_date_in_range('01-01-2018', '13-12-2021')));
INSERT INTO Company_Owners (Company_Id,Individual_Id, Start_Date ) VALUES (9, 4, (Select random_date_in_range('01-01-2018', '13-12-2021')));
INSERT INTO Company_Owners (Company_Id,Individual_Id, Start_Date ) VALUES (9, 6, (Select random_date_in_range('01-01-2018', '13-12-2021')));
INSERT INTO Company_Owners (Company_Id,Individual_Id, Start_Date ) VALUES (3, 2, (Select random_date_in_range('01-01-2018', '13-12-2021')));
INSERT INTO Company_Owners (Company_Id,Individual_Id, Start_Date ) VALUES (2, 1, (Select random_date_in_range('01-01-2018', '13-12-2021')));


-- Populate Tax_Payer_Id with new IOndivCompaniesiduals ignoring previously created Companies
INSERT INTO Tax_Payer_Id (Company_ID) SELECT DISTINCT ID FROM Company WHERE ID NOT IN (SELECT Company_ID FROM Tax_Payer_Id WHERE Company_ID is not null) ;
 



-- Generate random payment data 

do $$
begin
   for cnt in 1..1000 loop
    INSERT INTO Payment (Collection_Agengy, Taxpayer, Amount, Payment_Date, Tax_Type) VALUES(
        (SELECT ID from Collection_Agency ORDER BY RANDOM() LIMIT 1),
        (SELECT ID from Tax_Payer_Id ORDER BY RANDOM() LIMIT 1),
        (SELECT random_NUMERIC_in_range(100,100000)),
        (Select random_date_in_range('01-01-2018', '13-12-2021')),    
        (SELECT ID from Tax_Type ORDER BY RANDOM() LIMIT 1)
    ) ON CONFLICT DO NOTHING;
   end loop;
end; $$