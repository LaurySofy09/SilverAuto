<?php 

	class Proveedor {

		public static function Listar_Proveedores(){

			$filas = ProveedorModel::Listar_Proveedores();
			return $filas;
		
		}

		public static function Insertar_Proveedor($nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc, 
		$nombre_contacto, $telefono_contacto, $Correo, $Direccion, $Comentario){

			$cmd = ProveedorModel::Insertar_Proveedor($nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc, 
			$nombre_contacto, $telefono_contacto, $Correo, $Direccion, $Comentario);
			
		}

		public static function Editar_Proveedor($idproveedor,$nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc, 
		$nombre_contacto, $telefono_contacto, $estado){

			$cmd = ProveedorModel::Editar_Proveedor($idproveedor,$nombre_proveedor, $numero_telefono, $numero_nit, $numero_nrc, 
			$nombre_contacto, $telefono_contacto,$estado);
			
		}

	}


 ?>