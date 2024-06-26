create or replace function create_payment_for_open_ended_loan(v_client_id UUID, v_loan_id UUID, v_loan_statement_id UUID, v_interest_amount_paid float8, v_principal_amount_paid float8, v_pay_date date, v_receipt_image_url text, v_description text)
returns void as $$
declare
	loan_statement_record RECORD;
begin
	perform create_debug_log_entry('create_payment_for_open_ended_loan', 'start');

	-- Insert payment 
	insert into payments (client_id, loan_id, loan_statement_id, interest_amount_paid, principal_amount_paid, pay_date, receipt_image_url, description)
	values (v_client_id, v_loan_id, v_loan_statement_id, v_interest_amount_paid, v_principal_amount_paid, v_pay_date, v_receipt_image_url, v_description);

	-- Calculate values
	perform calculate_loan_statement_values(v_loan_statement_id);
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	PERFORM calculate_expected_interest_amount_for_loan(v_loan_id);

	perform create_debug_log_entry('create_payment_for_open_ended_loan', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('create_payment_for_open_ended_loan', SQLERRM);
    	RAISE EXCEPTION 'create_payment_for_open_ended_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
