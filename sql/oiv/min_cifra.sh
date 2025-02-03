psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "DROP SCHEMA public CASCADE;"
psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "VACUUM FULL VERBOSE ANALYZE;"
psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "CREATE SCHEMA public;"

pg_dump -h 172.28.123.16 -U postgres -d cm6 \
 -t so_department \
 -t department \
 -t SO_Appointment \
 -t so_personsys \
 -t SO_PostPlain \
 -t so_postplain_acl \
 -t SO_Post \
 -t so_parent \
 -t SO_Parent_SU \
 -t SO_StructureUnit \
 -t so_unit \
 -t so_orgsystem \
 -t domain_object_type_id \
 -t so_appointmentplain \
 -t so_accessredirectregplace \
 -t security_stamp \
 -t so_addressdata_person \
 -t so_person_hist \
 -t so_orgdescriptionnonsys \
 -t so_personnonsysprivate_acl \
 -t so_orgdescription_hist \
 -t so_rspost \
 -t status \
 -t person_profile \
 -t so_orgdescription_hist \
 -t so_person_hist \
 -t so_posthead \
 -t so_parent_ph \
 -t so_appointmenthead \
 -t so_person \
 -t person \
 -F c > dump_so_department.dump;
pg_restore -h 172.18.0.2 -U postgres -d cm6 -c -C -v dump_so_department.dump;

psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "CREATE TABLE org_spisok AS
SELECT so_dep.id,
       so_su.fullname,
       so_su.shortname,
       so_dep.type,
       hierparent
FROM so_department so_dep
INNER JOIN so_structureunit so_su ON so_su.id = so_dep.id
INNER JOIN so_orgsystem so_org ON so_org.id = so_dep.HierRoot
WHERE 1 = 1
  AND so_org.isdeleted = 0
  AND so_dep.accessredirect IS NULL
  AND so_dep.hierparent = 2
ORDER BY so_dep.id ASC;";

psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "CREATE TABLE sotr_spisok_min_cifra AS
WITH RECURSIVE recursive_data AS (
 				SELECT
 					so_u.id AS head_id,
 					0       AS level
 				FROM so_department so_dep
 						 INNER JOIN SO_StructureUnit so_su ON so_su.id = so_dep.id
 						 INNER JOIN so_unit so_u ON so_u.id = so_su.id
 				WHERE 1 = 1
 					AND so_dep.id = 233
 				UNION
 				SELECT
 					so_u.id      AS head_id,
 					rd.level + 1 AS level
 				FROM so_unit so_u
 						 INNER JOIN (
 					SELECT
 						so_u.id           AS unit_id,
 						so_ph_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_post so_p ON so_p.id = so_u.id
 							 INNER JOIN so_posthead so_ph ON so_ph.id = so_p.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_p.hierparent
 							 INNER JOIN so_parent_ph so_p_ph ON so_p_ph.id = so_par.id
 							 INNER JOIN SO_PostHead so_ph_parent ON so_ph_parent.id = so_p_ph.owner
 							 INNER JOIN so_post so_p_parent ON so_p_parent.id = so_ph_parent.id
 							 INNER JOIN so_unit so_ph_u_parent ON so_ph_u_parent.id = so_p_parent.id
 							 INNER JOIN so_appointmenthead so_ah ON so_ah.post = so_ph.id
 							 INNER JOIN SO_Appointment so_a ON so_ah.id = so_a.id
 							 INNER JOIN so_appointmenthead so_ah_parent ON so_ah_parent.post = so_ph_parent.id
 							 INNER JOIN SO_Appointment so_a_parent ON so_ah_parent.id = so_a_parent.id
 					WHERE so_p.isdeleted = 0
 					  AND so_p_parent.isdeleted = 0
 					  AND so_a.isprimary = 1
 					  AND so_a_parent.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_su_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_post so_p ON so_p.id = so_u.id
 							 INNER JOIN so_posthead so_ph ON so_ph.id = so_p.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_p.hierparent
 							 INNER JOIN so_parent_su so_p_su ON so_p_su.id = so_par.id
 							 INNER JOIN SO_StructureUnit so_su_parent ON so_su_parent.id = so_p_su.owner
 							 INNER JOIN so_unit so_su_u_parent ON so_su_u_parent.id = so_su_parent.id
 							 INNER JOIN so_appointmenthead so_ah ON so_ah.post = so_ph.id
 							 INNER JOIN SO_Appointment so_a ON so_ah.id = so_a.id
 					WHERE so_p.isdeleted = 0
 					  AND so_a.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_ph_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_structureunit so_su ON so_su.id = so_u.id
 							 INNER JOIN so_department so_dep ON so_dep.id = so_su.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_dep.hierparent
 							 INNER JOIN so_parent_ph so_p_ph ON so_p_ph.id = so_par.id
 							 INNER JOIN SO_PostHead so_ph_parent ON so_ph_parent.id = so_p_ph.owner
 							 INNER JOIN so_post so_p_parent ON so_p_parent.id = so_ph_parent.id
 							 INNER JOIN so_unit so_ph_u_parent ON so_ph_u_parent.id = so_p_parent.id
 							 INNER JOIN so_appointmenthead so_ah_parent ON so_ah_parent.post = so_ph_parent.id
 							 INNER JOIN SO_Appointment so_a_parent ON so_ah_parent.id = so_a_parent.id
 					WHERE so_p_parent.isdeleted = 0
 					  AND so_a_parent.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_su_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_structureunit so_su ON so_su.id = so_u.id
 							 INNER JOIN so_department so_dep ON so_dep.id = so_su.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_dep.hierparent
 							 INNER JOIN so_parent_su so_p_su ON so_p_su.id = so_par.id
 							 INNER JOIN SO_StructureUnit so_su_parent ON so_su_parent.id = so_p_su.owner
 							 INNER JOIN so_unit so_su_u_parent ON so_su_u_parent.id = so_su_parent.id
 					WHERE 1 = 1
 				) head_units_data ON head_units_data.unit_id = so_u.id
 						 INNER JOIN recursive_data rd ON rd.head_id = head_units_data.parent_unit_id
 				WHERE 1 = 1
 				  -- в реальности количество уровней не превышает 4-5, ограничим их на случай возможного зацикливания
 				  AND rd.level < 2
 			),
 ----------------------------------------------------------
 		    recursive_data2 AS (
 				SELECT
 					so_u.id AS head_id,
 					0       AS level1
 				FROM so_department so_dep
 						 INNER JOIN SO_StructureUnit so_su ON so_su.id = so_dep.id
 						 INNER JOIN so_unit so_u ON so_u.id = so_su.id
 				WHERE 1 = 1
 					AND so_dep.type = 'Подведомственное учреждение'
 				UNION
 				SELECT
 					so_u.id      AS head_id,
 					rd2.level1 + 1 AS level1
 				FROM so_unit so_u
 						 INNER JOIN (
 					SELECT
 						so_u.id           AS unit_id,
 						so_ph_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_post so_p ON so_p.id = so_u.id
 							 INNER JOIN so_posthead so_ph ON so_ph.id = so_p.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_p.hierparent
 							 INNER JOIN so_parent_ph so_p_ph ON so_p_ph.id = so_par.id
 							 INNER JOIN SO_PostHead so_ph_parent ON so_ph_parent.id = so_p_ph.owner
 							 INNER JOIN so_post so_p_parent ON so_p_parent.id = so_ph_parent.id
 							 INNER JOIN so_unit so_ph_u_parent ON so_ph_u_parent.id = so_p_parent.id
 							 INNER JOIN so_appointmenthead so_ah ON so_ah.post = so_ph.id
 							 INNER JOIN SO_Appointment so_a ON so_ah.id = so_a.id
 							 INNER JOIN so_appointmenthead so_ah_parent ON so_ah_parent.post = so_ph_parent.id
 							 INNER JOIN SO_Appointment so_a_parent ON so_ah_parent.id = so_a_parent.id
 					WHERE so_p.isdeleted = 0
 					  AND so_p_parent.isdeleted = 0
 					  AND so_a.isprimary = 1
 					  AND so_a_parent.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_su_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_post so_p ON so_p.id = so_u.id
 							 INNER JOIN so_posthead so_ph ON so_ph.id = so_p.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_p.hierparent
 							 INNER JOIN so_parent_su so_p_su ON so_p_su.id = so_par.id
 							 INNER JOIN SO_StructureUnit so_su_parent ON so_su_parent.id = so_p_su.owner
 							 INNER JOIN so_unit so_su_u_parent ON so_su_u_parent.id = so_su_parent.id
 							 INNER JOIN so_appointmenthead so_ah ON so_ah.post = so_ph.id
 							 INNER JOIN SO_Appointment so_a ON so_ah.id = so_a.id
 					WHERE so_p.isdeleted = 0
 					  AND so_a.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_ph_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_structureunit so_su ON so_su.id = so_u.id
 							 INNER JOIN so_department so_dep ON so_dep.id = so_su.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_dep.hierparent
 							 INNER JOIN so_parent_ph so_p_ph ON so_p_ph.id = so_par.id
 							 INNER JOIN SO_PostHead so_ph_parent ON so_ph_parent.id = so_p_ph.owner
 							 INNER JOIN so_post so_p_parent ON so_p_parent.id = so_ph_parent.id
 							 INNER JOIN so_unit so_ph_u_parent ON so_ph_u_parent.id = so_p_parent.id
 							 INNER JOIN so_appointmenthead so_ah_parent ON so_ah_parent.post = so_ph_parent.id
 							 INNER JOIN SO_Appointment so_a_parent ON so_ah_parent.id = so_a_parent.id
 					WHERE so_p_parent.isdeleted = 0
 					  AND so_a_parent.isprimary = 1
 					UNION
 					SELECT
 						so_u.id           AS unit_id,
 						so_su_u_parent.id AS parent_unit_id
 					FROM so_unit so_u
 							 INNER JOIN so_structureunit so_su ON so_su.id = so_u.id
 							 INNER JOIN so_department so_dep ON so_dep.id = so_su.id
 							 INNER JOIN so_parent so_par ON so_par.id = so_dep.hierparent
 							 INNER JOIN so_parent_su so_p_su ON so_p_su.id = so_par.id
 							 INNER JOIN SO_StructureUnit so_su_parent ON so_su_parent.id = so_p_su.owner
 							 INNER JOIN so_unit so_su_u_parent ON so_su_u_parent.id = so_su_parent.id
 					WHERE 1 = 1
 				) head_units_data2 ON head_units_data2.unit_id = so_u.id

 						 INNER JOIN recursive_data2 rd2 ON rd2.head_id = head_units_data2.parent_unit_id
 				WHERE 1 = 1
 				  -- в реальности количество уровней не превышает 4-5, ограничим их на случай возможного зацикливания
 				  AND rd2.level1 < 0
 			)
 ----------------------------------------------------------
 			SELECT
 				coalesce(so_per.lastname, so_per.lastnamealt, '')     AS lastname,
 				coalesce(so_per.firstname, so_per.firstnamealt, '')   AS firstname,
 				coalesce(so_per.middlename, so_per.middlenamealt, '') AS middlename,
 				per.login
 			FROM so_appointmentplain app
 					 INNER JOIN SO_Appointment so_ap ON so_ap.id = app.id
 					 INNER JOIN so_personsys so_per_sys ON so_per_sys.id = so_ap.person
 					 INNER JOIN so_person so_per ON so_per.id = so_per_sys.id
 					 INNER JOIN person per ON per.id = so_per_sys.platformperson
 					 INNER JOIN SO_PostPlain so_pp ON so_pp.id = app.post
 					 INNER JOIN SO_Post so_post ON so_post.id = so_pp.id
 					 INNER JOIN so_parent so_par ON so_par.id = so_post.hierparent
 					 INNER JOIN SO_Parent_SU so_par_su ON so_par_su.id = so_par.id
 					 INNER JOIN SO_StructureUnit so_su ON so_su.id = so_par_su.owner
 					 INNER JOIN so_department so_dep ON so_dep.id = so_su.id
 					 INNER JOIN so_unit so_u ON so_u.id = so_su.id
 			WHERE 1 = 1
 			  --основное назначение
 			  AND so_ap.isprimary = 1
 			  -- права не были переданы
 			  AND app.accessredirect IS NULL
 			  -- назначение не удалено
 			  AND so_post.isdeleted = 0
 			  -- персона не удалена
 			  AND so_per.isdeleted = 0
 			  -- логин должен быть непустым
 			  AND per.login IS NOT NULL
 			  AND trim(per.login) <> ''
 			  AND so_u.id IN (SELECT
 								  head_id
 							  FROM recursive_data)
 ------------------------------------------
 			  AND so_u.id NOT IN (SELECT
 								  head_id
 							  FROM recursive_data2)
 ------------------------------------------
 			ORDER BY
 				so_per.lastname,
 				so_per.firstname,
 				so_per.middlename;";

psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "CREATE TABLE result_table AS
select sotr_spisok.*, person.email
from sotr_spisok, person
where sotr_spisok.login = person.login;";