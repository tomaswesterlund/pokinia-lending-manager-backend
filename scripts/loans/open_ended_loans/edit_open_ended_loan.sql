create or replace function edit_open_ended_loan(v_loan_id uuid, v_interest_rate float8, v_payment_statuses text[])
returns void as $$
declare
	r record;
	v_client_id uuid;
	v_initial_principal_amount float8;
begin
	perform create_debug_log_entry('edit_open_ended_loan', 'start');
	perform create_debug_log_entry('edit_open_ended_loan', 'v_loan_id: ' || v_loan_id);
	perform create_debug_log_entry('edit_open_ended_loan', 'v_interest_rate: ' || v_interest_rate);
	perform create_debug_log_entry('edit_open_ended_loan', 'v_payment_statuses: ' || array_to_string(v_payment_statuses, ', '));

	-- Delcare variables
	select client_id
	into v_client_id
	from loans
	where id = v_loan_id;

	select initial_principal_amount
	into v_initial_principal_amount
	from open_ended_loans
	where loan_id = v_loan_id;

	perform create_debug_log_entry('edit_open_ended_loan', 'v_client_id:' || v_client_id);
	perform create_debug_log_entry('edit_open_ended_loan', 'v_initial_principal_amount:' || v_initial_principal_amount);

	-- Update interest rate in loan
	update open_ended_loans  
	set interest_rate = v_interest_rate
	where loan_id = v_loan_id;

	-- Update interest amount in loan statements
	update loan_statements 
	set interest_rate = v_interest_rate, expected_interest_amount = (v_initial_principal_amount * (v_interest_rate / 100)) 
	where loan_id = v_loan_id
	and payment_status = any(v_payment_statuses);

	-- Calculate values
	FOR r IN SELECT id FROM loan_statements WHERE loan_id = v_loan_id
    LOOP
       perform calculate_loan_statement_values(r.id);
    END LOOP;
   
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	perform create_debug_log_entry('edit_open_ended_loan', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('edit_open_ended_loan', SQLERRM);
    	RAISE EXCEPTION 'edit_open_ended_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;





