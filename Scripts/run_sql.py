import psycopg2

conn = psycopg2.connect(
    dbname="asrlm_dev",
    user="postgres",
    # schema="public",
    password="asrlm@2025",
    host="45.114.178.184",
    port="5444"
)

cur = conn.cursor()

with open("Schema_bkp.sql", "r", encoding="utf-8") as file:
    sql_script = file.read()

cur.execute(sql_script)
conn.commit()

cur.close()
conn.close()

print("Backup script executed successfully!")