-- Some test queries for the taxes database which will be used for testing the EverSQL integration.

select to_char(p.payment_date, 'YYYY-MM') as short_payment_date, p.taxpayer, round(cast(sum(p.amount)  as numeric),2)
                    from payment p
                    WHERE p.TAXPAYER = ( SELECT t.id from tax_payer_id t, individual i where i.Document_Number = '45986231' and t.individual_id = i.id  )
                    GROUP BY short_payment_date, p.taxpayer 
                    ORDER BY short_payment_date DESC, p.taxpayer;  


select round(cast(sum(amount)  as numeric),2) as Total_Paid, taxpayer
from payment
GROUP BY taxpayer
HAVING  taxpayer in (select ID 
    FROM Tax_Payer_Id
    WHERE Company_ID in  (select co.company_ID
    FROM Individual i, Company_Owners co
    where i.Document_Number = '3WGH5667'
    and i.ID = co.Individual_id)
);


select (Select full_name from Individual where document_number like '3WGH5667') as Name, '3WGH5667' as Document_Number, round(cast(sum(amount)  as numeric),2) as Total_Paid
from payment
WHERE  taxpayer in (select ID 
    FROM Tax_Payer_Id
    WHERE Company_ID in  (select co.company_ID
    FROM Individual i, Company_Owners co
    where i.Document_Number = '3WGH5667'
    and i.ID = co.Individual_id))
GROUP BY Document_Number;


