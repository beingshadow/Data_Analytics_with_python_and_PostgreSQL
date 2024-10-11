import pandas as pd
import psycopg2
from dotenv import dotenv_values 
#  scram-sha-256

config=dotenv_values(".env")

hostname = config['hostname']
database = config['database']
username = config['username']
port_id = config['port_id']
pwd = config['password']

conn=psycopg2.connect(
    host=hostname,
    dbname=database,
    user=username,
    password=pwd,
    port=port_id

)

conn.close()
