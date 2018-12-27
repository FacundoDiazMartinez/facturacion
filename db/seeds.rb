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


###ROL ADMIN

#Role.where(id: 1, name: "Administrador").first_or_initialize.save

####FriendlyNames

f_cli = FriendlyName.where(name: "Clientes", subject_class: "Client").first_or_initialize
f_cli.save
f_fac = FriendlyName.where(name: "Facturas de Venta", subject_class: "Invoice").first_or_initialize
f_fac.save
f_comp = FriendlyName.where(name: "Orden de Compra", subject_class: "PurchaseOrder").first_or_initialize
f_comp.save
f_facom = FriendlyName.where(name: "Facturas de Compra", subject_class: "PurchaseInvoice").first_or_initialize
f_facom.save
f_arrival = FriendlyName.where(name: "Remitos de Recepción", subject_class: "ArrivalNote").first_or_initialize
f_arrival.save
f_prod = FriendlyName.where(name: "Productos", subject_class: "Product").first_or_initialize
f_prod.save
f_prodc = FriendlyName.where(name: "Categorias de Productos", subject_class: "ProductCategory").first_or_initialize
f_prodc.save
f_depo = FriendlyName.where(name: "Depósitos", subject_class: "Depot").first_or_initialize
f_depo.save
f_serv = FriendlyName.where(name: "Servicios", subject_class: "Service").first_or_initialize
f_serv.save
f_users = FriendlyName.where(name: "Personal", subject_class: "User").first_or_initialize
f_users.save
f_company = FriendlyName.where(name: "Compañias", subject_class: "Company").first_or_initialize
f_company.save
f_rol = FriendlyName.where(name: "Roles", subject_class: "Role").first_or_initialize
f_rol.save
f_rolu = FriendlyName.where(name: "Roles de Usuario", subject_class: "UserRole").first_or_initialize
f_rolu.save
f_rolp = FriendlyName.where(name: "Permisos de Rol", subject_class: "RolePermission").first_or_initialize
f_rolp.save
f_sup = FriendlyName.where(name: "Proveedores", subject_class: "Supplier").first_or_initialize
f_sup.save
f_ivab = FriendlyName.where(name: "Libros IVA", subject_class: "IvaBook").first_or_initialize
f_ivab.save
f_receipt = FriendlyName.where(name: "Recibos", subject_class: "Receipt").first_or_initialize
f_receipt.save



#Clientes Permissions
Permission.where(action_name: "read", description: "Ver el índice de clientes", friendly_name_id: f_cli.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver información de un cliente", friendly_name_id: f_cli.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar los clientes", friendly_name_id: f_cli.id).first_or_initialize.save

