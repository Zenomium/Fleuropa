import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    host = "sqletud.u-pem.fr",
    dbname = "prenom.nom_db",  # changer pour enter
    password = "mot_de_pass",  # changer pour enter
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn
