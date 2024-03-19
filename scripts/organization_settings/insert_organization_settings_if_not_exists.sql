create or replace function insert_organization_settings_if_not_exists(v_organization_id uuid, v_key text, v_value text)
returns void as $$
declare
    v_exists boolean;
begin
	perform create_debug_log_entry('insert_organization_settings_if_not_exists', 'start');
    perform create_debug_log_entry('insert_organization_settings_if_not_exists', 'v_organization_id: ' || v_organization_id);
    perform create_debug_log_entry('insert_organization_settings_if_not_exists', 'v_key: ' || v_key);
    perform create_debug_log_entry('insert_organization_settings_if_not_exists', 'v_value: ' || v_value);

    -- Check if organization_settings exists
    select exists(select 1 from organization_settings where organization_id = v_organization_id and key = v_key) into v_exists;

    if not v_exists then
        PERFORM create_debug_log_entry('insert_organization_settings_if_not_exists', 'organization_settings does not exist. Inserting default value.');
        -- Insert organization_settings
        insert into organization_settings (organization_id, key, value) values (v_organization_id, v_key, v_value);
    end if;
	
	perform create_debug_log_entry('insert_organization_settings_if_not_exists', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('insert_organization_settings_if_not_exists', SQLERRM);
    	RAISE EXCEPTION 'insert_organization_settings_if_not_exists - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
