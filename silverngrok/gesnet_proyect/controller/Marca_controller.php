<?php 

	class Marca {

		public static function Listar_Marcas(){

			$filas = MarcaModel::Listar_Marcas();
			return $filas;
		
		}

		public static function Insertar_Marca($marca){

			$cmd = MarcaModel::Insertar_Marca($marca);
			
		}

		public static function Editar_Marca($idmarca,$marca,$estado){

			$cmd = MarcaModel::Editar_Marca($idmarca,$marca,$estado);
			
		}

	}


 ?>