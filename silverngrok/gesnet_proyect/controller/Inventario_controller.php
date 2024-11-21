<?php 

	class Inventario {

		public static function Listar_Kardex($mes){

			$filas = InventarioModel::Listar_Kardex($mes);
			return $filas;
		
		}

		public static function Listar_Entradas($mes){

			$filas = InventarioModel::Listar_Entradas($mes);
			return $filas;
		
		}

		public static function Listar_Salidas($mes){

			$filas = InventarioModel::Listar_Salidas($mes);
			return $filas;
		
		}


		public static function Insertar_Entrada($descripcion,$cantidad,$producto){

			$cmd = InventarioModel::Insertar_Entrada($descripcion,$cantidad,$producto);
			
		}

		public static function Insertar_Salida($descripcion,$cantidad,$producto){

			$cmd = InventarioModel::Insertar_Salida($descripcion,$cantidad,$producto);
			
		}


		public static function Abrir_Inventario(){

			$cmd = InventarioModel::Abrir_Inventario();
			
		}

		public static function Cerrar_Inventario(){

			$cmd = InventarioModel::Cerrar_Inventario();
			
		}

		public static function Validar_Inventario(){

			$cmd = InventarioModel::Validar_Inventario();
			
		}
	}


 ?>