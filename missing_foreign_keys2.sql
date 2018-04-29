SELECT
pg_catalog.pg_get_constraintdef(source_constraint.oid),
source_constraint.conkey,
    source_table.relname AS source_table,
    source_attribute.attname AS source_attribute,
    related_table.relname AS related_table,
    related_attribute.attname AS related_attribute
FROM pg_catalog.pg_namespace AS namespace
INNER JOIN pg_catalog.pg_class AS source_table ON (source_table.relnamespace = namespace.oid)
INNER JOIN pg_catalog.pg_attribute AS source_attribute ON (source_attribute.attrelid = source_table.oid)
INNER JOIN pg_catalog.pg_constraint AS source_constraint ON (source_constraint.conrelid = source_table.oid AND source_attribute.attnum = ALL(source_constraint.conkey))
INNER JOIN pg_catalog.pg_attribute AS related_attribute ON (related_attribute.attname LIKE '%' || source_attribute.attname AND related_attribute.attrelid != source_attribute.attrelid)
INNER JOIN pg_catalog.pg_class AS related_table ON (related_table.relnamespace = namespace.oid AND related_table.oid = related_attribute.attrelid)
WHERE source_constraint.contype = 'p'
AND source_table.relkind = 'r'
AND related_table.relkind = 'r'
AND related_attribute.attnum > 0
AND source_attribute.attnum > 0
AND NOT related_attribute.attisdropped
AND NOT source_attribute.attisdropped
AND namespace.nspname NOT IN ('pg_toast','information_schema','pg_catalog')
AND source_attribute.attname LIKE '%id'
AND NOT EXISTS (
    -- There is no FOREIGN KEY on this column
    SELECT 1 FROM pg_catalog.pg_constraint
    WHERE pg_catalog.pg_constraint.contype = 'f'
    AND pg_catalog.pg_constraint.conrelid = related_table.oid
    AND pg_catalog.pg_get_constraintdef(pg_catalog.pg_constraint.oid) LIKE (format('FOREIGN KEY (%s)',related_attribute.attname) || '%')
)
AND NOT EXISTS (
    -- This column is not the PRIMARY KEY of it's own table,
    -- since if it was, we wouldn't require a FOREIGN KEY on it
    SELECT 1 FROM pg_catalog.pg_constraint
    WHERE pg_catalog.pg_constraint.contype = 'p'
    AND pg_catalog.pg_constraint.conrelid = related_table.oid
    AND pg_catalog.pg_get_constraintdef(pg_catalog.pg_constraint.oid) = format('PRIMARY KEY (%s)',related_attribute.attname)
)
ORDER BY
namespace.nspname,
related_table.relname,
related_attribute.attnum