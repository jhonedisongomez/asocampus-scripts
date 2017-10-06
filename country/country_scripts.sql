create or replace function create_country(

  p_country_code country_country.country_code%type,
  p_country_name country_country.country_name%type,
  p_user_pk auth_user.id%type,
  o_message out varchar,
  o_is_error out boolean,
  o_is_admin OUT BOOLEAN


)as $$

declare
  v_is_admin varchar;
  v_exist varchar;
  v_values varchar;
  v_id_country int4;
begin
  o_is_admin := FALSE ;
  o_is_error := false;

  select 'X' into v_is_admin from profiles_profile pro, roles_rolesprofile rolpro
  where pro.fk_user_id = p_user_pk
        and pro.active = true
        and rolpro.fk_profile_id = pro.id
        and rolpro.fk_rol_id = 1;

  if not found then
    o_message := 'No tienes permisos para realizar esta acción';


  else
    o_is_admin := TRUE ;
    select 'X' into v_exist from country_country co
    where co.country_name = p_country_name and co.active = true;

    if not found then
      v_id_country := nextval('country_country_id_seq'::regclass);

      INSERT INTO country_country
      (id, country_code, country_name, active, "version")
      VALUES(v_id_country, p_country_code, p_country_name, true, 0);

      v_values := p_country_code||','||p_country_name||',true,0';

      INSERT INTO country_auditorcountry
      ("action", "table", field, before_value, after_value, "date", user_id, object_id)
      VALUES( 'create', 'country_country', 'all',null, v_values, current_date, p_user_pk, v_id_country);

      o_message := 'Se ha guardado el nuevo pais en la base de datos';
    else
      o_message := 'El pais ya existe en el sistema';
    end if;

  end if;

  exception when others then

    o_message := 'Error guardando el pais comuniquese con el administrador del sistema';
    o_is_error := true;


end; $$
LANGUAGE plpgsql;



CREATE  OR REPLACE FUNCTION  list_country (

  p_user_pk auth_user.id%TYPE

)RETURNS TABLE(

o_country_code country_country.country_code%type,
o_name country_country.country_name%type,
o_active country_country.active%type

)

as $$

DECLARE
  v_admin VARCHAR;
BEGIN

  SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
  WHERE us.id = p_user_pk
        AND us.is_active = TRUE
        AND pro.fk_user_id = us.id
        AND pro.active = TRUE
        AND rol_pro.fk_profile_id = pro.id
        AND rol_pro.fk_rol_id = 1;

  IF found THEN

    RETURN QUERY
    SELECT  coun.country_code ,coun.country_name, coun.active FROM country_country coun
    ORDER BY coun.country_name;

  ELSE
  END IF ;

end; $$


LANGUAGE plpgsql;


CREATE or REPLACE FUNCTION getCountry (

  p_id_user auth_user.id%TYPE,
  p_country_code country_country.country_code%TYPE,
  o_country_name out country_country.country_name%TYPE,
  o_is_active out country_country.active%TYPE,
  p_message out varchar,
  p_is_error out varchar,
  p_is_admin out varchar

)as $$

DECLARE
  v_admin VARCHAR;

begin

  p_is_error := FALSE ;
  p_is_admin := FALSE ;

  SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
  WHERE us.id = p_id_user
        AND us.is_active = TRUE
        AND pro.fk_user_id = us.id
        AND pro.active = TRUE
        AND rol_pro.fk_profile_id = pro.id
        AND rol_pro.fk_rol_id = 1;

  IF NOT found THEN

    p_message := 'El usuario no esta autorizado para realizar esta acción';

  ELSE

    p_is_admin := TRUE ;
    SELECT cou.country_name, cou.active into o_country_name,o_is_active from country_country cou
    where cou.country_code = p_country_code;

    IF NOT found THEN

      p_message := 'El codigo del pais no existe en la base de datos';
    END IF ;
  END IF ;

  exception when others then

    p_message := 'Error listando los pais comuniquese con el administrador del sistema';
    p_is_error := true;