#Ventas
Permission.where(action_name: "read", description: "Ver el índice de facturas de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver información de una factura de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar las facturas de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Editar las facturas de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "confirm", description: "Confirmar una factura de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "cancel", description: "Anular una factura de venta", friendly_name_id: f_fac.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear una factura de venta", friendly_name_id: f_fac.id).first_or_initialize.save


#Facturas de compra
Permission.where(action_name: "read", description: "Ver el índice de facturas de compra", friendly_name_id: f_facom.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver información de una factura de compra", friendly_name_id: f_facom.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar las facturas de compra", friendly_name_id: f_facom.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Editar las facturas de compra", friendly_name_id: f_facom.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear una factura de compra", friendly_name_id: f_facom.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar una factura de compra", friendly_name_id: f_facom.id).first_or_initialize.save

#Compañia
Permission.where(action_name: "update", description: "Actualizar información de la compañia", friendly_name_id: f_company.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear compañias", friendly_name_id: f_company.id).first_or_initialize.save
Permission.where(action_name: "see_personal", description: "Ver personal de la compañía", friendly_name_id: f_company.id).first_or_initialize.save
#Personal
Permission.where(action_name: "approve", description: "Aprobar un empleado", friendly_name_id: f_users.id).first_or_initialize.save
Permission.where(action_name: "read", description: "Ver índice de empleados", friendly_name_id: f_users.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar los empleados", friendly_name_id: f_users.id).first_or_initialize.save
Permission.where(action_name: "disapprove", description: "Expulsar un empleado", friendly_name_id: f_users.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un empleado", friendly_name_id: f_users.id).first_or_initialize.save
Permission.where(action_name: "menu", description: "Ver menú principal de Personal", friendly_name_id: f_comp.id).first_or_initialize.save


#Compras
Permission.where(action_name: "read", description: "Ver índice de ordenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de una orden de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear órdenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "approve", description: "Aprobar órdenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "disapprove", description: "Rechazar órdenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar órdenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar ordenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar ordenes de compra", friendly_name_id: f_comp.id).first_or_initialize.save
Permission.where(action_name: "menu", description: "Ver menú principal de Compras", friendly_name_id: f_comp.id).first_or_initialize.save


#Remitos de recepcion
Permission.where(action_name: "read", description: "Ver índice de remitos de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un remito de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un remito de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save
Permission.where(action_name: "cancel", description: "Anular un remito de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un remito de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar remitos de recepción", friendly_name_id: f_arrival.id).first_or_initialize.save

#Recibos
Permission.where(action_name: "read", description: "Ver índice de recibos", friendly_name_id: f_receipt.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un recibo", friendly_name_id: f_receipt.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un recibo", friendly_name_id: f_receipt.id).first_or_initialize.save
Permission.where(action_name: "cancel", description: "Anular un recibo", friendly_name_id: f_receipt.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un recibo", friendly_name_id: f_receipt.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar recibos", friendly_name_id: f_receipt.id).first_or_initialize.save

#Productos
Permission.where(action_name: "read", description: "Ver índice de productos", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un producto", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un producto", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un producto", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un producto", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar productos", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "import", description: "Importar productos", friendly_name_id: f_prod.id).first_or_initialize.save
Permission.where(action_name: "export", description: "Exportar productos", friendly_name_id: f_prod.id).first_or_initialize.save

#Categorias de productos
Permission.where(action_name: "read", description: "Ver índice de categorías", friendly_name_id: f_prodc.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de una categoría", friendly_name_id: f_prodc.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear una categoría", friendly_name_id: f_prodc.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar una categoría", friendly_name_id: f_prodc.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar categorías", friendly_name_id: f_prodc.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar una categoría", friendly_name_id: f_prodc.id).first_or_initialize.save

#Servicios
Permission.where(action_name: "read", description: "Ver índice de servicios", friendly_name_id: f_serv.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un servicio", friendly_name_id: f_serv.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un servicio", friendly_name_id: f_serv.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un servicio", friendly_name_id: f_serv.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un servicio", friendly_name_id: f_serv.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar servicios", friendly_name_id: f_serv.id).first_or_initialize.save

#Depositos
Permission.where(action_name: "read", description: "Ver índice de depósitos", friendly_name_id: f_depo.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un depósito", friendly_name_id: f_depo.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un depósito", friendly_name_id: f_depo.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un depósito", friendly_name_id: f_depo.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un depósito", friendly_name_id: f_depo.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar depósitos", friendly_name_id: f_depo.id).first_or_initialize.save

#Proveedores
Permission.where(action_name: "read", description: "Ver índice de proveedores", friendly_name_id: f_sup.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver datos de un proveedor", friendly_name_id: f_sup.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un proveedor", friendly_name_id: f_sup.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un proveedor", friendly_name_id: f_sup.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un proveedor", friendly_name_id: f_sup.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar proveedores", friendly_name_id: f_sup.id).first_or_initialize.save

#Iva Books
Permission.where(action_name: "index", description: "Ver movimientos de Libros IVA", friendly_name_id: f_ivab.id).first_or_initialize.save
Permission.where(action_name: "gen_pdf", description: "Generar PDF con movimientos de IVA", friendly_name_id: f_ivab.id).first_or_initialize.save

#Roles
Permission.where(action_name: "read", description: "Ver índice de roles", friendly_name_id: f_rol.id).first_or_initialize.save
Permission.where(action_name: "show", description: "Ver un rol", friendly_name_id: f_rol.id).first_or_initialize.save
Permission.where(action_name: "create", description: "Crear un rol", friendly_name_id: f_rol.id).first_or_initialize.save
Permission.where(action_name: "update", description: "Actualizar un rol", friendly_name_id: f_rol.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Eliminar un rol", friendly_name_id: f_rol.id).first_or_initialize.save

#Roles de usuario
Permission.where(action_name: "manage", description: "Administrar las asignaciones de roles a los empleados", friendly_name_id: f_rolu.id).first_or_initialize.save

#Permisos
Permission.where(action_name: "create", description: "Asignar permisos", friendly_name_id: f_rolp.id).first_or_initialize.save
Permission.where(action_name: "manage", description: "Administrar permisos", friendly_name_id: f_rolp.id).first_or_initialize.save
Permission.where(action_name: "destroy", description: "Revolcar permisos", friendly_name_id: f_rolp.id).first_or_initialize.save
Permission.where(action_name: "read", description: "Ver permisos de rol", friendly_name_id: f_rolp.id).first_or_initialize.save







