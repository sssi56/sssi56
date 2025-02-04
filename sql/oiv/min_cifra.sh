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
 				  AND rd2.level1 < 1
 			)
 ----------------------------------------------------------
 			SELECT
 				sb4.orig_departmentname as path4,
 				sb3.orig_departmentname as path3,
 				sb2.orig_departmentname as path2,
 				sb1.orig_departmentname as path1,
 				so_post.name, per.email, per.login,
 				coalesce(so_per.lastname, so_per.lastnamealt, '')     AS lastname,
 				coalesce(so_per.firstname, so_per.firstnamealt, '')   AS firstname,
 				coalesce(so_per.middlename, so_per.middlenamealt, '') AS middlename
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
 					 --------------------------------
 					 inner join so_beard sb1 on sb1.id = so_ap.beard
 					 inner join so_beard sb2 on sb1.hierparent = sb2.id
 					 inner join so_beard sb3 on sb2.hierparent = sb3.id
 					 inner join so_beard sb4 on sb3.hierparent = sb4.id
 					 --------------------------------
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