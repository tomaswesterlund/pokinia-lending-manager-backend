create or replace function undelete_loan(v_loan_id uuid)
returns void as $$
declare
	v_client_id uuid;
begin
	perform create_debug_log_entry('undelete_loan', 'start');

	-- Declare variables
	SELECT client_id
	INTO v_client_id
	FROM loans
	WHERE id = v_loan_id;

	-- Update
	UPDATE loans
	SET delete_date = null, delete_reason = null, payment_status = 'unknown'
	WHERE id = v_loan_id;

	-- Calculate values
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	perform create_debug_log_entry('undelete_loan', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('undelete_loan', SQLERRM);
    	RAISE EXCEPTION 'delete_loan - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
