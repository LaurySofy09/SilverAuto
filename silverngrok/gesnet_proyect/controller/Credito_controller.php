<?php

	class Credito {

		public static function Imprimir_Ticket_Abono($idabono){

			$filas = CreditoModel::Imprimir_Ticket_Abono($idabono);
			return $filas;

		}

		public static function Reporte_Abonos($fecha,$fecha2){

			$filas = CreditoModel::Reporte_Abonos($fecha,$fecha2);
			return $filas;

		}


		public static function Listar_Creditos($idcredito){

			$filas = CreditoModel::Listar_Creditos($idcredito);
			return $filas;

		}

		public static function Listar_Creditos_Espc($idcredito){

			$filas = CreditoModel::Listar_Creditos_Espc($idcredito);
			return $filas;

		}

		public static function Listar_Abonos_Credito($idcredito){

			$filas = CreditoModel::Listar_Abonos_Credito($idcredito);
			return $filas;

		}

		public static function Listar_Abonos_All(){

			$filas = CreditoModel::Listar_Abonos_All();
			return $filas;

		}

		public static function Count_Creditos(){

			$filas = CreditoModel::Count_Creditos();
			return $filas;

		}

		public static function Listar_Detalle($idVenta){

			$filas = CreditoModel::Listar_Detalle($idVenta);
			return $filas;

		}

		public static function Listar_Info($idVenta){

			$filas = CreditoModel::Listar_Info($idVenta);
			return $filas;

		}

		public static function Ver_Restante($idcredito){

			$filas = CreditoModel::Ver_Restante($idcredito);
			return $filas;

		}


		public static function Borrar_Abono($idabono){

			$cmd = CreditoModel::Borrar_Abono($idabono);

		}


		public static function Editar_Credito($id,$nombre,$fecha,$monto,$abonado,$restante,$estado){

			$cmd = CreditoModel::Editar_Credito($id,$nombre,$fecha,$monto,$abonado,$restante,$estado);

		}

		public static function Insertar_Abono($idcredito, $monto, $idusuario){

			$cmd = CreditoModel::Insertar_Abono($idcredito, $monto, $idusuario);

		}

		public static function Editar_Abono($idabono,$fecha_abono,$monto_abono){

			$cmd = CreditoModel::Editar_Abono($idabono,$fecha_abono,$monto_abono);

		}

		public static function Monto_Maximo($idcredito){

			$filas = CreditoModel::Monto_Maximo($idcredito);
			return $filas;

		}


	}


 ?>
