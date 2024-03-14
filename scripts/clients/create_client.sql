CREATE OR REPLACE FUNCTION create_client(v_organization_id UUID, v_name text, v_phone_number text, v_address text, v_avatar_image_path text)
RETURNS void AS $$
begin
	insert into log (origin, message) values ('create_client', 'start');

	insert into clients (organization_id, name, phone_number, address, avatar_image_path, payment_status)
	values (v_organization_id, v_name, v_phone_number, v_address, v_avatar_image_path, 'empty');

	insert into log (origin, message) values ('create_client', 'end');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'create_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

