# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#provincias = ::Afip::CTG.new().consultar_provincias.map{|c,p| {"name" => p, "id" => c}}

# provincias.each do |p|
# 	pp province 	= Province.where(name: p["name"], code: p["id"]).first_or_create
# 	pp localidades = ::Afip::CTG.new().consultar_localidades(province.code).map{|c,p| {"name" => p, "id" => c}}
# 	localidades.each do |l|
# 		Locality.where(code: l["id"], name: l["name"], province_id: province.id).first_or_create
# 	end
# end

province = Province.where(name: "Salta", code: "9").first_or_create
Locality.where(code: "10", name: "Capital", province_id: province.id).first_or_create