-- https://stackoverflow.com/questions/4852933/is-there-a-way-to-have-mysqldump-progress-bar-which-shows-the-users-the-status-o
SELECT table_schema AS "Database", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)" FROM information_schema.TABLES GROUP BY table_schema;
