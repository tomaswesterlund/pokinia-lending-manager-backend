create or replace function delete_payment(v_payment_id uuid, v_delete_date date, v_delete_reason text)
returns void as $$
declare
	v_client_id uuid;
	v_loan_id uuid;
	v_loan_statement_id uuid;
begin
	perform create_debug_log_entry('delete_payment', 'start');

	-- Declare variables
	SELECT client_id, loan_id, loan_statement_id
	INTO v_client_id, v_loan_id, v_loan_statement_id
	FROM payments
	WHERE id = v_payment_id;

	-- Update
	UPDATE payments
	SET delete_date = v_delete_date, delete_reason = v_delete_reason
	WHERE id = v_payment_id;

	-- Calculate values
	if v_loan_statement_id is not null then -- Needed for Zero Interest Loan
		perform calculate_loan_statement_values(v_loan_statement_id);
	end if;
	perform calculate_loan_values(v_loan_id);
	perform calculate_client_values(v_client_id);

	perform create_debug_log_entry('delete_payment', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('delete_payment', SQLERRM);
    	RAISE EXCEPTION 'delete_payment - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;