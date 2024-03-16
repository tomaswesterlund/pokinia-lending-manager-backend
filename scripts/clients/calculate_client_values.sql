CREATE OR REPLACE FUNCTION calculate_client_values(v_client_id UUID)
RETURNS VOID AS $$
declare 
	v_payment_status text;
	v_has_overdue BOOLEAN;
	v_has_loans BOOLEAN;
begin
	perform create_debug_log_entry('calculate_client_values', 'start');

	-- Update payment status
	perform update_client_payment_status(v_client_id);
	
	perform create_debug_log_entry('calculate_client_values', 'end');
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('calculate_client_values', SQLERRM);
        RAISE EXCEPTION 'An unexpected error occurred: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
