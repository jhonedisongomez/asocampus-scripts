create or replace function is_administrator(

	p_user_pk auth_user.id%type,
	p_message out varchar,
	p_is_admin out boolean,
	p_is_error out boolean
) as $$

declare
	
	v_value varchar;
	
begin
	
	p_is_error := false;	
	select 'X' into v_value
	from roles_rolesprofile rol_pro, roles_roles rol, profiles_profile prof
	where prof.fk_user_id = p_user_pk
	and prof.active = true
	and rol.id = 1
	and rol.active = true
	and rol_pro.fk_profile_id = prof.id
	and rol_pro.active = true;
	
	p_is_admin := true;
	if not found then
		p_message := 'El usuario no es administrador';
		p_is_admin := false;
		
	
	end if;
	
	exception when others then
	
	p_is_error := true;
	p_message := 'Error obteniendo el perfil por favor comuniquese con el administrador. '|| SQLERRM;
	

end;$$
LANGUAGE plpgsql;