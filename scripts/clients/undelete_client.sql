CREATE OR REPLACE FUNCTION undelete_client(v_client_id UUID)
RETURNS void AS $$
begin
	insert into log (origin, message) values ('undelete_client', 'start');
	insert into log (origin, message) values ('v_client_id', v_client_id);

	update clients
	set delete_date = null, delete_reason = null, payment_status = 'unknown'
	where id = v_client_id;

	perform calculate_client_values(v_client_id);


	insert into log (origin, message) values ('undelete_client', 'end');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'undelete_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

