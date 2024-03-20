create or replace function on_user_signed_in(v_user_id uuid)
returns void as $$
declare
    v_user_id_exists boolean;
    v_user_settings_id uuid;
    v_organzation_id uuid;
begin
	perform create_debug_log_entry('on_user_logged_in', 'start');
    perform create_debug_log_entry('on_user_logged_in', 'v_user_id: ' || v_user_id);

    -- Check if user_id exists in users table
    select user_exists(v_user_id) into v_user_id_exists;

    if not v_user_id_exists then
        insert into users (id) values (v_user_id);
    end if;


    -- Get user_settings_id
    select id into v_user_settings_id from user_settings where user_id = v_user_id;

    if v_user_settings_id is null then
        -- Create organization
        insert into organizations (name) values ('New organization: ' || v_user_id) returning id into v_organzation_id;

        -- Create user settings
        insert into user_settings (user_id, selected_organization_id, show_deleted_clients, show_deleted_loans, show_deleted_loan_statements, show_deleted_payments) 
        values (v_user_id, v_organzation_id, true, true, true, true) returning id into v_user_settings_id;
    else
        -- Get organization_id
        select selected_organization_id into v_organzation_id from user_settings where id = v_user_settings_id;
    end if;

    -- Insert default organization settings
    PERFORM insert_organization_settings_if_not_exists(v_organzation_id, 'CEIAFL01', 'true');
    PERFORM insert_organization_settings_if_not_exists(v_organzation_id, 'CEIAFL02', 'false');
	
	perform create_debug_log_entry('on_user_logged_in', 'end');
EXCEPTION
	WHEN OTHERS THEN
		perform create_exception_log_entry('on_user_logged_in', SQLERRM);
    	RAISE EXCEPTION 'on_user_logged_in - ERROR: %', SQLERRM;
end;
$$ LANGUAGE plpgsql;
