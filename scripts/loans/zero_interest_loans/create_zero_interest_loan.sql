

------------- create_zero_interest_loan ----------
create or replace function create_zero_interest_loan(v_client_id UUID, v_principal_amount float8, v_expected_pay_date date)
returns void as $$
declare 
	v_loan_id UUID;
begin
	insert into log (origin, message) values ('create_zero_interest_loan', 'start');

	insert into loans(client_id, payment_status, type) values (v_client_id, 'unknown', 'zero_interest_loan')
	returning id into v_loan_id;

	insert into zero_interest_loans (loan_id, initial_principal_amount, principal_amount_paid, expected_pay_date)
	values (v_loan_id, v_principal_amount, 0, v_expected_pay_date);


	-- Calculate values
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	insert into log (origin, message) values ('create_zero_interest_loan', 'end');
	
EXCEPTION
	WHEN OTHERS THEN
    	RAISE EXCEPTION 'create_zero_interest_loan - ERROR: %', SQLERRM;
end;

$$ LANGUAGE plpgsql;
