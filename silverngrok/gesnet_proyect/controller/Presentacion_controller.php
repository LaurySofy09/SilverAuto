<?php 

	class Presentacion {

		public static function Listar_Presentaciones(){

			$filas = PresentacionModel::Listar_Presentaciones();
			return $filas;
		
		}

		public static function Insertar_Presentacion($presentacion,$siglas){

			$cmd = PresentacionModel::Insertar_Presentacion($presentacion,$siglas);
			
		}

		public static function Editar_Presentacion($idpresentacion,$presentacion,$siglas,$estado){

			$cmd = PresentacionModel::Editar_Presentacion($idpresentacion,$presentacion,$siglas,$estado);
			
		}

	}


 ?>