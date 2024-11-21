<?php

	class Parametro {

		public static function Listar_Parametros(){

			$filas = ParametroModel::Listar_Parametros();
			return $filas;

		}

		public static function Listar_Monedas(){

			$filas = ParametroModel::Listar_Monedas();
			return $filas;

		}

		public static function Ver_Impuesto(){

			$filas = ParametroModel::Ver_Impuesto();
			return $filas;

		}

		public static function Ver_Moneda(){

			$filas = ParametroModel::Ver_Moneda();
			return $filas;

		}

		public static function Ver_Moneda_Simbolo(){

			$filas = ParametroModel::Ver_Moneda_Simbolo();
			return $filas;

		}


		public static function Insertar_Parametro($nombre_empresa, $propietario, $numero_nit,
		$numero_nrc, $porcentaje_iva,$porcentaje_retencion,$monto_retencion,$direccion,$idcurrency){

		$cmd = ParametroModel::Insertar_Parametro($nombre_empresa, $propietario, $numero_nit,
		$numero_nrc, $porcentaje_iva,$porcentaje_retencion,$monto_retencion,$direccion,$idcurrency);

		}

		public static function Editar_Parametro($idparametro, $nombre_empresa, $propietario, $numero_nit,
		$numero_nrc, $porcentaje_iva,$porcentaje_retencion,$monto_retencion,$direccion,$idcurrency){

		$cmd = ParametroModel::Editar_Parametro($idparametro, $nombre_empresa, $propietario, $numero_nit,
		$numero_nrc, $porcentaje_iva,$porcentaje_retencion,$monto_retencion,$direccion,$idcurrency);

		}

	}


 ?>