end; $$
LANGUAGE plpgsql;



CREATE or REPLACE FUNCTION edit_country(

  p_country_code country_country.country_code%TYPE,
  p_country_name country_country.country_name%TYPE,
  p_is_active country_country.active%TYPE,
  p_user_pk auth_user.id%TYPE,
  o_message out varchar,
  o_is_error out BOOLEAN,
  o_is_admin out BOOLEAN

)AS
  $$

  DECLARE

    v_admin VARCHAR;
    v_country_id country_country.id%TYPE;
    v_country_name country_country.country_name%TYPE;
    v_is_active country_country.active%TYPE;
    v_exist VARCHAR;

  BEGIN

    o_is_error := FALSE ;
    o_is_admin := FALSE ;

    SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
    WHERE us.id = p_user_pk
          AND us.is_active = TRUE
          AND pro.fk_user_id = us.id
          AND pro.active = TRUE
          AND rol_pro.fk_profile_id = pro.id
          AND rol_pro.fk_rol_id = 1;

    IF NOT found THEN

      o_message := 'El usuario no esta autorizado para realizar esta acción';

    ELSE
      o_is_admin := TRUE ;
      SELECT id, country_name, active into v_country_id, v_country_name, v_is_active FROM country_country WHERE
        country_code = p_country_code;

      IF v_country_name != p_country_name AND  v_is_active != p_is_active THEN

        select '*' into v_exist from country_country coun WHERE
          coun.country_name = p_country_name;

        IF NOT found THEN

          UPDATE country_country SET
            country_name = p_country_name,
            active = p_is_active
          WHERE id = v_country_id;

          INSERT INTO country_auditorcountry
          ("action", "table", field, before_value, after_value, "date", user_id, object_id)
          VALUES( 'edit', 'country_country', 'country_name, is_active',v_country_name || ', '|| v_is_active, p_country_name || ', ' || p_is_active, current_date, p_user_pk, v_country_id);

        ELSE

          o_message := 'El pais existe en la base de datos por favor ingrese otro nombre';

        END IF ;

      ELSE

        IF v_country_name != p_country_name THEN

          select '*' into v_exist from country_country coun WHERE
            coun.country_name = p_country_name;

          IF NOT found THEN

            UPDATE country_country SET
              country_name = p_country_name
            WHERE id = v_country_id;

            INSERT INTO country_auditorcountry
            ("action", "table", field, before_value, after_value, "date", user_id, object_id)
            VALUES( 'edit', 'country_country', 'country_name',v_country_name, p_country_name, current_date, p_user_pk, v_country_id);

            o_message := 'EL pais ha sido actualizado de manera exitosa';

          ELSE

            o_message := 'El pais existe en la base de datos por favor ingrese otro nombre';

          END  IF ;

        ELSE

          IF v_is_active != p_is_active THEN

            UPDATE country_country SET
              active = p_is_active
            WHERE id = v_country_id;

            INSERT INTO country_auditorcountry
            ("action", "table", field, before_value, after_value, "date", user_id, object_id)
            VALUES( 'edit', 'country_country', 'active',v_is_active, p_is_active, current_date, p_user_pk, v_country_id);

            o_message := 'EL pais ha sido actualizado de manera exitosa';

          END IF ;

        END IF ;

      END IF ;

    END IF ;

    exception when others then

      o_message := 'Error editando el pais comuniquese con el administrador del sistema ' ||  SQLERRM || ' ' || SQLSTATE;
      o_is_error := true;

  END ;

  $$
LANGUAGE plpgsql;

CREATE  OR REPLACE FUNCTION  list_section_types (

  p_user_pk auth_user.id%TYPE

)RETURNS TABLE(

o_section_type_code country_sectiontype.section_type_code%type,
section_type_name country_sectiontype.section_type_name%type,
o_active country_sectiontype.active%type

)

