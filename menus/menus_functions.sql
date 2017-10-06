create or replace function create_menu(
	
	p_menu_code menu.menu_code%type,
	p_menu_label menu.menu_label%type,
	p_menu_url menu.menu_url%type,
	p_user_pk auth_user.id%type,
	p_rol_pk roles_roles.id%type,
	p_is_error out  boolean,
	p_message out varchar
	
) as $$

declare
	
	v_values varchar;

begin
	
	p_is_error := false;
	
	insert into menu(menu_code, menu_label, menu_url, active, "version", fk_rol)
	values(p_menu_code, p_menu_label, p_menu_url, true, 0, p_rol_pk);
	
	v_values = p_menu_label||','||p_menu_url||',true,0,'||p_rol_pk;
	
	insert into auditor_menu("action", "table", field, before_value,
		after_value, record_code, "date", user_id)
	values('create','menu','all',null,v_values,p_menu_code,current_date, p_user_pk);
	
	p_message := 'La opcion del menu ha sido guardado en la base de datos';

	exception when others then
		begin
			p_message := 'Error en el sistema por favor comuniquese con el administrador. ';
			p_is_error := true;
			rollback;
		end;
end; $$
LANGUAGE plpgsql;

create or replace function get_menu(

	p_user_pk auth_user.id%type
	
) returns table(

	o_menu_label menu.menu_label%type,
	o_menu_url menu.menu_url%type


) as $$

declare
	
	
begin
	
	return query
	select menu.menu_label, menu.menu_url from profiles_profile pro, roles_rolesprofile rolpro, menu menu
	where pro.fk_user_id = p_user_pk
	and pro.active = true
	and rolpro.fk_profile_id = pro.id
	and rolpro.active = true
	and menu.fk_rol = rolpro.fk_rol_id
	and menu.active = true;
	
end; $$

LANGUAGE plpgsql;


create or replace function get_menu_options(
	p_user_pk auth_user.id%type
) returns table(

	o_menu_label menu_options.menu_option_label%type,
	o_menu_url menu_options.menu_option_url%type


) as $$

declare

begin
	
	return query
	select menuopt.menu_option_label, menuopt.menu_option_url
	from profiles_profile pro,
	roles_rolesprofile rolpro, menu menu,
	menu_options menuopt
	where pro.fk_user_id = p_user_pk
	and pro.active = true
	and rolpro.fk_profile_id = pro.id
	and rolpro.active = true
	and menu.fk_rol = rolpro.fk_rol_id
	and menu.active = true
	and menuopt.fk_menu = menu.id
	and menuopt.active = true;	
	
end; $$

LANGUAGE plpgsql;