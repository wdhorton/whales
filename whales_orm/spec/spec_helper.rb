require 'pry'
require_relative '../lib/base'

ROOT_FOLDER = File.join(File.dirname(__FILE__), '../test_db')
SQL_FILE = File.join(ROOT_FOLDER, 'cats.sql')
DB_FILE = File.join(ROOT_FOLDER, 'cats.db')
