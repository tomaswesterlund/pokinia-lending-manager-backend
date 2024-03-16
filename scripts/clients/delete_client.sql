CREATE OR REPLACE FUNCTION delete_client(v_client_id UUID, v_delete_date date, v_delete_reason text)
RETURNS void AS $$
begin
	perform create_debug_log_entry('delete_client', 'start');
	perform create_debug_log_entry('delete_client', 'v_client_id: ' || v_client_id);
	
	update clients
	set delete_date = v_delete_date, delete_reason = v_delete_reason, payment_status = 'deleted'
	where id = v_client_id;

	perform create_debug_log_entry('delete_client', 'end');
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('delete_client', SQLERRM);
        RAISE EXCEPTION 'delete_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

