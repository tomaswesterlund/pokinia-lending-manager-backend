CREATE OR REPLACE FUNCTION get_organization_id_from_client_id(v_client_id UUID)
RETURNS uuid AS $$
declare 
	v_organization_id uuid;
begin

	-- Get organization_id
	select organization_id into v_organization_id from clients where id = v_client_id;

    return v_organization_id;
EXCEPTION
    WHEN OTHERS THEN
		perform create_exception_log_entry('get_organization_id_for_client', SQLERRM);
        RAISE EXCEPTION 'get_organization_id_for_client - ERROR: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
