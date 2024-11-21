<?php 

	class Perecedero {

		public static function Listar_Perecederos($fecha1,$fecha2){

			$filas = PerecederoModel::Listar_Perecederos($fecha1,$fecha2);
			return $filas;
		
		}

		public static function Listar_A_Vencer(){

			$filas = PerecederoModel::Listar_A_Vencer();
			return $filas;
		
		}

		public static function Listar_Productos(){

			$filas = PerecederoModel::Listar_Productos();
			return $filas;
		
		}

		public static function Listar_Stock($producto){

			$filas = PerecederoModel::Listar_Stock($producto);
			return $filas;
		
		}

		public static function Insertar_Perecedero($fecha_vencimiento, $cantidad_perecedero, $idproducto){

			$cmd = PerecederoModel::Insertar_Perecedero($fecha_vencimiento, $cantidad_perecedero, $idproducto);
			
		}

		public static function Editar_Perecedero($fecha_vencimiento, $cantidad_perecedero, $idproducto){

			$cmd = PerecederoModel::Editar_Perecedero($fecha_vencimiento, $cantidad_perecedero, $idproducto);
			
		}

		public static function Borrar_Perecedero($fecha_vencimiento, $idproducto){

			$cmd = PerecederoModel::Borrar_Perecedero($fecha_vencimiento, $idproducto);
			
		}


	}


 ?>