<?php 

	class Categoria {
// add static nt
		public static function Listar_Categorias(){

			$filas = CategoriaModel::Listar_Categorias();
			return $filas;
		
		}

		public static function Insertar_Categoria($categoria){

			$cmd = CategoriaModel::Insertar_Categoria($categoria);
			
		}

		public static function Editar_Categoria($idcategoria,$categoria,$estado){

			$cmd = CategoriaModel::Editar_Categoria($idcategoria,$categoria,$estado);
			
		}

	}


 ?>