as

  $$

  DECLARE
    v_admin VARCHAR;
  BEGIN

    SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
    WHERE us.id = p_user_pk
          AND us.is_active = TRUE
          AND pro.fk_user_id = us.id
          AND pro.active = TRUE
          AND rol_pro.fk_profile_id = pro.id
          AND rol_pro.fk_rol_id = 1;

    IF found THEN

      RETURN QUERY
      SELECT  sectiontype.section_type_code,sectiontype.section_type_name, sectiontype.active FROM country_sectiontype sectiontype
      ORDER BY sectiontype.section_type_name;

    ELSE
    END IF ;

  end;

  $$


LANGUAGE plpgsql;

create or replace function create_section_type(

  p_section_type_code country_country.country_code%type,
  p_section_type_name country_country.country_name%type,
  p_user_pk auth_user.id%type,
  o_message out varchar,
  o_is_error out boolean,
  o_is_admin OUT BOOLEAN


)as $$

declare
  v_is_admin varchar;
  v_exist varchar;
  v_values varchar;
  v_id_section_type country_sectiontype.id%TYPE;
begin
  o_is_admin := FALSE ;
  o_is_error := false;

  select 'X' into v_is_admin from profiles_profile pro, roles_rolesprofile rolpro
  where pro.fk_user_id = p_user_pk
        and pro.active = true
        and rolpro.fk_profile_id = pro.id
        and rolpro.fk_rol_id = 1;

  if not found then
    o_message := 'No tienes permisos para realizar esta acción';


  else
    o_is_admin := TRUE ;
    select 'X' into v_exist from country_sectiontype sectiontype
    where sectiontype.section_type_name = p_section_type_name and sectiontype.active = true;

    if not found then

      v_id_section_type := nextval('country_sectiontype_id_seq'::regclass);

      INSERT INTO country_sectiontype
      (id,section_type_code, section_type_name, active, "version")
      VALUES(v_id_section_type,p_section_type_code, p_section_type_name, true, 0);

      v_values := p_section_type_code||','||p_section_type_name||',true,0';

      INSERT INTO country_auditorcountry
      ("action", "table", field, before_value, after_value, "date", user_id, object_id)
      VALUES( 'create', 'country_sectiontype', 'all',null, v_values, current_date, p_user_pk, v_id_section_type);

      o_message := 'Se ha guardado el nuevo tipo de sección en la base de datos';
    else

      o_message := 'El tipo de sección ya existe en el sistema';

    end if;

  end if;

  exception when others then

    o_message := 'Error guardando el tipo de sección comuniquese con el administrador del sistema' || SQLERRM ||' ' || SQLSTATE;
    o_is_error := true;


end; $$
LANGUAGE plpgsql;

CREATE or REPLACE FUNCTION get_section_type (

  p_id_user auth_user.id%TYPE,
  p_section_type_code country_sectiontype.section_type_code%TYPE,
  o_section_type_name out country_sectiontype.section_type_name%TYPE,
  o_is_active out country_sectiontype.active%TYPE,
  p_message out varchar,
  p_is_error out varchar,
  p_is_admin out varchar

)as $$

DECLARE
  v_admin VARCHAR;

begin

  p_is_error := FALSE ;
  p_is_admin := FALSE ;

  SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
  WHERE us.id = p_id_user
        AND us.is_active = TRUE
        AND pro.fk_user_id = us.id
        AND pro.active = TRUE
        AND rol_pro.fk_profile_id = pro.id
        AND rol_pro.fk_rol_id = 1;

  IF NOT found THEN

    p_message := 'El usuario no esta autorizado para realizar esta acción';

  ELSE

    p_is_admin := TRUE ;
    SELECT sectiontype.section_type_name, sectiontype.active into o_section_type_name,o_is_active from country_sectiontype sectiontype
    where sectiontype.section_type_code = p_section_type_code;

    IF NOT found THEN

      p_message := 'El codigo del pais no existe en la base de datos';
    END IF ;
  END IF ;

  exception when others then

    p_message := 'Error listando los pais comuniquese con el administrador del sistema';
    p_is_error := true;

