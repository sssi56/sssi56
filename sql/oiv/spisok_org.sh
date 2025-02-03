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