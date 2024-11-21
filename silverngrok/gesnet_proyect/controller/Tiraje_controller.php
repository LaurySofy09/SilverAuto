<?php 

	class Tiraje {

		public static function Listar_Tirajes(){

			$filas = TirajeModel::Listar_Tirajes();
			return $filas;
		
		}

		public static function Listar_Comprobantes(){

			$filas = TirajeModel::Listar_Comprobantes();
			return $filas;
		
		}

		public static function Insertar_Tiraje($fecha_resolucion, $numero_resolucion, $serie, $desde, $hasta, $disponibles, $idcomprobante){

			$cmd = TirajeModel::Insertar_Tiraje($fecha_resolucion, $numero_resolucion, $serie, $desde, $hasta, $disponibles, $idcomprobante);
			
		}

		public static function Editar_Tiraje($idtiraje, $fecha_resolucion, $numero_resolucion, $serie, $desde, $hasta, $disponibles, $idcomprobante){

			$cmd = TirajeModel::Editar_Tiraje($idtiraje, $fecha_resolucion, $numero_resolucion, $serie, $desde, $hasta, $disponibles, $idcomprobante);
			
		}

	}


 ?>