end; $$
LANGUAGE plpgsql;

CREATE or REPLACE FUNCTION edit_section_type(

  p_section_type_code country_sectiontype.section_type_code%TYPE,
  p_section_type_name country_sectiontype.section_type_name%TYPE,
  p_is_active country_sectiontype.active%TYPE,
  p_user_pk auth_user.id%TYPE,
  o_message out varchar,
  o_is_error out BOOLEAN,
  o_is_admin out BOOLEAN

)AS
  $$

  DECLARE

    v_admin VARCHAR;
    v_section_type_id country_sectiontype.id%TYPE;
    v_section_type_name country_sectiontype.section_type_name%TYPE;
    v_is_active country_sectiontype.active%TYPE;
    v_exist VARCHAR;

  BEGIN

    o_is_error := FALSE ;
    o_is_admin := FALSE ;

    SELECT '*' INTO v_admin FROM  auth_user us, profiles_profile pro, roles_rolesprofile rol_pro
    WHERE us.id = p_user_pk
          AND us.is_active = TRUE
          AND pro.fk_user_id = us.id
          AND pro.active = TRUE
          AND rol_pro.fk_profile_id = pro.id
          AND rol_pro.fk_rol_id = 1;

    IF NOT found THEN

      o_message := 'El usuario no esta autorizado para realizar esta acción';

    ELSE
      o_is_admin := TRUE ;
      SELECT id, section_type_name, active into v_section_type_id, v_section_type_name, v_is_active FROM country_sectiontype WHERE
        section_type_code = p_section_type_code;

      IF v_section_type_name != p_section_type_name AND  v_is_active != p_is_active THEN

        select '*' into v_exist from country_sectiontype sectiontype WHERE
          sectiontype.section_type_name = p_section_type_name;

        IF NOT found THEN

          UPDATE country_sectiontype SET
            section_type_name = p_section_type_name,
            active = p_is_active
          WHERE id = v_section_type_id;

          INSERT INTO country_auditorcountry
          ("action", "table", field, before_value, after_value, "date", user_id, object_id)
          VALUES( 'edit', 'country_sectiontype', 'section_type_name, is_active',v_section_type_name || ', '|| v_is_active, p_section_type_name || ', ' || p_is_active, current_date, p_user_pk, v_section_type_id);

        ELSE

          o_message := 'El pais existe en la base de datos por favor ingrese otro nombre';

        END IF ;

      ELSE

        IF v_section_type_name != p_section_type_name THEN

          select '*' into v_exist from country_sectiontype WHERE
            section_type_name = p_country_name;

          IF NOT found THEN

            UPDATE country_sectiontype SET
              section_type_name = p_section_type_name
            WHERE id = v_section_type_id;

            INSERT INTO country_auditorcountry
            ("action", "table", field, before_value, after_value, "date", user_id, object_id)
            VALUES( 'edit', 'country_sectiontype', 'section_type_name',v_section_type_name, p_section_type_name, current_date, p_user_pk, v_section_type_id);

            o_message := 'EL pais ha sido actualizado de manera exitosa';

          ELSE

            o_message := 'El pais existe en la base de datos por favor ingrese otro nombre';

          END  IF ;

        ELSE

          IF v_is_active != p_is_active THEN

            UPDATE country_sectiontype SET
              active = p_is_active
            WHERE id = v_section_type_id;

            INSERT INTO country_auditorcountry
            ("action", "table", field, before_value, after_value, "date", user_id, object_id)
            VALUES( 'edit', 'country_sectiontype', 'active',v_is_active, p_is_active, current_date, p_user_pk, v_section_type_id);

            o_message := 'EL pais ha sido actualizado de manera exitosa';

          END IF ;

        END IF ;

      END IF ;

    END IF ;

    exception when others then

      o_message := 'Error editando el pais comuniquese con el administrador del sistema ' ||  SQLERRM || ' ' || SQLSTATE;
      o_is_error := true;

  END ;

  $$
LANGUAGE plpgsql;
