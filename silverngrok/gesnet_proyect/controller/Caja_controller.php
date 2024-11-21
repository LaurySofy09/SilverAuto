<?php 

	class Caja {

		public static function Validar_Caja(){

			$cmd = CajaModel::Validar_Caja();
			
		}

		public static function Listar_Datos(){

			$filas = CajaModel::Listar_Datos();
			return $filas;
		
		}

		public static function Listar_Historico($date,$date2){

			$filas = CajaModel::Listar_Historico($date,$date2);
			return $filas;
		
		}

		public static function Cerrar_Caja_Manual($id){

			$filas = CajaModel::Cerrar_Caja_Manual($id);
			return $filas;
		
		}

		public static function Listar_Movimientos(){

			$filas = CajaModel::Listar_Movimientos();
			return $filas;
		
		}

		public static function Get_Movimientos(){

			$filas = CajaModel::Get_Movimientos();
			return $filas;
		
		}

		public static function Listar_Ingresos(){

			$filas = CajaModel::Listar_Ingresos();
			return $filas;
		
		}

		public static function Listar_Devoluciones(){

			$filas = CajaModel::Listar_Devoluciones();
			return $filas;
		
		}

		public static function Listar_Prestamos(){

			$filas = CajaModel::Listar_Prestamos();
			return $filas;
		
		}

		public static function Listar_Gastos(){

			$filas = CajaModel::Listar_Gastos();
			return $filas;
		
		}

		public static function Insertar_Movimiento($tipo_movimiento,$monto,$descripcion){

			$cmd = CajaModel::Insertar_Movimiento($tipo_movimiento,$monto,$descripcion);
			
		}

		public static function Abrir_Caja($monto){

			$cmd = CajaModel::Abrir_Caja($monto);
			
		}

		public static function Update_Caja($monto){

			$cmd = CajaModel::Update_Caja($monto);
			
		}

		public static function Cerrar_Caja($monto){

			$cmd = CajaModel::Cerrar_Caja($monto);
			
		}

		public static function Insertar_Caja_Venta($monto){

			$cmd = CajaModel::Insertar_Caja_Venta($monto);
			
		}
	}


 ?>