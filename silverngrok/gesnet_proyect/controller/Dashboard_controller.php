<?php

	class Dashboard {

		public static function Ver_Moneda_Reporte(){

			$filas = DashboardModel::Ver_Moneda_Reporte();
			return $filas;

		}


		public static function Datos_Paneles(){

			$filas = DashboardModel::Datos_Paneles();
			return $filas;

		}

		public static function Compras_Anuales(){

			$filas = DashboardModel::Compras_Anuales();
			return $filas;

		}

		public static function Ventas_Anuales(){

			$filas = DashboardModel::Ventas_Anuales();
			return $filas;

		}

	}


?>
