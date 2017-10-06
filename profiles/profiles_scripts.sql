create or replace function get_profile_activity(

	p_user_pk auth_user.id%type,
	p_is_error out  boolean,
	p_message out varchar,
	p_profile_code out profiles_profile.profile_code%type,
	p_document_id out profiles_profile.document_id%type,
	p_first_name out profiles_profile.first_name%type,
	p_last_name out profiles_profile.last_name%type,
	p_phone_number out profiles_profile.phone_number%type,
	p_mobil_number out profiles_profile.mobil_number%type,
	p_sign_up_acti_act out integer
	
)as $$

begin
	
	p_is_error = false;
	
	select
	pro.profile_code,
	pro.document_id,
	pro.first_name,
	pro.last_name,
	pro.phone_number,
	pro.mobil_number,
	pro.fk_id_type_id
	
	into
	p_profile_code,
	p_document_id,
	p_first_name,
	p_last_name,
	p_phone_number,
	p_mobil_number
	from
	profiles_profile pro
	where
	pro.fk_user_id = p_user_pk and pro.active = true;

	if not found then
	
		p_message := 'No existe un perfil con este usuario';

	else
	
		select count(*) into p_sign_up_acti_act from activities_signupactivities sig
		where sig.active = true and sig.fk_user_id = p_user_pk;
	
	end if;

	exception when others then
		
		p_is_error := true;
		p_message := 'Error obteniendo el perfil por favor comuniquese con el administrador. '|| SQLERRM;
		
end; $$
LANGUAGE plpgsql;