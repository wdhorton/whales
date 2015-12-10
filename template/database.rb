require 'whales_orm'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
ROOT_FOLDER = File.join(File.dirname(__FILE__), '../db')

# sql file name goes here, the default is database.sql
SQL_FILE = File.join(ROOT_FOLDER, 'database.sql')

# Here you can configure where you want the database file to be saved
DB_FILE = File.join(ROOT_FOLDER, 'database.db')
