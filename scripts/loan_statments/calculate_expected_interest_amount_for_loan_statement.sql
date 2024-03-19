create or replace function calculate_expected_interest_amount_for_loan_statement(v_loan_statement_id uuid)
returns void as $$
declare
	v_loan_id uuid;
	v_interest_rate float8;
	v_remaining_principal_amount float8;
	v_expected_interest_amount float8;
begin
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'start');
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'v_loan_statement_id: ' || v_loan_statement_id);

	-- Get loan_id from loan_statement
	select loan_id into v_loan_id from loan_statements where id = v_loan_statement_id;

	-- Get interest rate from loan
	select (initial_principal_amount - principal_amount_paid), interest_rate
	into v_remaining_principal_amount, v_interest_rate
	from open_ended_loans oel 
	where loan_id = v_loan_id;

	-- Set expected interest amount
	v_expected_interest_amount := v_remaining_principal_amount * (v_interest_rate / 100);

	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'v_remaining_principal_amount: ' || v_remaining_principal_amount);
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'v_interest_rate: ' || v_interest_rate);
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'v_expected_interest_amount: ' || v_expected_interest_amount);

	-- Update loan_statement
	update loan_statements
	set expected_interest_amount = v_expected_interest_amount
	where id = v_loan_statement_id;

	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan_statement', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('calculate_expected_interest_amount_for_loan_statement', SQLERRM);
    	RAISE EXCEPTION 'calculate_expected_interest_amount_for_loan_statement - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
