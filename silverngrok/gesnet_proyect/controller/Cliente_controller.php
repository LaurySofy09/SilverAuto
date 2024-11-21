<?php

	class Cliente {

		public static function Listar_Clientes(){

			$filas = ClienteModel::Listar_Clientes();
			return $filas;

		}

		public static function Listar_Dias(){

			$filas = ClienteModel::Listar_Dias();
			return $filas;

		}

		public static function Ver_Limite_Credito($idcliente){

			$filas = ClienteModel::Ver_Limite_Credito($idcliente);
			return $filas;

		}

		public static function Listar_Clientes_Activos(){

			$filas = ClienteModel::Listar_Clientes_Activos();
			return $filas;

		}

		public static function Listar_Clientes_Inactivos(){

			$filas = ClienteModel::Listar_Clientes_Inactivos();
			return $filas;

		}

		public static function Insertar_Cliente($nombre_cliente, $numero_nit, $numero_nrc, $direccion,
		$numero_telefono, $email, $giro, $limite_credito, $iddias){

			$cmd = ClienteModel::Insertar_Cliente($nombre_cliente, $numero_nit, $numero_nrc, $direccion,
			$numero_telefono, $email, $giro, $limite_credito, $iddias);

		}

		public static function Editar_Cliente($idcliente, $nombre_cliente, $numero_nit, $numero_nrc, $direccion,
		$numero_telefono, $email, $giro, $limite_credito, $estado, $iddias){

			$cmd = ClienteModel::Editar_Cliente($idcliente, $nombre_cliente, $numero_nit, $numero_nrc, $direccion,
			$numero_telefono, $email, $giro, $limite_credito, $estado, $iddias);

		}

	}


 ?>
