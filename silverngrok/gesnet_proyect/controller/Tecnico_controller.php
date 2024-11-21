<?php

	class Tecnico {

		public static function Listar_Tecnicos(){

			$filas = TecnicoModel::Listar_Tecnicos();
			return $filas;

		}

		public static function Insertar_Tecnico($Tecnico,$telefono){

			$cmd = TecnicoModel::Insertar_Tecnico($Tecnico,$telefono);

		}

		public static function Editar_Tecnico($idTecnico,$Tecnico,$telefono,$estado){

			$cmd = TecnicoModel::Editar_Tecnico($idTecnico,$Tecnico,$telefono,$estado);

		}

	}


 ?>
