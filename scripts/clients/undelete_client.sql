CREATE OR REPLACE FUNCTION undelete_client(v_client_id UUID)
RETURNS void AS $$
begin
	perform create_debug_log_entry('undelete_client', 'start');
	perform create_debug_log_entry('undelete_client', 'v_client_id: ' || v_client_id);

	update clients
	set delete_date = null, delete_reason = null, payment_status = 'unknown'
	where id = v_client_id;

	perform calculate_client_values(v_client_id);

	perform create_debug_log_entry('undelete_client', 'end');
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('undelete_client', SQLERRM);
        RAISE EXCEPTION 'undelete_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

