------------------------------------------------------------

CREATE OR REPLACE FUNCTION delete_client(v_client_id UUID, v_delete_date date, v_delete_reason text)
RETURNS void AS $$
begin
	insert into log (origin, message) values ('delete_client', 'start');
	insert into log (origin, message) values ('v_client_id', v_client_id);

	update clients
	set delete_date = v_delete_date, delete_reason = v_delete_reason, payment_status = 'deleted'
	where id = v_client_id;


	insert into log (origin, message) values ('delete_client', 'end');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'delete_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

