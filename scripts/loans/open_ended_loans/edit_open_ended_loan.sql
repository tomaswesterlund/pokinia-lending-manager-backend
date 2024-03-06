------------- edit_open_ended_loan ----------
create or replace function edit_open_ended_loan(v_loan_id uuid, v_interest_rate float8, v_statuses text[])
returns void as $$
declare
	r record;
	v_client_id uuid;
	v_initial_principal_amount float8;
begin
	insert into log (origin, message) values ('edit_open_ended_loan', 'start');

	-- Delcare variables
	select client_id
	into v_client_id
	from loans
	where id = v_loan_id;

	select initial_principal_amount
	into v_initial_principal_amount
	from open_ended_loans
	where id = v_loan_id;

	-- Update interest rate in loan
	update loans 
	set interest_rate = v_interest_rate
	where id = v_loan_id;


	-- Update interest amount in loan statements
	update loan_statements 
	set expected_interest_amount = (v_initial_principal_amount * (v_interest_rate / 100)) 
	where loan_id = v_loan_id
	and payment_status = any(v_statuses);

	-- Calculate values
	FOR r IN SELECT id FROM loan_statements WHERE loan_id = 'x'
    LOOP
       perform calculate_loan_statement_values(rowr.id);
    END LOOP;
   
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	insert into log (origin, message) values ('edit_open_ended_loan', 'end');	

EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'edit_open_ended_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;