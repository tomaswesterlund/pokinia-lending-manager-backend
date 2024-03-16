create or replace function undelete_loan_statement(v_loan_statement_id uuid)
returns void as $$
declare 
	v_client_id uuid;
	v_loan_id uuid;
begin
	perform create_debug_log_entry('undelete_loan_statement', 'v_loan_statement_id: ' || v_loan_statement_id);

	-- Declare variables
	SELECT client_id, loan_id
	INTO v_client_id, v_loan_id
	FROM loan_statements
	WHERE id = v_loan_statement_id;

	-- Update
	UPDATE loan_statements
	SET delete_date = null, delete_reason = null, payment_status = 'unknown'
	WHERE id = v_loan_statement_id;

	-- Calculate values
	perform calculate_loan_statement_values(v_loan_statement_id);
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	perform create_debug_log_entry('undelete_loan_statement', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('undelete_loan_statement', SQLERRM);
    	RAISE EXCEPTION 'undelete_loan_statement - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;