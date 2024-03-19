create or replace function calculate_expected_interest_amount_for_loan(v_loan_id uuid)
returns void as $$
declare
	loan_statement_record RECORD;
	v_CEIAFL01 text;
	v_CEIAFL02 text;
begin
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'start');
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'v_loan_id' || v_loan_id);

	-- Check if loan exists
	PERFORM check_loan_exists(v_loan_id);

	-- Get settings
	select value into v_CEIAFL01 from organization_settings where organization_id = (select organization_id from loans where id = v_loan_id) and key = 'CEIAFL01';
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'v_CEIAFL01: ' || v_CEIAFL01);
	
	select value into v_CEIAFL02 from organization_settings where organization_id = (select organization_id from loans where id = v_loan_id) and key = 'CEIAFL02';
	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'v_CEIAFL02: ' || v_CEIAFL02);

	FOR loan_statement_record IN SELECT id, payment_status FROM loan_statements where loan_id = v_loan_id loop
		PERFORM create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'loan_statement_record.id: ' || loan_statement_record.id);
		PERFORM create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'loan_statement_record.payment_status: ' || loan_statement_record.payment_status);

		IF loan_statement_record.payment_status = 'scheduled' and v_CEIAFL01 = 'true' THEN
			PERFORM calculate_expected_interest_amount_for_loan_statement(loan_statement_record.id);
		ELSEIF loan_statement_record.payment_status = 'overdue' and v_CEIAFL02 = 'true' THEN
			PERFORM calculate_expected_interest_amount_for_loan_statement(loan_statement_record.id);
		END IF;
	END LOOP;

	perform create_debug_log_entry('calculate_expected_interest_amount_for_loan', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('calculate_expected_interest_amount_for_loan', SQLERRM);
    	RAISE EXCEPTION 'calculate_expected_interest_amount_for_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
